// Records the README demos as terminal SVGs (light and dark) in docs/media/ by running the built
// command on Examples/support-app against the on-device model, as a reader would.
//
//   swift build -c release && node scripts/demo.mjs
//
// It needs a Mac with Apple Intelligence: the output is what the model and fmdrift printed,
// colour included; nothing is typed by hand. The "drift" demo copies the example into
// .build/demo-work, shortens the instructions, and compares with the committed snapshot.
import { execFileSync } from 'node:child_process';
import { cpSync, mkdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { terminalSvg } from './terminal-svg.mjs';

const ROOT = fileURLToPath(new URL('../', import.meta.url));
const MEDIA = `${ROOT}docs/media/`;
const BINARY = `${ROOT}.build/release/fmdrift`;
const EXAMPLE = `${ROOT}Examples/support-app/`;
const WORK = `${ROOT}.build/demo-work/`;

const SHORT = 'Answer in at most eight words. Never promise refunds or dates.';
const LONG = 'Keep answers short and factual. Never promise refunds or dates.';

function prepareEditedCopy() {
  rmSync(WORK, { recursive: true, force: true });
  mkdirSync(WORK, { recursive: true });
  cpSync(`${EXAMPLE}fmdrift`, `${WORK}fmdrift`, { recursive: true });
  cpSync(`${EXAMPLE}fmdrift-snapshots`, `${WORK}fmdrift-snapshots`, { recursive: true });
  const suite = `${WORK}fmdrift/support.yaml`;
  const text = readFileSync(suite, 'utf8');
  if (!text.includes(LONG)) throw new Error('The example instructions changed; update scripts/demo.mjs.');
  writeFileSync(suite, text.replace(LONG, SHORT));
}

const DEMOS = [
  {
    name: 'run',
    title: 'fmdrift · Examples/support-app',
    comment: '# five prompts of a support inbox, three runs each, on this Mac’s on-device model',
    cwd: EXAMPLE,
    args: ['run'],
  },
  {
    name: 'drift',
    title: 'fmdrift · instructions shortened, compared with the snapshot',
    comment: `# instructions changed to "${SHORT.split('.')[0]}." and run against the recording`,
    cwd: WORK,
    prepare: prepareEditedCopy,
    args: ['run', '--baseline', 'fmdrift-snapshots', '--case', 'ticket-summary', '--case', 'off-topic-request'],
  },
];

mkdirSync(MEDIA, { recursive: true });
for (const demo of DEMOS) {
  demo.prepare?.();
  let output;
  try {
    output = execFileSync(BINARY, demo.args, {
      cwd: demo.cwd,
      encoding: 'utf8',
      env: { ...process.env, CLICOLOR_FORCE: '1', NO_COLOR: '' },
    });
  } catch (error) {
    // Exit status 1 means a case failed or regressed, which the drift demo shows on purpose.
    if (error.status !== 1) throw error;
    output = error.stdout;
  }
  const session = { title: demo.title, comment: demo.comment, command: `fmdrift ${demo.args.join(' ')}`, output };
  for (const theme of ['light', 'dark']) {
    writeFileSync(`${MEDIA}demo-${demo.name}-${theme}.svg`, terminalSvg(session, theme));
  }
  writeFileSync(`${MEDIA}demo-${demo.name}.txt`, output.replace(/\u001b\[[\d;]*m/g, ''));
  console.log(`docs/media/demo-${demo.name}-{light,dark}.svg`);
}
rmSync(WORK, { recursive: true, force: true });

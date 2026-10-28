#!/usr/bin/env bash
# Prints Formula/fmdrift.rb for muhittincamdali/homebrew-tap from a release's checksums:
#
#   scripts/homebrew-formula.sh <version> <SHA256SUMS file of the release> [<download base URL>]
#
# The formula installs the prebuilt arm64 binary the release attaches. The on-device model needs
# Apple silicon, and Foundation Models needs macOS 26, so the formula says both. The third
# argument replaces the GitHub release URL, for trying the formula with a local archive.
set -euo pipefail

version="${1:-}"
sums="${2:-}"
base="${3:-https://github.com/muhittincamdali/fmdrift/releases/download/v$version}"
if ! printf '%s' "$version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$' || [ ! -f "$sums" ]; then
  echo "usage: $0 <version, e.g. 0.1.0> <SHA256SUMS> [<base URL>]" >&2
  exit 64
fi

file="fmdrift-$version-macos-arm64.tar.gz"
sum="$(awk -v file="$file" '$2 == file || $2 == "*" file || $2 == "./" file { print $1 }' "$sums")"
if ! printf '%s' "$sum" | grep -Eq '^[0-9a-f]{64}$'; then
  echo "error: no SHA-256 for $file in $sums" >&2
  exit 1
fi

cat <<FORMULA
class Fmdrift < Formula
  desc "Regression tests for prompts to Apple's on-device foundation model"
  homepage "https://github.com/muhittincamdali/fmdrift"
  url "$base/$file"
  # Homebrew reads "64" from "arm64" in the file name as the version, so it is stated.
  version "$version"
  sha256 "$sum"
  license "MIT"

  depends_on arch: :arm64
  depends_on macos: :tahoe

  def install
    bin.install "fmdrift"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/fmdrift --version").strip
    system bin/"fmdrift", "init"
    assert_match "suite \`starter\`, 2 cases", shell_output("#{bin}/fmdrift validate")
    (testpath/"bad.yaml").write "cases:\n  - id: a\n    prompt: p\n    expect:\n      - contans: x\n"
    assert_match "did you mean \`contains\`", shell_output("#{bin}/fmdrift validate bad.yaml", 1)
  end
end
FORMULA

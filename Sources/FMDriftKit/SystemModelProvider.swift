import Foundation

#if canImport(FoundationModels)
    import FoundationModels

    /// Answers with Apple's on-device foundation model (`SystemLanguageModel`).
    ///
    /// Each generation uses a new `LanguageModelSession`, so one case cannot see another's
    /// transcript, and the context window starts empty every time.
    public struct SystemModelProvider: ModelProvider {
        /// Seconds after which a generation is cancelled and recorded as a timeout.
        public var timeout: Double

        public init(timeout: Double = 120) {
            self.timeout = timeout
        }

        public func availability() async -> ModelAvailability {
            Self.availability(of: SystemLanguageModel.default)
        }

        static func availability(of model: SystemLanguageModel) -> ModelAvailability {
            switch model.availability {
            case .available:
                return .available
            case .unavailable(.deviceNotEligible):
                return .unavailable(
                    reason: "deviceNotEligible",
                    explanation: "This Mac cannot run Apple Intelligence; the on-device model needs Apple silicon."
                )
            case .unavailable(.appleIntelligenceNotEnabled):
                return .unavailable(
                    reason: "appleIntelligenceNotEnabled",
                    explanation: "Turn on Apple Intelligence in System Settings › Apple Intelligence & Siri."
                )
            case .unavailable(.modelNotReady):
                return .unavailable(
                    reason: "modelNotReady",
                    explanation: "The model is still downloading or being prepared; try again in a few minutes."
                )
            case .unavailable(let other):
                return .unavailable(reason: "\(other)", explanation: "The on-device model is not available.")
            }
        }

        public func environment() async -> RunEnvironment {
            let model = SystemLanguageModel.default
            let availability = Self.availability(of: model)
            let contextSize = availability == .available ? model.contextSize : nil
            return .host(provider: "system", modelAvailability: availability.code, contextSize: contextSize)
        }

        public func generate(_ request: GenerationRequest) async -> Generation {
            let limit = timeout
            return await withTaskGroup(of: Generation?.self) { group in
                group.addTask { await Self.respond(to: request) }
                group.addTask {
                    try? await Task.sleep(for: .seconds(limit))
                    return Task.isCancelled
                        ? nil : .failed(.timeout, "no response within \(Format.duration(limit))", latency: limit)
                }
                var result: Generation?
                while let next = await group.next() {
                    if let next {
                        result = next
                        break
                    }
                }
                group.cancelAll()
                return result ?? .failed(.timeout, "no response", latency: limit)
            }
        }

        static func respond(to request: GenerationRequest) async -> Generation {
            let model = SystemLanguageModel(
                useCase: request.settings.useCase == .contentTagging ? .contentTagging : .general,
                guardrails: request.settings.guardrails == .default ? .default : .permissiveContentTransformations
            )
            if case .unavailable(_, let explanation) = availability(of: model) {
                return .failed(.modelUnavailable, explanation, latency: 0)
            }
            let session = LanguageModelSession(model: model, instructions: request.settings.instructions)
            let options = Self.options(for: request.settings)
            let clock = ContinuousClock()
            let start = clock.now
            do {
                let text: String
                var tokens: (input: Int?, output: Int?) = (nil, nil)
                if let schema = request.schema {
                    let generationSchema = try GenerationSchemaBuilder.schema(for: schema)
                    let response = try await session.respond(
                        to: request.prompt,
                        schema: generationSchema,
                        options: options
                    )
                    text = response.content.jsonString
                    tokens = usage(of: response)
                } else {
                    let response = try await session.respond(to: request.prompt, options: options)
                    text = response.content
                    tokens = usage(of: response)
                }
                let latency = seconds(clock.now - start)
                if tokens.output == nil {
                    tokens.output = await countTokens(text, model: model)
                }
                return Generation(text: text, latency: latency, outputTokens: tokens.output, inputTokens: tokens.input)
            } catch {
                let failure = ErrorClassifier.failure(from: error)
                return Generation(text: nil, latency: seconds(clock.now - start), failure: failure)
            }
        }

        static func options(for settings: GenerationSettings) -> GenerationOptions {
            let mode: GenerationOptions.SamplingMode?
            switch settings.sampling {
            case .greedy: mode = .greedy
            case .random: mode = nil  // the framework default
            case .randomTop(let top, let seed): mode = .random(top: top, seed: seed)
            case .randomProbability(let threshold, let seed):
                mode = .random(probabilityThreshold: threshold, seed: seed)
            }
            #if compiler(>=6.4)
                return GenerationOptions(
                    samplingMode: mode,
                    temperature: settings.temperature,
                    maximumResponseTokens: settings.maximumResponseTokens
                )
            #else
                return GenerationOptions(
                    sampling: mode,
                    temperature: settings.temperature,
                    maximumResponseTokens: settings.maximumResponseTokens
                )
            #endif
        }

        /// Token counts reported with the response (macOS 27 and later).
        static func usage<Content>(of response: LanguageModelSession.Response<Content>) -> (input: Int?, output: Int?) {
            #if compiler(>=6.4)
                if #available(macOS 27.0, *) {
                    return (response.usage.input.totalTokenCount, response.usage.output.totalTokenCount)
                }
            #endif
            return (nil, nil)
        }

        /// Counts the response's tokens on macOS 26.4 and later, where the OS does not report them
        /// with the response.
        static func countTokens(_ text: String, model: SystemLanguageModel) async -> Int? {
            if #available(macOS 26.4, *) {
                return try? await model.tokenCount(for: text)
            }
            return nil
        }

        static func seconds(_ duration: Duration) -> Double {
            Double(duration.components.seconds) + Double(duration.components.attoseconds) / 1e18
        }
    }

    /// Turns a ``JSONSchema`` into the `GenerationSchema` that guided generation takes.
    enum GenerationSchemaBuilder {
        static func schema(for schema: JSONSchema) throws -> GenerationSchema {
            try GenerationSchema(root: dynamic(schema, name: "Response"), dependencies: [])
        }

        static func dynamic(_ schema: JSONSchema, name: String) throws -> DynamicGenerationSchema {
            switch schema {
            case .object(let properties, let description):
                return DynamicGenerationSchema(
                    name: name,
                    description: description,
                    properties: try properties.map { property in
                        DynamicGenerationSchema.Property(
                            name: property.name,
                            description: property.schema.descriptionText,
                            schema: try dynamic(property.schema, name: "\(name)_\(property.name)"),
                            isOptional: !property.isRequired
                        )
                    }
                )
            case .string(let enumValues, let pattern, let description):
                if let enumValues {
                    return DynamicGenerationSchema(name: name, description: description, anyOf: enumValues)
                }
                if let pattern {
                    return DynamicGenerationSchema(type: String.self, guides: [.pattern(try Regex(pattern))])
                }
                return DynamicGenerationSchema(type: String.self)
            case .integer(let minimum, let maximum, _):
                var guides: [GenerationGuide<Int>] = []
                if let minimum { guides.append(.minimum(minimum)) }
                if let maximum { guides.append(.maximum(maximum)) }
                return DynamicGenerationSchema(type: Int.self, guides: guides)
            case .number(let minimum, let maximum, _):
                var guides: [GenerationGuide<Double>] = []
                if let minimum { guides.append(.minimum(minimum)) }
                if let maximum { guides.append(.maximum(maximum)) }
                return DynamicGenerationSchema(type: Double.self, guides: guides)
            case .boolean:
                return DynamicGenerationSchema(type: Bool.self)
            case .array(let items, let minItems, let maxItems, _):
                return DynamicGenerationSchema(
                    arrayOf: try dynamic(items, name: "\(name)_item"),
                    minimumElements: minItems,
                    maximumElements: maxItems
                )
            }
        }
    }
#endif

extension JSONSchema {
    /// The `description` keyword, which guided generation passes to the model as a hint.
    var descriptionText: String? {
        switch self {
        case .object(_, let description), .string(_, _, let description), .integer(_, _, let description),
            .number(_, _, let description), .boolean(let description), .array(_, _, _, let description):
            return description
        }
    }
}

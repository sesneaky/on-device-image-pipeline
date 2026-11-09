//
//  TaggingService.swift
//  OnDeviceImagePipeline
//
//  Created by J Kneafsey on 07/11/2026.
//

import CoreML
import Vision

struct ImageResult: Identifiable {
  let id = UUID()
  let label: String
  let score: Double
  let duration: Duration
}

enum ComputeProfile: String, CaseIterable {
  case all, cpuOnly, cpuAndGPU, cpuAndNeuralEngine

  var configuration: MLModelConfiguration {
    let config = MLModelConfiguration()
    config.computeUnits = switch self {
    case .all:               .all
    case .cpuOnly:           .cpuOnly
    case .cpuAndGPU:         .cpuAndGPU
    case .cpuAndNeuralEngine: .cpuAndNeuralEngine
    }
    return config
  }
}

final class TaggingService {
  enum TaggingError: Error {
    case modelMissing                       // bundle resource not found (fresh-clone failure mode)
    case modelNotLoaded                     // run before loadModel succeeded
    case noResults                          // received no classifications from model
  }

  private var visionRequest: CoreMLRequest?
  private let clock = ContinuousClock()

  private(set) var isLoaded = false

  func loadModel(profile: ComputeProfile) async throws {
    guard let url = Bundle.main.url(forResource: "ImageClassifier", withExtension: "mlmodelc") else {
      throw TaggingError.modelMissing
    }
    let coreModel = try MLModel(contentsOf: url, configuration: profile.configuration)

    let container = try CoreMLModelContainer(model: coreModel)

    let request = CoreMLRequest(model: container)

    self.visionRequest = request

    isLoaded = true
  }

  func run(on image: CGImage) async throws -> ImageResult {
    guard let request = visionRequest else {
      throw TaggingError.modelNotLoaded
    }

    var obs: [any VisionObservation] = []

    let duration = try await clock.measure {
      let handler = ImageRequestHandler(image)
      obs = try await handler.perform(request)
    }

    return try Self.makeResult(obs: obs, duration: duration)
  }

  private static func makeResult(obs: [any VisionObservation], duration: Duration) throws -> ImageResult {
    let classes = obs.compactMap { $0 as? ClassificationObservation }
        .sorted { $0.confidence > $1.confidence }

    guard let top = classes.first else {
      throw TaggingError.noResults
    }

    return ImageResult(label: top.identifier,
                       score: Double(top.confidence),
                       duration: duration)
  }
}

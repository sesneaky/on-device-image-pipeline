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
  }

  private(set) var isLoaded = false

  func loadModel(profile: ComputeProfile) async throws {
    guard let url = Bundle.main.url(forResource: "ImageClassifier", withExtension: "mlmodelc") else {
      throw TaggingError.modelMissing
    }
    _ = try MLModel(contentsOf: url, configuration: profile.configuration)

    isLoaded = true
  }
}

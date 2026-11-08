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

final class TaggingService {
    func runDummyBatch() async -> [ImageResult] {
      return ["bear", "ladder", "cloud"].map(ImageResult.init)
    }
}

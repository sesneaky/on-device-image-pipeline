//
//  PipelineViewModel.swift
//  OnDeviceImagePipeline
//
//  Created by J Kneafsey on 07/11/2026.
//

import SwiftUI
import PhotosUI
import UIKit

enum RunState {
  /// Model still loading — Run is gated; nothing can start yet.
  case loadingModel

  /// Model ready, idle — Run is enabled (given a selection).
  case idle

  /// Batch in flight — Cancel is available, results stream in.
  case running

  /// Model loaded but something is missing/limited (e.g. no Neural Engine fallback).
  case degraded(String)

  /// Terminal failure — model missing or failed to load. Run stays gated.
  case failed(String)
}

@MainActor
@Observable
final class PipelineViewModel {
  let service = TaggingService()
  var state: RunState = .loadingModel

  var isReady: Bool {
    if case .idle = state { return true }
    return false
  }

  var isRunning: Bool {
    if case .running = state { return true }
    return false
  }

  private(set) var results: [ImageResult] = []

  init() {
    Task {
      do {
        try await service.loadModel(profile: .cpuAndNeuralEngine)
        state = .idle
      } catch {
        state = .failed("Model failed to load: \(error.localizedDescription)")
      }
    }
  }

  func start(with items: [PhotosPickerItem]) async {
    state = .running
    results = []

    let images = await loadImages(items)

    guard let first = images.first else {
      state = .failed("No photos could be loaded")
      return
    }

    do {
      for _ in 1...2 {                              // two passes to account for cold start
        let result = try await service.run(on: first)
        results.append(result)
        print("inference: \(result.duration)")
      }
      state = .idle
    } catch {
      state = .failed("Inference failed: \(error.localizedDescription)")
    }
  }

  private func loadImages(
    _ items: [PhotosPickerItem]
  ) async -> [CGImage] {
    await withTaskGroup(of: CGImage?.self) { group in
      for item in items {
        group.addTask {
          guard let data = try? await item.loadTransferable(
            type: Data.self
          ),
                let ui = UIImage(data: data),
                let cg = ui.cgImage else {
            return nil
          }

          return cg
        }
      }

      var out: [CGImage] = []

      for await img in group {
        if let img {
          out.append(img)
        }
      }

      return out
    }
  }
}

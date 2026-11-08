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
  case idle
  case running
}

@MainActor
@Observable
final class PipelineViewModel {

  var state: RunState = .idle

  var isRunning: Bool {
    if case .running = state { return true }
    return false
  }

  private(set) var images: [CGImage] = []
  private(set) var loadedCount = 0

  func start(with items: [PhotosPickerItem]) async {
    state = .running
    images = []
    loadedCount = 0

    images = await loadImages(items)
    loadedCount = images.count

    state = .idle
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

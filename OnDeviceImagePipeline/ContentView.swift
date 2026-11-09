//
//  ContentView.swift
//  OnDeviceImagePipeline
//
//  Created by J Kneafsey on 30/10/2026.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
  @State private var selectedPhotos: [PhotosPickerItem] = []
  @State private var viewModel = PipelineViewModel()

  private var statusLine: String {
    if viewModel.isRunning {
      return "Loading \(selectedPhotos.count) photos…"
    }
    if !viewModel.results.isEmpty {
      return "\(selectedPhotos.count) photos selected"
    }
    return "\(selectedPhotos.count) photos selected"
  }

  var body: some View {
    VStack(spacing: 16) {
      PhotosPicker(
        selection: $selectedPhotos,
        maxSelectionCount: 200,
        matching: .images
      ) {
        Label("Select Photos", systemImage: "photo.on.rectangle")
      }

      if !selectedPhotos.isEmpty {
        Text(statusLine)
          .font(.callout)
          .foregroundStyle(.secondary)
      }

      Button(viewModel.isRunning ? "Running…" : "Run") {
        Task { await viewModel.start(with: selectedPhotos) }
      }
      .buttonStyle(.borderedProminent)
      .disabled(selectedPhotos.isEmpty || viewModel.isRunning || !viewModel.isReady)

      if !viewModel.results.isEmpty {
        Text(viewModel.results[0].label)
          .font(.headline)
      }
    }
    .padding()
  }
}
#Preview {
  ContentView()
}

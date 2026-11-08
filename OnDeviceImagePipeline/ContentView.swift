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
    if viewModel.loadedCount > 0 {
      return "\(viewModel.loadedCount) images loaded"
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

      if !selectedPhotos.isEmpty || viewModel.loadedCount > 0 {
        Text(statusLine)
          .font(.callout)
          .foregroundStyle(.secondary)
      }

      Button(viewModel.isRunning ? "Running…" : "Run") {
        Task { await viewModel.start(with: selectedPhotos) }
      }
      .buttonStyle(.borderedProminent)
      .disabled(selectedPhotos.isEmpty || viewModel.isRunning || !viewModel.isReady)
    }
    .padding()
  }
}

#Preview {
  ContentView()
}

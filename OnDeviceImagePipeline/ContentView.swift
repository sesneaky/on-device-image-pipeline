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
        Text("\(selectedPhotos.count) photos selected")
          .font(.callout)
          .foregroundStyle(.secondary)
      }

      Button(viewModel.isRunning ? "Running…" : "Run") {
        Task {
          await viewModel.start(with: selectedPhotos)
        }
      }
      .buttonStyle(.borderedProminent)
      .disabled(selectedPhotos.isEmpty || viewModel.isRunning)

      if !viewModel.isRunning && viewModel.loadedCount > 0 {
        Text("\(viewModel.loadedCount) images loaded")
          .font(.callout)
          .foregroundStyle(.secondary)
      }
    }
    .padding()
  }
}

#Preview {
  ContentView()
}

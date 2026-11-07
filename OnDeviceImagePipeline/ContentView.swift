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
  @State private var isRunning = false

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

      Button(isRunning ? "Running…" : "Run") {
        runPipeline()
      }
      .buttonStyle(.borderedProminent)
      .disabled(selectedPhotos.isEmpty || isRunning)
    }
    .padding()
  }

  private func runPipeline() {
    isRunning = true
  }
}

#Preview {
  ContentView()
}

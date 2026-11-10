# on-device-image-pipeline

An on-device image classifier for iOS. Provides an ImageNet label and inference time. Local processing only, backend free, no external dependencies - system frameworks only (Core ML, Vision, SwiftUI, PhotosUI).

**Status:** single-image inference working end-to-end; batch mode next.

## Requirements

- Xcode 27.2, Swift 5 mode, deployment target iOS 26.5 (development tested on a device running iOS 27.2; simulator runs but has no Neural Engine)
- Fresh clone → open → run

## Architecture

```
ContentView → PipelineViewModel → TaggingService
```

`TaggingService` is the only file importing Core ML/Vision. The UI layer (ContentView and PipelineViewModel) speaks only `ComputeProfile` (in) and `ImageResult` (out).

## Engineering notes

- **Explicit compute units.** `MLModelConfiguration.computeUnits` is set explicitly, never defaulted; a `ComputeProfile` enum covers all four options. `.all` doesn't guarantee ANE dispatch (Core ML routes per-op); compute units are load-time config, not a runtime switch.
- **Specific timing measurement.** `ContinuousClock` only measures the Vision request. Decode, model load, and post-processing are intentionally excluded.
- **Visible degradation.** Model loading is async and fallible. Run is disabled until the model is loaded. A load failure surfaces as a visible failed state with the error's description, rather than a crash.
- **Async throughout.** Inference runs off the main thread. Batch loop with streaming results and Cancel are coming next.
- **Idiomatic use of Vision.** `CoreMLModelContainer` → `CoreMLRequest` are wrapped once at load and then reused per image. `ImageRequestHandler` is used per image. Vision handles resizing the selected photo to the dimensions required by the model (224×224).

## Methodology

Measured on iPhone 13 mini (A15, 16-core NE) running iOS 27.2. Real device only, one device, no cross-device claims. Cold start discarded per run. Timing bracket above.

Informal early result (single image, `.cpuAndNeuralEngine`, cold-start initial result discarded): **~35 ms**.

## Known Limitations

- Single-photo runs only; batch loop is the next milestone.
- No persistence, no tests, no accuracy evaluation (I'm just doing spot checks on labels).
- One device, one model (gallery MobileNetV2 FP32, 24.7 MB); comparison axis is compute config, not architecture.
- 224×224 fixed input; Vision crops, aspect ratio not compensated.
- Cosmetic Core ML warning at load (`precisionRecallCurves`) - probes metadata only updatable models carry; no effect on results.

## Next

- Batch mode with streaming results and cancellation
- Swift 6 strict concurrency migration
- FP16 variant trade-off (12.4 MB vs 24.7 MB)
- `OSSignposter` intervals for Instruments

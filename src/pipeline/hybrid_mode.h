#pragma once

enum class UpscaleMode { FSR_ONLY = 0, NEURAL_ONLY = 1, HYBRID = 2 };

/*
Example usage:
// enum UpscaleMode { FSR_ONLY, NEURAL_ONLY, HYBRID };
// void processFrame(void* input, UpscaleMode mode) {
//     if (mode == UpscaleMode::HYBRID) { fsrUpscale(input,...); ncnnInfer(...);
}
// }
*/

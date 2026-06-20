# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

RKNN-Toolkit2 is Rockchip's NPU (Neural Network Processing Unit) SDK for deploying AI models on Rockchip chips (RK3588, RK3576, RK3566/3568, RK3562, RV1103/1106, RV1126B, RK2118). The workflow is: convert trained models to RKNN format on PC, then run inference on device via C/C++ or Python APIs.

## Repository Structure

Four main components, each in its own top-level directory:

- **rknn-toolkit2/** - PC-side model conversion, quantization, inference, and evaluation (Python wheels for x86_64 and arm64, Python 3.6-3.12)
- **rknn-toolkit-lite2/** - Lightweight device-side Python inference API (pre-built wheels)
- **rknpu2/** - C/C++ runtime libraries and examples for production deployment on-device
- **autosparsity/** - PyTorch sparse model training support (pre-built wheels)
- **doc/** - PDF documentation (Quick Start guides, API references, user guides, op support lists)

## Build & Install

### Python Toolkit (PC)
```bash
pip install rknn-toolkit2/packages/x86_64/rknn_toolkit2-*-cpXX-cpXX-manylinux_2_17_x86_64.manylinux2014_x86_64.whl
```
Docker environment available: `rknn-toolkit2/docker/docker_file/` (Ubuntu 20.04, Python 3.8).

### C/C++ Runtime Examples (CMake cross-compilation)
Each example under `rknpu2/examples/` has its own build scripts:
```bash
cd rknpu2/examples/rknn_mobilenet_demo
bash build-linux.sh      # Linux (aarch64 by default)
bash build-android.sh    # Android
```
CMake 3.6+ required. Cross-compilation targets: aarch64, armhf, armhf-uclibc (Linux) or arm64-v8a (Android).

### DEB Packaging (Runtime Libraries)
```bash
cd rknpu2/runtime/Linux
bash package.sh <arch>   # arch: armhf, arm64, aarch64
```

## Architecture

The stack is layered:

1. **Conversion layer** (`rknn-toolkit2`): Runs on PC. Converts models from PyTorch/ONNX/TensorFlow/Caffe/Darknet/TFLite to `.rknn` format. Python API: `from rknn.api import RKNN`.
2. **Device inference - Python** (`rknn-toolkit-lite2`): Lightweight Python wrapper for on-device inference.
3. **Device inference - C/C++** (`rknpu2`): Production runtime. Core headers in `rknpu2/runtime/Linux/librknn_api/include/`:
   - `rknn_api.h` - Main inference API (init, run, input/output, memory management, query)
   - `rknn_matmul_api.h` - Matrix multiplication operations
   - `rknn_custom_op.h` - Custom operator registration
4. **RKNPU kernel driver** - In Rockchip kernel (not in this repo).

Runtime shared libraries are pre-built per architecture in `rknpu2/runtime/Linux/librknn_api/{aarch64,armhf}/`.

## Key Patterns

- **Examples as tests**: No formal test suite. Each `examples/` subdirectory serves as both demo and validation. Python examples use `test.py`; C/C++ examples use CMake builds.
- **Distribution is pre-built wheels and shared libraries**: This repo distributes binaries, not buildable source for the core toolkit. Development work typically involves examples, packaging, or integration.
- **Platform-specific code**: Some examples have separate implementations for RV1106/RV1103 (smaller NPU) under `RV1106_RV1103/` subdirectories.
- **Third-party deps for C++ examples**: Located in `rknpu2/examples/3rdparty/` (stb image loading, RGA graphics acceleration, MPI MMZ memory management).

## Version

Current: v2.3.2. Not compatible with the older RKNN-Toolkit (v1) which targets RK1808/RV1109/RV1126/RK3399Pro.

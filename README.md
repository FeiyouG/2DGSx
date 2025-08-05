# 2DGSx: Object-Centric 2D Gaussian Splatting

## Overview

2DGSx is an extended version of [2D Gaussian Splatting](https://github.com/hbb1/2d-gaussian-splatting) with the following improvments:
1. Implementation from [Object-centric 2DGS paper](https://github.com/MarcelRogge/object-centric-2dgs) to have better segmentation of objects and reduced gaussian size.
2. A dockerfile for easy setup

## Installation

### Option 1: Docker (Recommended)

```bash
# Build the Docker image
docker build -t 2dgsx .

# Run with GPU support
docker run --gpus all -it 2dgsx
```

### Option 2: Manual Installation

```bash
# Clone the repository
git clone https://github.com/FeiyouG/2DGSx.git --recursive
cd 2DGSx

# Create conda environment
conda env create --file environment.yml
conda activate 2dgsx
```

## Usage

2DGSx maintains the same interface as the original 2DGS, with an additional optional `--masks` flag for `convert.py`, `train.py` and `render.py`.

**Important Notes:**
- Mask filenames must exactly match image filenames (with .png extension)
- Masks should be grayscale (0-255 values)
- For COLMAP processing, masks should correspond to the original input images
- For training/rendering, masks should correspond to the undistorted images

### Example COLMAP Processing

```bash
python convert.py -s <path to dataset> --masks <mask_subdirectory>
```

### Example Training

```bash
python train.py -s <path to dataset> -m <output_path> --masks <mask_subdirectory>
```

### Example Rendering

```bash
python render.py -m <path to trained model> -s <path to dataset> --masks <mask_subdirectory>
```

## FAQ

**Q: How do I prepare masks for my dataset?**
A: Create grayscale PNG files where white (255) represents the object and black (0) represents background. Filenames must exactly match your images.

**Q: Can I use 2DGSx without masks?**
A: Yes, if without masks the result will be the about the same as that from 2DGS, except additioanl pruning strategy from Object-centric paper still remains. 
     Simply omit the `--masks` flag and it will work exactly like the original 2DGS.

**Q: What's the difference between masks for COLMAP vs training?**
A: COLMAP performs undistortion on images, so masks for COLMAP should correspond to original images, while masks for training should correspond to undistorted images.

## Acknowledgements

2DGSx is based on the following projects:
- [Gaussian Splatting](https://github.com/graphdeco-inria/gaussian-splatting?tab=readme-ov-file) by Kerbl et al.
- [2D Gaussian Splatting](https://github.com/hbb1/2d-gaussian-splatting) by Huang et al.
- [object-centric 2dgs](https://github.com/MarcelRogge/object-centric-2dgs) by Rogge et al.
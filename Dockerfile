# Base CUDA 11.7 base with Ubuntu 22.04 (closest match for PyTorch & tooling)
FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04

# Set up environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install tiny-cuda-nn
# Set this to the correct compute capability of the GPU, A100 is 80
ENV TCNN_CUDA_ARCHITECTURES=80

# A10G uses the GA102 GPU, which is Ampere architecture.
ENV TORCH_CUDA_ARCH_LIST="8.6"

# Expose Cuda dir and home
ENV CONDA_DIR=/opt/conda
ENV PATH=$CONDA_DIR/bin:$PATH
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    cmake \
    build-essential \
    libglfw3-dev \
    libglew-dev \
    libassimp-dev \
    libboost-all-dev \
    libgtk-3-dev \
    libopencv-dev \
    libavdevice-dev \
    libavcodec-dev \
    libeigen3-dev \
    libxxf86vm-dev \
    libembree-dev \
    ffmpeg \
    imagemagick \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p $CONDA_DIR && \
    rm /tmp/miniconda.sh && \
    $CONDA_DIR/bin/conda clean -afy

# Clone repo and init submodules
WORKDIR /workspace
COPY . /workspace/2d-gaussian-splatting
WORKDIR /workspace/2d-gaussian-splatting
RUN git submodule update --init --recursive

# Setup Conda and install dependencies manually
RUN /bin/bash -c "source $CONDA_DIR/etc/profile.d/conda.sh && \
    conda config --add channels defaults && \
    conda config --set always_yes yes && \
    conda config --set auto_update_conda false && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r && \
    conda create -n 2d-gaussian-splatting python=3.7 -y && \
    conda activate 2d-gaussian-splatting && \
    conda install pytorch==1.13.1 torchvision==0.14.1 torchaudio==0.13.1 pytorch-cuda=11.7 -c pytorch -c nvidia && \
    conda install -c conda-forge colmap opencv matplotlib && \
    pip install --no-cache-dir ./submodules/diff-surfel-rasterization && \
    pip install --no-cache-dir ./submodules/simple-knn && \
    pip install --no-cache-dir plyfile tqdm mediapy open3d trimesh"

# Automatically activate the env on shell startup
RUN echo "source $CONDA_DIR/etc/profile.d/conda.sh && conda activate 2d-gaussian-splatting" >> ~/.bashrc

CMD ["/bin/bash"]

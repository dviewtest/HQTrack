FROM nvidia/cuda:11.7.1-devel-ubuntu20.04
LABEL Maintainer="jamie.conlon@dviewapps.com"

ARG DEBIAN_FRONTEND=noninteractive

ENV NVIDIA_VISIBLE_DEVICES all

ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

RUN mkdir HQTRACK
WORKDIR /HQTRACK/

RUN apt-get update \
        && apt-get install -y build-essential \
        && apt-get install -y wget \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

ENV PATH=/usr/local/cuda-11.7/bin:$PATH
ENV PATH=/root/.local/bin:$PATH

RUN apt-get update && apt-get install -y python3 python3-pip libgl1-mesa-dev libglib2.0-0

COPY requirements.txt .

RUN pip3 install --user -r requirements.txt
RUN pip3 install torch torchvision torchaudio

COPY . /HQTRACK

WORKDIR /HQTRACK/segment_anything_hq/
RUN pip3 install -e .
RUN pip3 install opencv-python pycocotools matplotlib onnxruntime onnx

WORKDIR /HQTRACK/packages/Pytorch-Correlation-extension
RUN python3 setup.py install

WORKDIR /HQTRACK/networks/encoders/ops_dcnv3
RUN ./make.sh

WORKDIR /HQTRACK/demo/
VOLUME /HQTRACK/demo/hqtrack_out

# Run demo.py on container start with argument specifying image
#ENTRYPOINT ["/bin/bash"]
ENTRYPOINT ["python3", "demo.py", "--video"]

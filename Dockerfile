#ARG AIDO_REGISTRY

# 1.7.0-cuda11.0-cudnn8-runtime
# docker pull pytorch/pytorch:1.7.0-cuda11.0-cudnn8-runtime
# @sha256:9cffbe6c391a0dbfa2a305be24b9707f87595e832b444c2bde52f0ea183192f1
FROM pytorch/pytorch


# we need git for certain dependencies
RUN apt-get update -y &&\
    apt-get install -y software-properties-common &&\
    add-apt-repository ppa:git-core/ppa &&\
    apt-get update -y &&\
    apt-get install -y --no-install-recommends \
        xvfb freeglut3-dev libglib2.0-dev libgtk2.0-dev git &&\
    rm -rf /var/lib/apt/lists/*

RUN conda install numpy pyyaml scipy ipython mkl mkl-include && conda clean -ya


WORKDIR /gym-duckietown

ARG PIP_INDEX_URL
ENV PIP_INDEX_URL=${PIP_INDEX_URL}

RUN pip install -U "pip>=20.2"
# first install the ones that do not change
COPY requirements.pin.txt .
RUN pip install --use-feature=2020-resolver -r requirements.pin.txt

COPY requirements.* ./
RUN cat requirements.* > .requirements.txt
RUN cat .requirements.txt

RUN pip install --use-feature=2020-resolver -r .requirements.txt
RUN pipdeptree

COPY . .

RUN TORCH_CUDA_ARCH_LIST="3.5 5.2 6.0 6.1 7.0+PTX" \
    TORCH_NVCC_FLAGS="-Xfatbin -compress-all" \
    CMAKE_PREFIX_PATH="$(dirname $(which conda))/../" \
    pip install -v  .

#   pip install -v -e .

RUN pipdeptree

#FROM nvidia/cuda:9.1-runtime-ubuntu16.04
#
#RUN apt-get update -y && apt-get install -y --no-install-recommends \
#         git \
#         xvfb \
#         bzip2 \
#         python-pip \
#         python-setuptools\
#         freeglut3-dev \
#          python-subprocess32 python-matplotlib python-yaml python-opencv
##         && \
##     rm -rf /var/lib/apt/lists/*
#
#WORKDIR /workspace
#
#
#
#COPY docker/AIDO1/server-python2/requirements.txt /requirements.txt
#RUN pip install -r /requirements.txt
#
#
#RUN pip install -e git+https://github.com/duckietown/duckietown-slimremote.git#egg=duckietown-slimremote
#
#
#EXPOSE 5558 8902
#
#
#
#ADD . gym-duckietown
#
#RUN cd gym-duckietown && python setup.py develop --no-deps
#
#COPY docker/AIDO1/server-python2/launch-gym-server-with-xvfb.sh /usr/bin/launch-gym-server-with-xvfb
#COPY docker/AIDO1/server-python2/launch-xvfb /usr/bin/launch-xvfb
#
#CMD launch-gym-server-with-xvfb

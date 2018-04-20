ARG cuda=8.0

FROM nvidia/cuda:$cuda-runtime

RUN apt-get update \
    && apt-get install -y \
    python2.7 \
    python-pip \ 
    git \ 
    build-essential \
    libfreetype6-dev \
    pkg-config \
    libpng12-dev \
    && rm -rf /var/lib/apt/lists/* 

RUN git clone https://github.com/annarchy/annarchy

WORKDIR /annarchy

RUN pip install numpy sympy scipy cython \
    && python setup.py install


FROM ubuntu:14.04
MAINTAINER Alex Zaporozhets <alexzaporozhets@gmail.com>

# install depdencies
RUN apt-get update          &&  \
    DEBIAN_FRONTEND=noninteractive apt-get -y upgrade      &&  \
    DEBIAN_FRONTEND=noninteractive apt-get install -y          \
    build-essential \
    libglib2.0-dev \
    libopencv-dev \
    libx11-xcb-dev \
    libgl1-mesa-dev \
    libxcb1-dev \
    libx11-xcb-dev \
    libxcb-record0-dev \
    libxmu-dev \
    libappindicator-dev \
    libnotify-dev \
    libgstreamer-plugins-base0.10-dev \
    git \
    chrpath \
    make \
    build-essential \
    g++ \
    lib32gcc1 \
    nano \
    libc6-i386 \
    python \
    python2.7 \
    unzip \
    wget \
    "^libxcb.*" \
    libx11-xcb-dev \
    libglu1-mesa-dev \
    libxrender-dev \
    libxi-dev \
    libssl-dev \
    libxcursor-dev \
    libxcomposite-dev \
    libxdamage-dev \
    libxrandr-dev \
    libfontconfig1-dev \
    libcap-dev \
    libbz2-dev \
    libgcrypt11-dev \
    libpci-dev \
    libnss3-dev \
    libxcursor-dev \
    libxcomposite-dev \
    libxdamage-dev \
    libxrandr-dev \
    libdrm-dev \
    libfontconfig1-dev \
    libxtst-dev \
    libasound2-dev \
    gperf \
    libcups2-dev \
    libpulse-dev \
    libudev-dev \
    libssl-dev \
    flex \
    bison \
    ruby \
    libicu-dev \
    libxslt-dev \
    zlib1g-dev \
    mc \
    wget \
    qtchooser \
    python-magic \
    s3cmd

RUN apt-get autoremove -y
RUN apt-get clean

# moving configuration
COPY qtchooser/default.conf /usr/lib/x86_64-linux-gnu/qtchooser/default.conf
COPY etc/ld.so.conf.d/opt-qt-5.4.2-lib.conf /etc/ld.so.conf.d/opt-qt-5.4.2-lib.conf

# settign current working directory
WORKDIR /opt

# downloading Qt & unpack
RUN wget "https://s3.amazonaws.com/mystaff-qt-build/linux/qt5/qt-5.4.2-install-dir-x86_64.tar.xz"
RUN tar -C /opt -xvJf qt-5.4.2-install-dir-x86_64.tar.xz

# cleanup
RUN rm -rf qt-5.4.2-install-dir-x86_64.tar.xz

RUN ldconfig

# Copy build sandbox into docker image
COPY build-sandbox/linux /opt/build-sandbox

# I think we can remove this step
RUN mkdir -p /opt/build-sandbox/qthybrid-app


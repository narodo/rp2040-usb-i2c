FROM ubuntu:22.04 AS ndk

ARG USER_ID
ARG GROUP_ID

RUN apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    sudo \
    build-essential \
    gcc \
    lsb-release \
    git \
    file \
    wget \
    unzip \
    cmake \
    gcc-arm-none-eabi \
    libnewlib-arm-none-eabi \ 
    libstdc++-arm-none-eabi-newlib

# install pico sdk
RUN git clone --recurse-submodules  https://github.com/raspberrypi/pico-sdk.git /opt/pico-sdk-master

# Create a user with the same id and group_id as the host user so that artifacts can be chowned to that
RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
    if [ "$(id build)" -ne "" ]; then \
        userdel -f build \
        && if getent group build ; then groupdel build; fi \
    fi \
    && groupadd -g ${GROUP_ID} build \
    && useradd -l -u ${USER_ID} -g build build \ 
    && install -d -m 0755 -o build -g build /home/build \
    && chown --changes --silent --no-dereference --recursive ${USER_ID}:${GROUP_ID} /home/build \
;fi

RUN echo "export PATH=\$PATH:/home/build/.local/bin" >> /home/build/.bash_profile \
    && chown build:build /home/build/.bash_profile

RUN passwd --delete build && adduser build sudo

USER build

ENV PICO_SDK_PATH=/opt/pico-sdk-master

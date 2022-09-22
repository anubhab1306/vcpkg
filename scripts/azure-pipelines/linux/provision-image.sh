#!/bin/bash
# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT
#

export DEBIAN_FRONTEND=noninteractive

# Add apt repos

## CUDA
apt-key del 7fa2af80
if [[ $(grep Microsoft /proc/version) ]]; then
### WSL Ubuntu
https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin
mv cuda-wsl-ubuntu.pin /etc/apt/preferences.d/cuda-repository-pin-600
apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/3bf863cc.pub
add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/ /"
else
### Ubuntu
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub
add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /"
fi

## PowerShell
wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
rm -f packages-microsoft-prod.deb
add-apt-repository universe

apt-get -y update
apt-get -y dist-upgrade

# Add apt packages

## vcpkg prerequisites
APT_PACKAGES="git curl zip unzip tar"

## common build dependencies
APT_PACKAGES="$APT_PACKAGES at libxt-dev gperf libxaw7-dev cifs-utils \
  build-essential g++ gfortran libx11-dev libxkbcommon-x11-dev libxi-dev \
  libgl1-mesa-dev libglu1-mesa-dev mesa-common-dev libxinerama-dev libxxf86vm-dev \
  libxcursor-dev yasm libnuma1 libnuma-dev \
  flex libbison-dev autoconf libudev-dev libncurses5-dev libtool libxrandr-dev \
  xutils-dev dh-autoreconf autoconf-archive libgles2-mesa-dev ruby-full \
  pkg-config meson nasm cmake ninja-build"

## required by qt5-base
APT_PACKAGES="$APT_PACKAGES libxext-dev libxfixes-dev libxrender-dev \
  libxcb1-dev libx11-xcb-dev libxcb-glx0-dev libxcb-util0-dev"

## required by qt5-base for qt5-x11extras
APT_PACKAGES="$APT_PACKAGES libxkbcommon-dev libxcb-keysyms1-dev \
  libxcb-image0-dev libxcb-shm0-dev libxcb-icccm4-dev libxcb-sync-dev \
  libxcb-xfixes0-dev libxcb-shape0-dev libxcb-randr0-dev \
  libxcb-render-util0-dev libxcb-xinerama0-dev libxcb-xkb-dev libxcb-xinput-dev"

## required by libhdfs3
APT_PACKAGES="$APT_PACKAGES libkrb5-dev"

## required by kf5windowsystem
APT_PACKAGES="$APT_PACKAGES libxcb-res0-dev"

## required by mesa
APT_PACKAGES="$APT_PACKAGES python3-setuptools python3-mako"

## required by some packages to install additional python packages
APT_PACKAGES="$APT_PACKAGES python3-pip python3-venv"

## required by qtwebengine
APT_PACKAGES="$APT_PACKAGES nodejs"

## required by qtwayland
APT_PACKAGES="$APT_PACKAGES libwayland-dev"

## required by all GN projects
APT_PACKAGES="$APT_PACKAGES python2 python-is-python3"

## required by libctl
APT_PACKAGES="$APT_PACKAGES guile-2.2-dev"

## required by gtk
APT_PACKAGES="$APT_PACKAGES libxdamage-dev"

## required by gtk3 and at-spi2-atk
APT_PACKAGES="$APT_PACKAGES libdbus-1-dev"

## required by at-spi2-atk
APT_PACKAGES="$APT_PACKAGES libxtst-dev"

## required by bond
APT_PACKAGES="$APT_PACKAGES haskell-stack"

## required by intel-mkl
APT_PACKAGES="$APT_PACKAGES intel-mkl"

## CUDA
APT_PACKAGES="$APT_PACKAGES cuda-compiler-11-6 cuda-libraries-dev-11-6 cuda-driver-dev-11-6 \
  cuda-cudart-dev-11-6 libcublas-11-6 libcurand-dev-11-6 cuda-nvml-dev-11-6 libcudnn8-dev libnccl2 \
  libnccl-dev"

## PowerShell
APT_PACKAGES="$APT_PACKAGES powershell"

## Additionally required/installed by Azure DevOps Scale Set Agents, skip on WSL
if [[ $(grep Microsoft /proc/version) ]]; then
echo "Skipping install of ADO prerequisites on WSL."
else
APT_PACKAGES="$APT_PACKAGES libkrb5-3 zlib1g libicu66"
fi

apt-get -y --no-install-recommends install $APT_PACKAGES

#!/bin/bash

if [ "$(uname -m)" = "aarch64" ]; then
    wget -q https://agr-build-files.s3.amazonaws.com/pypy3.11-v7.3.23-aarch64.tar.bz2 -O pypy.tar.bz2
    tar jxvf pypy.tar.bz2
    mv pypy3.11-v7.3.23-aarch64 pypy
    rm pypy.tar.bz2
    pypy/bin/pypy -m ensurepip --default-pip
else
    wget -q https://agr-build-files.s3.amazonaws.com/pypy.tar.bz2
    tar jxvf pypy.tar.bz2
    mv pypy3.6-7.2.0-linux_x86_64-portable pypy
    rm pypy.tar.bz2
    wget -q https://agr-build-files.s3.amazonaws.com/get-pip.py
    pypy/bin/pypy get-pip.py
    rm get-pip.py
fi
pypy/bin/pypy -m pip install docker "requests<2.32" "urllib3<2"

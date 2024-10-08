#!/bin/bash

wget -q https://agr-build-files.s3.amazonaws.com/pypy.tar.bz2
tar jxvf pypy.tar.bz2
mv pypy3.6-7.2.0-linux_x86_64-portable pypy
rm pypy.tar.bz2
wget -q https://agr-build-files.s3.amazonaws.com/get-pip.py
pypy/bin/pypy get-pip.py
rm get-pip.py
pypy/bin/pypy -m pip install docker-py

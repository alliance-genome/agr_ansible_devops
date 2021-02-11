#!/bin/bash

wget -q https://s3.amazonaws.com/agr-build-files/pypy.tar.bz2
tar jxvf pypy.tar.bz2
mv pypy3.6-7.2.0-linux_x86_64-portable pypy
rm pypy.tar.bz2
wget -q https://s3.amazonaws.com/agr-build-files/get-pip.py
pypy/bin/pypy get-pip.py
rm get-pip.py
pypy/bin/pypy -m pip install docker-py
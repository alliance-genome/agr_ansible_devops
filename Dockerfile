FROM agrdocker/agr_python_env:latest

WORKDIR /usr/src/ansible

RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install ansible curl python-pip -y
RUN pip install boto

RUN ansible-galaxy install akirak.coreos-python

RUN echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config
RUN echo "    ServerAliveInterval 120" >> /etc/ssh/ssh_config
RUN mkdir /root/.ssh
RUN mkdir /root/.docker

ADD . .

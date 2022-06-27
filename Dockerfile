ARG DOCKER_PULL_TAG=latest
ARG REG=100225593120.dkr.ecr.us-east-1.amazonaws.com
FROM ${REG}/agr_base_linux_env:${DOCKER_PULL_TAG}

WORKDIR /usr/src/ansible

RUN echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config
RUN echo "    ServerAliveInterval 120" >> /etc/ssh/ssh_config

RUN sed -i '/^\[ssh_connection\]/a retries = 20' /etc/ansible/ansible.cfg

RUN sed -i '/^\[defaults\]/a callback_whitelist=profile_tasks' /etc/ansible/ansible.cfg

RUN echo 'interpreter_python = /home/core/pypy/bin/pypy' >> /etc/ansible/ansible.cfg
RUN echo 'networks_cli_compatible = yes' >> /etc/ansible/ansible.cfg
RUN echo 'pipelining = True' >> /etc/ansible/ansible.cfg
RUN echo 'host_key_checking = False' >> /etc/ansible/ansible.cfg

RUN mkdir /root/.ssh
RUN mkdir /root/.docker

ADD . .

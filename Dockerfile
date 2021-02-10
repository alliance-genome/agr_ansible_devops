ARG DOCKER_IMAGES_TAG=latest
ARG REG=agrdocker
FROM ${REG}/agr_base_linux_env:${DOCKER_IMAGES_TAG}

WORKDIR /usr/src/ansible

RUN echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config
RUN echo "    ServerAliveInterval 120" >> /etc/ssh/ssh_config

RUN sed -i '/^\[defaults\]/a callback_whitelist=profile_tasks' /etc/ansible/ansible.cfg

RUN mkdir /root/.ssh
RUN mkdir /root/.docker

ADD . .

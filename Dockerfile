FROM agrdocker/agr_python_env:latest

WORKDIR /usr/src/ansible

RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install ansible -y

ADD . .

CMD ["ansible-playbook", "-i", "hosts", "demo-aws-launch.yml"]

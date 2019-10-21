FROM agrdocker/agr_python_env:latest

WORKDIR /usr/src/ansible

RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install ansible python-pip -y
RUN pip install boto

ADD . .

CMD ["ansible-playbook", "-i", "hosts", "demo-aws-launch.yml"]

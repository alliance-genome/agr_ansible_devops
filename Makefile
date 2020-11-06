REG := 100225593120.dkr.ecr.us-east-1.amazonaws.com

build: pull
	docker build -t ${REG}/agr_ansible_run:latest --build-arg REG=${REG} .

pull:
	docker pull ${REG}/agr_base_linux_env:latest

bash:
	docker run -it ${REG}/agr_ansible_run:latest bash

3_1_0:
	docker run -it ${REG}/agr_ansible_run:latest ansible-playbook -e env=production -e ALLIANCE_RELEASE=3.1.0 -i hosts launch_3.1.0.yml --vault-password-file=.password

3_1_1:
	docker run -it ${REG}/agr_ansible_run:latest ansible-playbook -e env=production -e ALLIANCE_RELEASE=3.1.1 -i hosts launch_3.1.1.yml --vault-password-file=.password

3_2_0:
	docker run -it ${REG}/agr_ansible_run:latest ansible-playbook -e env=production -e ALLIANCE_RELEASE=3.2.0 -i hosts launch_3.2.0.yml --vault-password-file=.password

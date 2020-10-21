build: pull
	docker build -t agrdocker/agr_ansible_run:latest .

pull:
	docker pull agrdocker/agr_base_linux_env:latest

bash:
	docker run -it agrdocker/agr_ansible_run:latest bash

3_1_0:
	docker run -it agrdocker/agr_ansible_run:latest ansible-playbook -e env=production -e ALLIANCE_RELEASE=3.1.0 -i hosts launch_3.1.0.yml --vault-password-file=.password 

3_1_1:
	docker run -it agrdocker/agr_ansible_run:latest ansible-playbook -e env=production -e ALLIANCE_RELEASE=3.1.1 -i hosts launch_3.1.1.yml --vault-password-file=.password 

3_2_0:
	docker run -it agrdocker/agr_ansible_run:latest ansible-playbook -e env=production -e ALLIANCE_RELEASE=3.2.0 -i hosts launch_3.2.0.yml --vault-password-file=.password

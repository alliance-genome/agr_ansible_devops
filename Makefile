build: pull
	docker build -t agrdocker/agr_ansible_run:latest .

pull:
	docker pull agrdocker/agr_base_linux_env:latest

bash:
	docker run -it agrdocker/agr_ansible_run:latest bash

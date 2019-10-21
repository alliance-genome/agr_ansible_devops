build: pull
	docker build -t agrdocker/agr_ansible_run:latest .

pull:
	docker pull agrdocker/agr_python_env:latest

bash:
	docker run -it agrdocker/agr_ansible_run:latest bash

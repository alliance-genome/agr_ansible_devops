REG := 100225593120.dkr.ecr.us-east-1.amazonaws.com
DOCKER_PULL_TAG  := latest
DOCKER_BUILD_TAG := latest

build: pull
	docker build -t agrlocal/agr_ansible_run_unlocked:${DOCKER_BUILD_TAG} --build-arg REG=${REG} --build-arg DOCKER_PULL_TAG=${DOCKER_PULL_TAG} .

registry-docker-login:
ifneq ($(shell echo ${REG} | egrep "ecr\..+\.amazonaws\.com"),)
	@$(eval DOCKER_LOGIN_CMD=aws)
ifneq (${AWS_PROFILE},)
	@$(eval DOCKER_LOGIN_CMD=${DOCKER_LOGIN_CMD} --profile ${AWS_PROFILE})
endif
	@$(eval DOCKER_LOGIN_CMD=${DOCKER_LOGIN_CMD} ecr get-login-password | docker login -u AWS --password-stdin https://${REG})
	${DOCKER_LOGIN_CMD}
endif

pull: registry-docker-login
	docker pull ${REG}/agr_base_linux_env:${DOCKER_PULL_TAG}

bash:
	docker run -it agrlocal/agr_ansible_run_unlocked:${DOCKER_BUILD_TAG} bash

3_1_0:
	docker run -it agrlocal/agr_ansible_run_unlocked:${DOCKER_BUILD_TAG} ansible-playbook -e env=production -e DOCKER_PULL_TAG=3.1.0 -i hosts launch_3.1.0.yml --vault-password-file=.password

3_1_1:
	docker run -it agrlocal/agr_ansible_run_unlocked:${DOCKER_BUILD_TAG} ansible-playbook -e env=production -e DOCKER_PULL_TAG=3.1.1 -i hosts launch_3.1.1.yml --vault-password-file=.password

3_2_0:
	docker run -it agrlocal/agr_ansible_run_unlocked:${DOCKER_BUILD_TAG} ansible-playbook -e env=production -e DOCKER_PULL_TAG=3.2.0 -i hosts launch_3.2.0.yml --vault-password-file=.password

4_0_0:
	docker run -it agrlocal/agr_ansible_run_unlocked:${DOCKER_BUILD_TAG} ansible-playbook -e env=production -e DOCKER_PULL_TAG=4.0.0 -i hosts launch_4.0.0.yml --vault-password-file=.password

mod_jbrowse_server:
	docker run -it -e PLAYBOOK_NAME="Mod Jbrowse Server" agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e START_GOCD_AGENT=true -e DOCKER_PULL_TAG=build -e SKIP_NVME_DRIVES=true -e WEBSERVER_INSTANCE_TYPE=m4.xlarge -e env=jbrowse -i hosts custom_playbook_launch_web_instance.yml --vault-password-file=.password

stage_web_server:
	docker run -it -e PLAYBOOK_NAME="Stage Web Server" agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e env=stage -e SKIP_NVME_DRIVES=true -e START_GOCD_AGENT=true -i hosts custom_playbook_launch_web_instance.yml --vault-password-file=.password

build_web_server:
	docker run -it -e PLAYBOOK_NAME="Build Web Server" agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e env=build -e SKIP_NVME_DRIVES=true -e START_GOCD_AGENT=true -i hosts custom_playbook_launch_web_instance.yml --vault-password-file=.password

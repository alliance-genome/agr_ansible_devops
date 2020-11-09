REG := 100225593120.dkr.ecr.us-east-1.amazonaws.com
TAG := latest

build: pull
	docker build -t agrlocal/agr_ansible_run_unlocked:${TAG} --build-arg REG=${REG} --build-arg ALLIANCE_RELEASE=${TAG} .

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
	docker pull ${REG}/agr_base_linux_env:${TAG}

bash:
	docker run -it ${REG}/agr_ansible_run:${TAG} bash

3_1_0:
	docker run -it ${REG}/agr_ansible_run:${TAG} ansible-playbook -e env=production -e ALLIANCE_RELEASE=3.1.0 -i hosts launch_3.1.0.yml --vault-password-file=.password

3_1_1:
	docker run -it ${REG}/agr_ansible_run:${TAG} ansible-playbook -e env=production -e ALLIANCE_RELEASE=3.1.1 -i hosts launch_3.1.1.yml --vault-password-file=.password

3_2_0:
	docker run -it ${REG}/agr_ansible_run:${TAG} ansible-playbook -e env=production -e ALLIANCE_RELEASE=3.2.0 -i hosts launch_3.2.0.yml --vault-password-file=.password

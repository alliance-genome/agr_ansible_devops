REG := 100225593120.dkr.ecr.us-east-1.amazonaws.com
DOCKER_PULL_TAG  := stage
DOCKER_BUILD_TAG := stage
REPO := agrlocal/agr_ansible_run_unlocked:${DOCKER_BUILD_TAG}

build: pull
	docker build --no-cache -t agrlocal/agr_ansible_run_unlocked:${DOCKER_BUILD_TAG} --build-arg REG=${REG} --build-arg DOCKER_PULL_TAG=${DOCKER_PULL_TAG} .

registry-docker-login:
ifneq ($(shell echo ${REG} | egrep "ecr\..+\.amazonaws\.com"),)
	@$(eval DOCKER_LOGIN_CMD=docker run --rm -it -v ~/.aws:/root/.aws amazon/aws-cli)
ifneq (${AWS_PROFILE},)
	@$(eval DOCKER_LOGIN_CMD=${DOCKER_LOGIN_CMD} --profile ${AWS_PROFILE})
endif
	@$(eval DOCKER_LOGIN_CMD=${DOCKER_LOGIN_CMD} ecr get-login-password | docker login -u AWS --password-stdin https://${REG})
	${DOCKER_LOGIN_CMD}
endif

registry-docker-login-ci:
ifeq ($(shell test -t 0 && echo interactive || echo ci),ci)
	@echo "[CI] logging in to ECR without a TTY …"
	@aws ecr get-login-password --region $(or $(AWS_REGION),us-east-1) \
	    | docker login --username AWS --password-stdin $(REG)
else
	@$(MAKE) registry-docker-login
endif

pull:
	docker pull ${REG}/agr_base_linux_env:${DOCKER_PULL_TAG}

bash:
	docker run -it ${REPO} bash

run_human_variant_indexer:
	docker run -it ${REPO} ansible-playbook -e AWS_PRODUCT_TAG=public-website -e AWS_ENV_TAG=stage -e env=stage -e ALLIANCE_RELEASE=7.4.0 -e DOCKER_PULL_TAG=7.3.0 -i hosts playbook_run_human_variant_indexer.yml --vault-password-file=.password

mod_jbrowse_server:
	docker run -it -e PLAYBOOK_NAME="Mod Jbrowse Server" ${REPO} ansible-playbook -e START_GOCD_AGENT=true -e DOCKER_PULL_TAG=build -e SKIP_NVME_DRIVES=true -e WEBSERVER_INSTANCE_TYPE=m4.xlarge -e env=jbrowse -i hosts custom_playbook_launch_web_instance.yml --vault-password-file=.password

zfin_jbrowse_process:
	docker run -it -e PLAYBOOK_NAME="Zfin Jbrowse Processor" ${REPO} ansible-playbook -e START_GOCD_AGENT=false -e DOCKER_PULL_TAG=zfin_latest -e SKIP_NVME_DRIVES=true -e WEBSERVER_INSTANCE_TYPE=m4.xlarge -e env=jbrowse -e jbrowse_env=zfin -i hosts playbook_run_jbrowse_process_gff.yml --vault-password-file=.password

stage_curation_server:
	docker run -it --platform linux/arm64 -e PLAYBOOK_NAME="Stage Curation" ${REPO} \
		ansible-playbook \
			-e AWS_PRODUCT_TAG=public-website \
			-e AWS_ENV_TAG=stage \
			-e env=stage \
			-e SWAP_SIZE=64G \
			-e WEBSERVER_INSTANCE_TYPE=r7g.2xlarge \
			-e WEBSERVER_AMI_IMAGE=ami-0d86c874f0fb5ae1a \
			-e SKIP_NVME_DRIVES=true \
			-e START_GOCD_AGENT=true \
			-i hosts custom_playbook_launch_web_instance.yml --vault-password-file=.password

stage_web_server:
	docker run -it -e PLAYBOOK_NAME="Stage Web Server" ${REPO} ansible-playbook -e AWS_PRODUCT_TAG=public-website -e AWS_ENV_TAG=stage -e env=stage -e SKIP_NVME_DRIVES=true -e START_GOCD_AGENT=true -i hosts custom_playbook_launch_web_instance.yml --vault-password-file=.password

gocd_server:
	docker run -it -e PLAYBOOK_NAME="GoCD Server" ${REPO} \
		ansible-playbook \
			-e AWS_PRODUCT_TAG=gocd \
			-e AWS_ENV_TAG=gocd \
			-e env=build \
			-e SWAP_SIZE=8G \
			-e WEBSERVER_INSTANCE_TYPE=m6g.large \
			-e WEBSERVER_AMI_IMAGE=ami-0d86c874f0fb5ae1a \
			-e SKIP_NVME_DRIVES=true \
			-e START_GOCD_AGENT=false \
			-i hosts custom_playbook_launch_web_instance.yml --vault-password-file=.password

openvpn_server:
	docker run -it -e PLAYBOOK_NAME="OpenVPN Server" ${REPO} ansible-playbook -e AWS_PRODUCT_TAG=open-vpn  -e AWS_ENV_TAG=build -e env=build -e WEBSERVER_INSTANCE_TYPE=t3.small -e SKIP_NVME_DRIVES=true -i hosts custom_playbook_launch_instance_bare.yml --vault-password-file=.password

start_dev_intermine_build_server:
	docker run -it -e PLAYBOOK_NAME="Dev Intermine Build Server" ${REPO} ansible-playbook -e WEBSERVER_INSTANCE_TYPE=r5a.2xlarge -e env=build -e SKIP_NVME_DRIVES=true -i hosts custom_playbook_launch_web_instance.yml --vault-password-file=.password

start_build_intermine_app_server:
	docker run -it -e PLAYBOOK_NAME="Build Intermine App Server" -e SKIP_NVME_DRIVES=true -e SETUP_NVME_DRIVE=true -e START_GOCD_AGENT=true -e WEBSERVER_INSTANCE_TYPE=i3.xlarge ${REPO} ansible-playbook -e SETUP_NVME_DRIVE=true -e SKIP_NVME_DRIVES=true -e env=build -i hosts custom_playbook_launch_intermine_instance.yml --vault-password-file=.password

start_production_intermine_app_server:
	docker run -it -e PLAYBOOK_NAME="Production Intermine App Server" -e SKIP_NVME_DRIVES=true -e SETUP_NVME_DRIVE=true -e START_GOCD_AGENT=true -e WEBSERVER_INSTANCE_TYPE=i3.xlarge ${REPO} ansible-playbook -e SETUP_NVME_DRIVE=true -e SKIP_NVME_DRIVES=true -e env=intermineproduction -i hosts custom_playbook_launch_intermine_instance.yml --vault-password-file=.password


STAGE_CLUSTER_MACHINE_TYPE := t4g.large
STAGE_COMPUTE_AMI_IMAGE := ami-0d86c874f0fb5ae1a
SWAP_SIZE := 8G

start_stage_node%:
	docker run --rm -it -e PLAYBOOK_NAME="Stage ES Cluster $*" ${REPO} \
	ansible-playbook \
		-e AWS_PRODUCT_TAG=public-website \
		-e AWS_ENV_TAG=stage \
		-e STAGE_CLUSTER_NODE=NODE$* \
		-e SWAP_SIZE=${SWAP_SIZE} \
		-e COMPUTE_INSTANCE_TYPE=${STAGE_CLUSTER_MACHINE_TYPE} \
		-e COMPUTE_AMI_IMAGE=${STAGE_COMPUTE_AMI_IMAGE} \
		-e SKIP_NVME_DRIVES=true \
		-e env=stage \
	-i hosts playbook_launch_stage_cluster_node.yml --vault-password-file=.password

PRODUCTION_CLUSTER_MACHINE_TYPE := t4g.large
PRODUCTION_COMPUTE_AMI_IMAGE := ami-0d86c874f0fb5ae1a
SWAP_SIZE := 8G

start_production_node%:
	docker run --rm -it -e PLAYBOOK_NAME="Production ES Cluster $*" ${REPO} \
	ansible-playbook \
		-e AWS_PRODUCT_TAG=public-website \
		-e AWS_ENV_TAG=production \
		-e PRODUCTION_CLUSTER_NODE=NODE$* \
		-e SWAP_SIZE=${SWAP_SIZE} \
		-e COMPUTE_INSTANCE_TYPE=${PRODUCTION_CLUSTER_MACHINE_TYPE} \
		-e COMPUTE_AMI_IMAGE=${PRODUCTION_COMPUTE_AMI_IMAGE} \
		-e SKIP_NVME_DRIVES=true \
		-e env=production \
	-i hosts playbook_launch_production_cluster_node.yml --vault-password-file=.password

ALPHA_CLUSTER_MACHINE_TYPE := m7g.xlarge
ALPHA_COMPUTE_AMI_IMAGE := ami-0d86c874f0fb5ae1a
SWAP_SIZE := 16G

start_alpha_node%:
	docker run --rm -it -e PLAYBOOK_NAME="Alpha OS Cluster $*" ${REPO} \
	ansible-playbook \
		-e AWS_PRODUCT_TAG=curation-app \
		-e AWS_ENV_TAG=alpha -e ALPHA_CLUSTER_NODE=NODE$* \
		-e SWAP_SIZE=${SWAP_SIZE} \
		-e COMPUTE_INSTANCE_TYPE=${ALPHA_CLUSTER_MACHINE_TYPE} \
		-e COMPUTE_AMI_IMAGE=${ALPHA_COMPUTE_AMI_IMAGE} \
		-e SKIP_NVME_DRIVES=true \
		-e env=alpha \
	-i hosts playbook_launch_alpha_cluster_node.yml --vault-password-file=.password

BETA_CLUSTER_MACHINE_TYPE := m7g.xlarge
BETA_COMPUTE_AMI_IMAGE := ami-0d86c874f0fb5ae1a
SWAP_SIZE := 16G

start_beta_node%:
	docker run --rm -it -e PLAYBOOK_NAME="Beta OS Cluster $*" ${REPO} \
	ansible-playbook \
		-e AWS_PRODUCT_TAG=curation-app \
		-e AWS_ENV_TAG=beta \
		-e BETA_CLUSTER_NODE=NODE$* \
		-e SWAP_SIZE=${SWAP_SIZE} \
		-e COMPUTE_INSTANCE_TYPE=${BETA_CLUSTER_MACHINE_TYPE} \
		-e COMPUTE_AMI_IMAGE=${BETA_COMPUTE_AMI_IMAGE} \
		-e SKIP_NVME_DRIVES=true \
		-e env=beta \
	-i hosts playbook_launch_beta_cluster_node.yml --vault-password-file=.password

PRODUCTION_CURATION_CLUSTER_MACHINE_TYPE := m7g.xlarge
PRODUCTION_CURATION_COMPUTE_AMI_IMAGE := ami-0d86c874f0fb5ae1a
SWAP_SIZE := 16G

start_curation_production_node%:
	docker run --rm -it -e PLAYBOOK_NAME="Production Curation OS Cluster $*" ${REPO} \
	ansible-playbook \
		-e AWS_PRODUCT_TAG=curation-app \
		-e AWS_ENV_TAG=production \
		-e PRODUCTION_CLUSTER_NODE=NODE$* \
		-e SWAP_SIZE=${SWAP_SIZE} \
		-e COMPUTE_INSTANCE_TYPE=${PRODUCTION_CURATION_CLUSTER_MACHINE_TYPE} \
		-e COMPUTE_AMI_IMAGE=${PRODUCTION_CURATION_COMPUTE_AMI_IMAGE} \
		-e SKIP_NVME_DRIVES=true \
		-e env=production \
	-i hosts playbook_launch_production_curation_cluster_node.yml --vault-password-file=.password

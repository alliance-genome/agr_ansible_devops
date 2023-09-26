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

pull:
	docker pull ${REG}/agr_base_linux_env:${DOCKER_PULL_TAG}

bash:
	docker run -it ${REPO} bash

3_1_0:
	docker run -it ${REPO} ansible-playbook -e env=production -e DOCKER_PULL_TAG=3.1.0 -i hosts launch_3.1.0.yml --vault-password-file=.password

3_1_1:
	docker run -it ${REPO} ansible-playbook -e env=production -e DOCKER_PULL_TAG=3.1.1 -i hosts launch_3.1.1.yml --vault-password-file=.password

3_2_0:
	docker run -it ${REPO} ansible-playbook -e env=production -e DOCKER_PULL_TAG=3.2.0 -i hosts launch_3.2.0.yml --vault-password-file=.password

4_0_0:
	docker run -it ${REPO} ansible-playbook -e env=production -e DOCKER_PULL_TAG=4.0.0 -i hosts launch_4.0.0.yml --vault-password-file=.password

4_1_0:
	docker run -it ${REPO} ansible-playbook -e env=production -e DOCKER_PULL_TAG=4.1.0 -i hosts launch_4.1.0.yml --vault-password-file=.password

4_2_0:
	docker run -it ${REPO} ansible-playbook -e env=production -e DOCKER_PULL_TAG=4.2.0 -i hosts launch_4.2.0.yml --vault-password-file=.password

5_0_0:
	docker run -it ${REPO} ansible-playbook -e env=production -e DOCKER_PULL_TAG=5.0.0 -i hosts launch_5.0.0.yml --vault-password-file=.password

5_1_0:
	docker run -it ${REPO} ansible-playbook -e WEBSERVER_INSTANCE_TYPE=r5a.8xlarge -e env=production -e DOCKER_PULL_TAG=5.1.0 -i hosts launch_5.1.0.yml --vault-password-file=.password

5_1_1:
	docker run -it ${REPO} ansible-playbook -e WEBSERVER_INSTANCE_TYPE=r5a.8xlarge -e env=production -e DOCKER_PULL_TAG=5.1.1 -i hosts launch_5.1.1.yml --vault-password-file=.password

5_2_0:
	docker run -it ${REPO} ansible-playbook -e WEBSERVER_INSTANCE_TYPE=r5a.8xlarge -e env=production -e DOCKER_PULL_TAG=5.2.0 -i hosts launch_5.2.0.yml --vault-password-file=.password

5_2_1:
	docker run -it ${REPO} ansible-playbook -e WEBSERVER_INSTANCE_TYPE=r5a.8xlarge -e env=production -e DOCKER_PULL_TAG=5.2.1 -i hosts launch_5.2.1.yml --vault-password-file=.password

5_3_0:
	docker run -it ${REPO} ansible-playbook -e WEBSERVER_INSTANCE_TYPE=r5a.8xlarge -e env=production -e DOCKER_PULL_TAG=5.3.0 -i hosts launch_5.3.0.yml --vault-password-file=.password

5_4_0:
	docker run -it ${REPO} ansible-playbook -e WEBSERVER_INSTANCE_TYPE=r5a.8xlarge -e env=production -e DOCKER_PULL_TAG=5.4.0 -i hosts launch_5.4.0.yml --vault-password-file=.password

6_0_0:
	docker run -it ${REPO} ansible-playbook -e WEBSERVER_INSTANCE_TYPE=r5a.4xlarge -e env=production -e DOCKER_PULL_TAG=6.0.0 -i hosts launch_6.0.0.yml --vault-password-file=.password

mod_jbrowse_server:
	docker run -it -e PLAYBOOK_NAME="Mod Jbrowse Server" ${REPO} ansible-playbook -e START_GOCD_AGENT=true -e DOCKER_PULL_TAG=build -e SKIP_NVME_DRIVES=true -e WEBSERVER_INSTANCE_TYPE=m4.xlarge -e env=jbrowse -i hosts custom_playbook_launch_web_instance.yml --vault-password-file=.password

zfin_jbrowse_process:
	docker run -it -e PLAYBOOK_NAME="Zfin Jbrowse Processor" ${REPO} ansible-playbook -e START_GOCD_AGENT=false -e DOCKER_PULL_TAG=zfin_latest -e SKIP_NVME_DRIVES=true -e WEBSERVER_INSTANCE_TYPE=m4.xlarge -e env=jbrowse -e jbrowse_env=zfin -i hosts playbook_run_jbrowse_process_gff.yml --vault-password-file=.password

stage_web_server:
	docker run -it -e PLAYBOOK_NAME="Stage Web Server" ${REPO} ansible-playbook -e env=stage -e SKIP_NVME_DRIVES=true -e START_GOCD_AGENT=true -i hosts custom_playbook_launch_web_instance.yml --vault-password-file=.password

build_web_server:
	docker run -it -e PLAYBOOK_NAME="Build Web Server" ${REPO} ansible-playbook -e env=build -e SKIP_NVME_DRIVES=true -e START_GOCD_AGENT=true -i hosts custom_playbook_launch_web_instance.yml --vault-password-file=.password

openvpn_server:
	docker run -it -e PLAYBOOK_NAME="OpenVPN Server" ${REPO} ansible-playbook -e env=build -e WEBSERVER_INSTANCE_TYPE=t3.small -e SKIP_NVME_DRIVES=true -i hosts custom_playbook_launch_instance_bare.yml --vault-password-file=.password

start_dev_intermine_build_server:
	docker run -it -e PLAYBOOK_NAME="Dev Intermine Build Server" ${REPO} ansible-playbook -e WEBSERVER_INSTANCE_TYPE=r5a.2xlarge -e env=build -e SKIP_NVME_DRIVES=true -i hosts custom_playbook_launch_web_instance.yml --vault-password-file=.password

start_build_intermine_app_server:
	docker run -it -e PLAYBOOK_NAME="Build Intermine App Server" -e SKIP_NVME_DRIVES=true -e SETUP_NVME_DRIVE=true -e START_GOCD_AGENT=true -e WEBSERVER_INSTANCE_TYPE=i3.xlarge ${REPO} ansible-playbook -e SETUP_NVME_DRIVE=true -e SKIP_NVME_DRIVES=true -e env=build -i hosts custom_playbook_launch_intermine_instance.yml --vault-password-file=.password

start_production_intermine_app_server:
	docker run -it -e PLAYBOOK_NAME="Production Intermine App Server" -e SKIP_NVME_DRIVES=true -e SETUP_NVME_DRIVE=true -e START_GOCD_AGENT=true -e WEBSERVER_INSTANCE_TYPE=i3.xlarge ${REPO} ansible-playbook -e SETUP_NVME_DRIVE=true -e SKIP_NVME_DRIVES=true -e env=intermineproduction -i hosts custom_playbook_launch_intermine_instance.yml --vault-password-file=.password

CLUSTER_MACHINE_TYPE := i3.large

start_node%:
	docker run --rm -it -e PLAYBOOK_NAME="Build ES Cluster $*" ${REPO} ansible-playbook -e CLUSTER_NODE=NODE$* -e COMPUTE_INSTANCE_TYPE=${CLUSTER_MACHINE_TYPE} -e SETUP_NVME_DRIVE=true -e SKIP_NVME_DRIVES=true -e env=build -i hosts playbook_launch_cluster_node.yml --vault-password-file=.password

start_alpha_node%:
	docker run --rm -it -e PLAYBOOK_NAME="Alpha OS Cluster $*" ${REPO} ansible-playbook -e CLUSTER_NODE=NODE$* -e COMPUTE_INSTANCE_TYPE=${CLUSTER_MACHINE_TYPE} -e SETUP_NVME_DRIVE=true -e SKIP_NVME_DRIVES=true -e env=alpha -i hosts playbook_launch_os_cluster_node.yml --vault-password-file=.password
	#docker run --rm -it -e PLAYBOOK_NAME="Build ES Cluster $*" ${REPO} ansible-playbook -e CLUSTER_NODE=NODE$* -e COMPUTE_INSTANCE_TYPE=${CLUSTER_MACHINE_TYPE} -e SKIP_NVME_DRIVES=true -e env=build -i hosts playbook_launch_cluster_node.yml --vault-password-file=.password

restart_cluster:
	docker run --rm -d -e PLAYBOOK_NAME="Build ES Cluster 01" agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e CLUSTER_NODE=NODE01 -e COMPUTE_INSTANCE_TYPE=${CLUSTER_MACHINE_TYPE} -e SKIP_NVME_DRIVES=true -e env=build -i hosts playbook_restart_cluster_node.yml --vault-password-file=.password
	docker run --rm -d -e PLAYBOOK_NAME="Build ES Cluster 02" agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e CLUSTER_NODE=NODE02 -e COMPUTE_INSTANCE_TYPE=${CLUSTER_MACHINE_TYPE} -e SKIP_NVME_DRIVES=true -e env=build -i hosts playbook_restart_cluster_node.yml --vault-password-file=.password
	docker run --rm -d -e PLAYBOOK_NAME="Build ES Cluster 03" agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e CLUSTER_NODE=NODE03 -e COMPUTE_INSTANCE_TYPE=${CLUSTER_MACHINE_TYPE} -e SKIP_NVME_DRIVES=true -e env=build -i hosts playbook_restart_cluster_node.yml --vault-password-file=.password
	docker run --rm -d -e PLAYBOOK_NAME="Build ES Cluster 04" agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e CLUSTER_NODE=NODE04 -e COMPUTE_INSTANCE_TYPE=${CLUSTER_MACHINE_TYPE} -e SKIP_NVME_DRIVES=true -e env=build -i hosts playbook_restart_cluster_node.yml --vault-password-file=.password
	docker run --rm -d -e PLAYBOOK_NAME="Build ES Cluster 05" agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e CLUSTER_NODE=NODE05 -e COMPUTE_INSTANCE_TYPE=${CLUSTER_MACHINE_TYPE} -e SKIP_NVME_DRIVES=true -e env=build -i hosts playbook_restart_cluster_node.yml --vault-password-file=.password
	docker run --rm -d -e PLAYBOOK_NAME="Build ES Cluster 06" agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e CLUSTER_NODE=NODE06 -e COMPUTE_INSTANCE_TYPE=${CLUSTER_MACHINE_TYPE} -e SKIP_NVME_DRIVES=true -e env=build -i hosts playbook_restart_cluster_node.yml --vault-password-file=.password
	docker run --rm -d -e PLAYBOOK_NAME="Build ES Cluster 07" agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e CLUSTER_NODE=NODE07 -e COMPUTE_INSTANCE_TYPE=${CLUSTER_MACHINE_TYPE} -e SKIP_NVME_DRIVES=true -e env=build -i hosts playbook_restart_cluster_node.yml --vault-password-file=.password
	docker run --rm -d -e PLAYBOOK_NAME="Build ES Cluster 08" agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e CLUSTER_NODE=NODE08 -e COMPUTE_INSTANCE_TYPE=${CLUSTER_MACHINE_TYPE} -e SKIP_NVME_DRIVES=true -e env=build -i hosts playbook_restart_cluster_node.yml --vault-password-file=.password
	docker run --rm -d -e PLAYBOOK_NAME="Build ES Cluster 09" agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e CLUSTER_NODE=NODE09 -e COMPUTE_INSTANCE_TYPE=${CLUSTER_MACHINE_TYPE} -e SKIP_NVME_DRIVES=true -e env=build -i hosts playbook_restart_cluster_node.yml --vault-password-file=.password
	docker run --rm -d -e PLAYBOOK_NAME="Build ES Cluster 10" agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e CLUSTER_NODE=NODE10 -e COMPUTE_INSTANCE_TYPE=${CLUSTER_MACHINE_TYPE} -e SKIP_NVME_DRIVES=true -e env=build -i hosts playbook_restart_cluster_node.yml --vault-password-file=.password
	docker run --rm -d -e PLAYBOOK_NAME="Build ES Cluster 11" agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e CLUSTER_NODE=NODE11 -e COMPUTE_INSTANCE_TYPE=${CLUSTER_MACHINE_TYPE} -e SKIP_NVME_DRIVES=true -e env=build -i hosts playbook_restart_cluster_node.yml --vault-password-file=.password
	docker run --rm -d -e PLAYBOOK_NAME="Build ES Cluster 12" agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e CLUSTER_NODE=NODE12 -e COMPUTE_INSTANCE_TYPE=${CLUSTER_MACHINE_TYPE} -e SKIP_NVME_DRIVES=true -e env=build -i hosts playbook_restart_cluster_node.yml --vault-password-file=.password
	docker run --rm -d -e PLAYBOOK_NAME="Build ES Cluster 13" agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e CLUSTER_NODE=NODE13 -e COMPUTE_INSTANCE_TYPE=${CLUSTER_MACHINE_TYPE} -e SKIP_NVME_DRIVES=true -e env=build -i hosts playbook_restart_cluster_node.yml --vault-password-file=.password
	docker run --rm -d -e PLAYBOOK_NAME="Build ES Cluster 14" agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e CLUSTER_NODE=NODE14 -e COMPUTE_INSTANCE_TYPE=${CLUSTER_MACHINE_TYPE} -e SKIP_NVME_DRIVES=true -e env=build -i hosts playbook_restart_cluster_node.yml --vault-password-file=.password
	docker run --rm -d -e PLAYBOOK_NAME="Build ES Cluster 15" agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e CLUSTER_NODE=NODE15 -e COMPUTE_INSTANCE_TYPE=${CLUSTER_MACHINE_TYPE} -e SKIP_NVME_DRIVES=true -e env=build -i hosts playbook_restart_cluster_node.yml --vault-password-file=.password
	docker run --rm -d -e PLAYBOOK_NAME="Build ES Cluster 16" agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e CLUSTER_NODE=NODE16 -e COMPUTE_INSTANCE_TYPE=${CLUSTER_MACHINE_TYPE} -e SKIP_NVME_DRIVES=true -e env=build -i hosts playbook_restart_cluster_node.yml --vault-password-file=.password

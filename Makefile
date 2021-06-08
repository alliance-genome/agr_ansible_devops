REG := 100225593120.dkr.ecr.us-east-1.amazonaws.com
DOCKER_PULL_TAG  := latest
DOCKER_BUILD_TAG := latest

build: pull
	docker build -t agrlocal/agr_ansible_run_unlocked:${DOCKER_BUILD_TAG} --build-arg REG=${REG} --build-arg DOCKER_PULL_TAG=${DOCKER_PULL_TAG} .

registry-docker-login:
ifneq ($(shell echo ${REG} | egrep "ecr\..+\.amazonaws\.com"),)
	@$(eval DOCKER_LOGIN_CMD=docker run --rm -it -v ~/.aws:/root/.aws amazon/aws-cli)
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

openvpn_server:
	docker run -it -e PLAYBOOK_NAME="OpenVPN Server" agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e env=build -e WEBSERVER_INSTANCE_TYPE=t3.small -e SKIP_NVME_DRIVES=true -i hosts custom_playbook_launch_instance_bare.yml --vault-password-file=.password

start_build_intermine_app_server:
	docker run -it -e PLAYBOOK_NAME="Build Intermine App" -e SKIP_NVME_DRIVES=true -e SETUP_NVME_DRIVE=false -e START_GOCD_AGENT=true -e WEBSERVER_INSTANCE_TYPE=m4.xlarge agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e env=build -i hosts custom_playbook_launch_web_instance.yml --vault-password-file=.password

start_stage_intermine_app_server:
	docker run -it -e PLAYBOOK_NAME="Stage Intermine App" -e SKIP_NVME_DRIVES=true -e SETUP_NVME_DRIVE=false -e START_GOCD_AGENT=true -e WEBSERVER_INSTANCE_TYPE=m4.xlarge agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e env=stage -i hosts custom_playbook_launch_web_instance.yml --vault-password-file=.password

start_node1:
	docker run -it -e PLAYBOOK_NAME="Build ES Cluster 1" agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e SKIP_NVME_DRIVES=true -e SETUP_NVME_DRIVE=true -e COMPUTE_INSTANCE_TYPE=m5dn.xlarge -e env=build -i hosts playbook_launch_cluster_node1.yml --vault-password-file=.password
start_node2:
	docker run -it -e PLAYBOOK_NAME="Build ES Cluster 2" agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e SKIP_NVME_DRIVES=true -e SETUP_NVME_DRIVE=true -e COMPUTE_INSTANCE_TYPE=m5dn.xlarge -e env=build -i hosts playbook_launch_cluster_node2.yml --vault-password-file=.password
start_node3:
	docker run -it -e PLAYBOOK_NAME="Build ES Cluster 3" agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e SKIP_NVME_DRIVES=true -e SETUP_NVME_DRIVE=true -e COMPUTE_INSTANCE_TYPE=m5dn.xlarge -e env=build -i hosts playbook_launch_cluster_node3.yml --vault-password-file=.password
start_node4:
	docker run -it -e PLAYBOOK_NAME="Build ES Cluster 4" agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e SKIP_NVME_DRIVES=true -e SETUP_NVME_DRIVE=true -e COMPUTE_INSTANCE_TYPE=m5dn.xlarge -e env=build -i hosts playbook_launch_cluster_node4.yml --vault-password-file=.password
start_node5:
	docker run -it -e PLAYBOOK_NAME="Build ES Cluster 5" agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e SKIP_NVME_DRIVES=true -e SETUP_NVME_DRIVE=true -e COMPUTE_INSTANCE_TYPE=m5dn.xlarge -e env=build -i hosts playbook_launch_cluster_node5.yml --vault-password-file=.password
start_node6:
	docker run -it -e PLAYBOOK_NAME="Build ES Cluster 6" agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e SKIP_NVME_DRIVES=true -e SETUP_NVME_DRIVE=true -e COMPUTE_INSTANCE_TYPE=m5dn.xlarge -e env=build -i hosts playbook_launch_cluster_node6.yml --vault-password-file=.password
start_node7:
	docker run -it -e PLAYBOOK_NAME="Build ES Cluster 7" agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e SKIP_NVME_DRIVES=true -e SETUP_NVME_DRIVE=true -e COMPUTE_INSTANCE_TYPE=m5dn.xlarge -e env=build -i hosts playbook_launch_cluster_node7.yml --vault-password-file=.password
start_node8:
	docker run -it -e PLAYBOOK_NAME="Build ES Cluster 8" agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e SKIP_NVME_DRIVES=true -e SETUP_NVME_DRIVE=true -e COMPUTE_INSTANCE_TYPE=m5dn.xlarge -e env=build -i hosts playbook_launch_cluster_node8.yml --vault-password-file=.password
start_node9:
	docker run -it -e PLAYBOOK_NAME="Build ES Cluster 9" agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e SKIP_NVME_DRIVES=true -e SETUP_NVME_DRIVE=true -e COMPUTE_INSTANCE_TYPE=m5dn.xlarge -e env=build -i hosts playbook_launch_cluster_node9.yml --vault-password-file=.password
start_node10:
	docker run -it -e PLAYBOOK_NAME="Build ES Cluster 10" agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e SKIP_NVME_DRIVES=true -e SETUP_NVME_DRIVE=true -e COMPUTE_INSTANCE_TYPE=m5dn.xlarge -e env=build -i hosts playbook_launch_cluster_node10.yml --vault-password-file=.password
start_node11:
	docker run -it -e PLAYBOOK_NAME="Build ES Cluster 11" agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e SKIP_NVME_DRIVES=true -e SETUP_NVME_DRIVE=true -e COMPUTE_INSTANCE_TYPE=m5dn.xlarge -e env=build -i hosts playbook_launch_cluster_node11.yml --vault-password-file=.password
start_node12:
	docker run -it -e PLAYBOOK_NAME="Build ES Cluster 12" agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e SKIP_NVME_DRIVES=true -e SETUP_NVME_DRIVE=true -e COMPUTE_INSTANCE_TYPE=m5dn.xlarge -e env=build -i hosts playbook_launch_cluster_node12.yml --vault-password-file=.password
start_node13:
	docker run -it -e PLAYBOOK_NAME="Build ES Cluster 13" agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e SKIP_NVME_DRIVES=true -e SETUP_NVME_DRIVE=true -e COMPUTE_INSTANCE_TYPE=m5dn.xlarge -e env=build -i hosts playbook_launch_cluster_node13.yml --vault-password-file=.password
start_node14:
	docker run -it -e PLAYBOOK_NAME="Build ES Cluster 14" agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e SKIP_NVME_DRIVES=true -e SETUP_NVME_DRIVE=true -e COMPUTE_INSTANCE_TYPE=m5dn.xlarge -e env=build -i hosts playbook_launch_cluster_node14.yml --vault-password-file=.password
start_node15:
	docker run -it -e PLAYBOOK_NAME="Build ES Cluster 15" agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e SKIP_NVME_DRIVES=true -e SETUP_NVME_DRIVE=true -e COMPUTE_INSTANCE_TYPE=m5dn.xlarge -e env=build -i hosts playbook_launch_cluster_node15.yml --vault-password-file=.password
start_node16:
	docker run -it -e PLAYBOOK_NAME="Build ES Cluster 16" agrlocal/agr_ansible_run_unlocked:latest ansible-playbook -e SKIP_NVME_DRIVES=true -e SETUP_NVME_DRIVE=true -e COMPUTE_INSTANCE_TYPE=m5dn.xlarge -e env=build -i hosts playbook_launch_cluster_node16.yml --vault-password-file=.password

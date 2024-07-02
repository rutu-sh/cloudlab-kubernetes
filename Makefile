CL_DIR=${CURDIR}/.cloudlab
TOOLS_SRC_DIR=${CURDIR}/setup/cloudlab-tools
KUBE_CONFIG_SRC="~/.kube/config"
KUBE_CONFIG_DEST=${CL_DIR}/kubeconfig

# Node Mappings 
MASTER_NODE=NODE_0
WORKER_NODE_1=NODE_1
WORKER_NODE_2=NODE_2


.PHONY: all
all:
	$(MAKE) setup-3n-k8s-cluster 
	
include setup/cloudlab-tools/cloudlab_tools.mk


display-node-names:
	@echo "Master Node: ${MASTER_NODE_NAME}"
	@echo "Worker Node 1: ${WORKER_NODE_1_NAME}"
	@echo "Worker Node 2: ${WORKER_NODE_2_NAME}"


update-cl-tools:
	@echo "Updating cloudlab tools..."
	cd ${CURDIR}/setup/cloudlab-tools && git pull origin && cd ../.. && \
	echo "Cloudlab tools updated"


setup-master-node:
	@echo "Setting up master node..."
	$(MAKE) cl-sync-code NODE=${MASTER_NODE} && \
	$(MAKE) cl-run-cmd NODE=${MASTER_NODE} COMMAND="cd ${REMOTE_DIR}/cloudlab-kubernetes/setup/cloudlab-tools/tools/kubernetes && make setup-master-node"
	$(MAKE) cl-run-cmd NODE=${MASTER_NODE} COMMAND="sudo kubeadm token create --print-join-command" > ${CL_DIR}/join-command
	sed -i '' '1,2d' ${CL_DIR}/join-command && \
	$(MAKE) copy-kube-config && \
	echo "Master node setup complete!"


setup-worker-node-1:
	@echo "Setting up worker node 1..."
	$(MAKE) cl-sync-code NODE=${WORKER_NODE_1} && \
	$(MAKE) cl-run-cmd NODE=${WORKER_NODE_1} COMMAND="cd ${REMOTE_DIR}/cloudlab-kubernetes/setup/cloudlab-tools/tools/kubernetes && make setup-worker-node"
	$(MAKE) cl-run-cmd NODE=${WORKER_NODE_1} COMMAND="sudo $(shell cat ${CL_DIR}/join-command) --cri-socket=unix:///var/run/cri-dockerd.sock --node-name worker1" && \
	echo "Worker node 1 setup complete!"


setup-worker-node-2:
	@echo "Setting up worker node 2..."
	$(MAKE) cl-sync-code NODE=${WORKER_NODE_2} && \
	$(MAKE) cl-run-cmd NODE=${WORKER_NODE_2} COMMAND="cd ${REMOTE_DIR}/cloudlab-kubernetes/setup/cloudlab-tools/tools/kubernetes && make setup-worker-node"
	$(MAKE) cl-run-cmd NODE=${WORKER_NODE_2} COMMAND="sudo $(shell cat ${CL_DIR}/join-command) --cri-socket=unix:///var/run/cri-dockerd.sock --node-name worker2" 
	echo "Worker node 2 setup complete!"


copy-kube-config:
	@echo "Copying kubeconfig..."
	$(MAKE) cl-scp-from-host NODE=${MASTER_NODE} SCP_SRC=${KUBE_CONFIG_SRC} SCP_DEST=${KUBE_CONFIG_DEST} && \
	echo "Kubeconfig copied to ${KUBE_CONFIG_DEST}"
	echo "Overwrite ~/.kube/config with ${KUBE_CONFIG_DEST} to access the cluster with kubectl?(y/n)"
	@read response && \
	if [ "$$response" = "y" ]; then \
		cp ${KUBE_CONFIG_DEST} ~/.kube/config && \
		echo "Kubeconfig copied to ~/.kube/config"; \
	fi


setup-3n-k8s-cluster:
	@echo "Setting up 3-node k8s cluster..."
	$(MAKE) setup-master-node
	$(MAKE) setup-worker-node-1
	$(MAKE) setup-worker-node-2 
	@echo "3-node k8s cluster setup complete!"


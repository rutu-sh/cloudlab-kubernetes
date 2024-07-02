# cloudlab-kubernetes

![created with https://socialify.git.ci/](./docs/assets/cloudlab-kubernetes.svg)

This repository contains the necessary code to setup a 3 Node Kubernetes Cluster on CloudLab. It uses the [rutu-sh/cloudlab-tools](https://github.com/rutu-sh/cloudlab-tools) repository to setup the cluster. 


## Usage

1. Clone the repository
```bash
git clone --recurse-submodules https://github.com/rutu-sh/cloudlab-kubernetes.git
```

2. [Optional] Update cloudlab-tools submodule
```bash
make update-cl-tools
```

3. Instantiate an experiment on CloudLab using the profile [rutu-k8s-3n](https://www.cloudlab.us/p/GWCloudLab/rutu-k8s-3n)

4. Setup CloudLab configurations. 

```bash
make cl-setup
```

This will create a directory `.cloudlab` in the root of the repository. This directory contains the configuration files for the CloudLab experiment. Within this directory, there will be a `cloudlab_config.mk` file. Add your CloudLab username, ssh-key path, and the node IPs in the file. General convention is: `NODE_0` is the master node, and `NODE_1` and `NODE_2` are worker nodes. If you're using different names for the nodes (other than `NODE_0`, `NODE_1`, `NODE_2`), make sure to update the values for [Makefile](./Makefile) variables `MASTER_NODE`, `WORKER_NODE_1`, and `WORKER_NODE_2` accordingly.

5. Setup the Kubernetes Cluster

```bash
make
```

This step will setup the Kubernetes cluster on the CloudLab nodes. It will copy the `~/.kube/config` file from the master node to `./.cloudlab/kubeconfig` locally. And it will ask you if you want to overwrite the `~/.kube/config` file on your local machine with the one from the master node, choose `y` if you want to use `kubectl` from your local machine to interact with the cluster.

<!-- TODO: Add teardown commands -->
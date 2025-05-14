# VDK-Template
VDK Template Repository

## Requirements
The VDK is designed to run inside a devbox shell.  You will need a Linux-based system with Docker installed to run the VDK. You can download and install Docker from [Docker's official website](https://www.docker.com/products/docker-desktop). (On Windows, you can use Docker Desktop for Windows and WSL)
DevBox will automatically configure your shell environment for you and download the latest version of the VDK CLI.

## Installation/Setup
Setting up a Vega development environment can be complex, but with this template repository, you can quickly get started. Follow these steps to set up your development environment:
1. Clone the repository to your local machine using Git: (ex. `git clone https://github.com/ArchetypicalSoftware/VDK-Template`)
2. Switch to the cloned repository directory: (ex. `cd VDK-Template`)
3. Run command `devbox shell` to initialize the DevBox environment.

## Usage
For each development session, simply switch to your repository and start a devbox shell again with the command `devbox shell`. 

### Vega CLI Commands

#### vega create cluster
Description: Create a Vega development cluster

Usage: vega create cluster [options]

Options:

  -n, --Name <Name>                            The name of the kind cluster to create. [default: vdk]

  -c, --ControlPlaneNodes <ControlPlaneNodes>  The number of control plane nodes in the cluster. [default: 1]

  -w, --Workers <Workers>                      The number of worker nodes in the cluster. [default: 2]

  -k, --KubeVersion <KubeVersion>              The kubernetes api version. [default: 1.29]

  -?, -h, --help                               Show help and usage information

__Examples__
```
    # Create a default cluster with 1 control plane node and 2 worker nodes named vdk
    vega create cluster
    
    # Create a cluster with 2 control plane nodes and 3 worker nodes named mycluster with kubernetes version 1.32

    vega create cluster -n mycluster -c 2 -w 3 -k 1.32
```

#### vega create registry
Description: Create Vega VDK Container Registry (A docker registry accessible from your local machine and your clusters - i.e. you can push test images here and pull them into your local cluster)

Usage: vega create registry [options]

Options:

  -?, -h, --help  Show help and usage information

> This command is automatically run during init and should not need to be run again unless something becomes corrupted on your environment.

#### vega create proxy
Description: Create a Vega VDK Proxy Container (Enables basic connection to resources in your cluster(s))

Usage: vega create proxy [options]

Options:

  -?, -h, --help  Show help and usage information

> This command is automatically run during init and should not need to be run again unless something becomes corrupted on your environment.

#### vega remove cluster
Description: Remove a Vega development cluster (Remove a cluster you are no longer using or has become "dirty" to allow you to create a fresh environment)

Usage: vega remove cluster [options]

Options:

  -n, --Name <Name>  The name of the cluster to remove [default: vdk]

  -?, -h, --help     Show help and usage information

__Examples__
```
    # Remove default cluster (named "vdk")
    vega remove cluster

    # Remove a cluster named "sample"
    vega remove cluster -n sample
```

#### vega remove registry
Description:  Remove Vega VDK Container Registry

Usage: vega remove registry [options]

Options:

  -?, -h, --help  Show help and usage information

> Not generally used, unless your environment has been corrupted.

#### vega remove proxy
Description: Remove the Vega VDK Proxy

Usage: vega remove proxy [options]

Options:
  
  -?, -h, --help  Show help and usage information

> Not generally used, unless your environment has been corrupted.


#### vega list clusters
Description: List Vega development clusters

Usage: vega list clusters [options]

Options:

  -?, -h, --help  Show help and usage information

#### vega list kubernetes-versions
Description: List available kubernetes versions

Usage: vega list kubernetes-versions [options]

Options:

  -?, -h, --help  Show help and usage information

#### vega init
Description: Initialize environment.  This is generally only run once.  It will automatically create a new cluster with the default kubernetes version and settings, configure the vega proxy and set up the vega registry locally.

Usage: vega init [options]

Options:

  -?, -h, --help  Show help and usage information


#### vega update kind-version-info
Description: Update kind version info (Maps kind and Kubernetes versions/enables new releases of kubernetes in vega)

Usage: vega update kind-version-info [options]

Options:

  -?, -h, --help  Show help and usage information

> This command is generally not required to be run by developers as it is automatically performed by the vega cli periodically.  
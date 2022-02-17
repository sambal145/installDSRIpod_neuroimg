# Install essential dependencies and neuroimaging softwares on Maastricht University DSRI cluster

Maastricht University Data Science Research Infrastructure (DSRI) is an OKD 4.6 cluster, the open source version of OpenShift, using RedHat Ceph Storage.
The DSRI provides a graphical user interface on top of the Kubernetes containers orchestration to easily deploy and manage workspaces and services.
Usage documentation can be found at: https://maastrichtu-ids.github.io/dsri-documentation/docs/ 

The present scripts are meant to build a neuroimaging friendly environment on a pod with an Ubuntu 20.04 with web User Interface. 
They require minimal user interaction and automatize the installation of: 
* [Essential dependencies](#install_essentials.sh)
* [Specific neuroimaging softwares](#install_softwares.sh)

## Requirements

A pod running Ubuntu 20.04 with web UI needs to be created.
At least 100GB need to be allocated to a pod's container to allow sufficient storage space for downloads and installations 
(e.g. allocate 100GB to /root, or create a container /installers). 

## install_essentials.sh

This script installs essential packages that are
* generally needed for your system 
		(e.g. cat, nano, unzip, tar, git, etc.)
* necessary to install the neuroimaging softwares specified by [install_softwares.sh](#install_softwares.sh)

No user interaction is required for this step. The script can simply be launched as follow: 

```
$ sh /<location where script has been saved>/install_essentials.sh
```
## install_softwares.sh

This script installs neuroimaging softwares including:
* FSL (https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSL)
* FSL ICA FIX (https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FIX)
* FREESURFER (https://surfer.nmr.mgh.harvard.edu/fswiki)
* ANTs (https://github.com/ANTsX/ANTs)
* HUMAN CONNECTOME PROJECT PIPELINES (https://github.com/Washington-University/HCPpipelines)

The script can be launched as follow:

```
$ bash /<location where script has been saved>/install_softwares.sh --fsl=ON --fslfix=ON --freesurfer=ON --ants=OFF --hcppipelines=OFF --pathedits=ON
```
The exact usage can be seen in script, but here a few notes for the user: 
* Make sure to have a container with sufficient storage running on your pod
* EDIT the script to speficy: 
  * path to folder where you are downloading .tar or .zip files for installation
  * path to folder where you are going to install (RECOMMENDED: let this be under /root)
* Specify your choice for each software (whether to install -ON, or not to install -OFF)
* If installing Matlab Runtime Compiler (as part of FSL ICA FIX), the user is required to interact with a GUI to proceed with the installation. Following instructions, the GUI closes and the script continues without any other required interaction
* Setting the option `--pathedits=ON` allows the script to modify the .bashrc file to set environment variables and edit the $PATH. This is the recommended choice. However, the user is invited to check the .bashrc file at the end of the installation process. Close the terminal window and open a new session to apply the changes



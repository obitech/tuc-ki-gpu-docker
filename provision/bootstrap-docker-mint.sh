#!/usr/bin env bash
set -e
set -o pipefail


RELEASE=xenial
SUPPORTED=(xenial trusty)
FINGERPRINT=0EBFCD88
COMPOSE_VERSION=1.19.0
UNATTENDED=false

usage() {
    echo "bootstrap-docker-mint.sh - Bootstrap Docker on Linux Mint
    
Usage:
    $ bash bootstrap-docker-mint.sh [OPTIONS]

Options:
    -h                      Display this help
    -r <release>            Specify the Ubuntu release package base necessary for Linux Mint (default: ${RELEASE})
    -f <fingerprint>        Specify Dockers GPG key fingerprint (default: ${FINGERPRINT})
    -v <version>            Specify docker-compose version to be installed. (default: ${COMPOSE_VERSION}, supported: ${SUPPORTED[@]})
    -u                      Unattended installation, does not prompt user.

Notes:
    In order to find out which release name to pass to the -r flag, do the following:
        1. Run lsb_release -cs to find out the short codename for your Mint release
        2. Go to https://linuxmint.com/download_all.php and find the fitting Ubuntu package base for your Mint codename

    For more information visit https://docs.docker.com/install/#docker-ce"
}

########################################################################
###################### CHECKING PASSED PARAMETERS ######################
########################################################################

while getopts ":hur:f:v:" o; do
    case "${o}" in
        h )
            usage
            exit 0
            ;;
        r ) 
            # Check if passed release is supported
            if [[ " ${SUPPORTED[@]} " =~ " ${OPTARG} " ]]; then
                RELEASE=${OPTARG}
            else
                echo "Error - ${OPTARG} is not supported (${SUPPORTED[@]})."
                exit 1
            fi
            ;;
        f )
            FINGERPRINT=${OPTARG}
            ;;
        v ) COMPOSE_VERSION=${OPTARG}
            ;;
        u )
            UNATTENDED=true
            ;;
        \? )
            echo "Error - Unknown option -${OPTARG}"
            usage
            exit 1
            ;;
        : )
            echo "Error - Missing parameter for -${OPTARG}"
            usage
            exit 1
            ;;
        * )
            echo "Error - Unimplemented option -${OPTARG}"
            usage
            exit 1
            ;;
    esac
done
shift $((${OPTIND} - 1))

if [[ "$UNATTENDED" == false ]]; then
    echo "Installing Docker for release package $RELEASE"
    read -p "Continue (Y/n)? " choice
    case "$choice" in 
      n|N|no|No )
        echo "Aborting."
        exit 1
        ;; 
      * )
        ;;
    esac
fi

#####################################################################
###################### STARTING DOCKER INSTALL ######################
#####################################################################

echo "Removing deprecated Docker versions..."
sudo apt-get remove docker docker-engine docker.io -y || true

echo "Updating package index..."
sudo apt-get update -y

echo "Installing additional packages for $RELEASE..."
if [[ "$RELEASE" == "xenial" ]]; then
    sudo apt-get install -y \
        apt-transport-https \
        software-properties-common \
        ca-certificates
else
    sudo apt-get install -y \
        linux-image-extra-$(uname -r) \
        linux-image-extra-virtual
fi
sudo apt-get install -y \
    curl \
    bash-completion

echo "Adding docker's official GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo apt-key add -

echo "Verifying GPG fingerprint ${FINGERPRINT} with 9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88..."
sudo apt-key fingerprint ${FINGERPRINT}

if [[ "$UNATTENDED" == false ]]; then
    echo "Please verify if the information displayed above confirms the fingerprint identity belonging to Docker Release (CE deb) <docker@docker.com>"
    read -p "Confirm (Y/n)? " choice
    case "$choice" in 
      n|N|no|No )
        echo "Aborting."
        exit 1
        ;; 
      * )
        ;;
    esac
fi

echo "Adding docker repository..."
sudo add-apt-repository \
 "deb [arch=amd64] https://download.docker.com/linux/ubuntu ${RELEASE} stable"

echo "Updating package index..."
sudo apt-get update -y

echo "Installing docker from package manager..."
sudo apt-get install docker-ce -y

if [[ "$RELEASE" == "xenial" ]]; then
    echo "Adding docker to systemd..."
    sudo systemctl enable docker
fi

echo "Downloading docker-compose ${COMPOSE_VERSION}..."
sudo curl -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "Adding docker-compose to bash-completion..."
sudo curl -L https://raw.githubusercontent.com/docker/compose/${COMPOSE_VERSION}/contrib/completion/bash/docker-compose -o /usr/share/bash-completion/completions/docker-compose

echo "Setup completed."
exit 0
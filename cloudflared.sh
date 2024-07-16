#!/bin/bash

# Define installation functions for each OS

# Instructions per OS taken from here https://pkg.cloudflare.com/index.html
install_debian_ubuntu() {
    echo "Installing on Debian/Ubuntu..."
    
    # Determine the distribution name (e.g., buster, focal)
    distro_name=$(lsb_release -cs)
    
    # Check if the release file is available
    release_url="https://pkg.cloudflare.com/cloudflared/${distro_name}/main/binary-amd64/Packages"
    if ! curl --output /dev/null --silent --head --fail "$release_url"; then
        echo "Release file for ${distro_name} not found, using 'jammy' instead"
        distro_name="jammy"
    fi
    
    # Add Cloudflare GPG key
    sudo mkdir -p --mode=0755 /usr/share/keyrings
    curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
    
    # Add Cloudflare repository to apt sources
    echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared $distro_name main" | sudo tee /etc/apt/sources.list.d/cloudflared.list
    
    # Install cloudflared
    sudo apt-get update && sudo apt-get install cloudflared -y
}

install_amazon_linux() {
    echo "Installing on Amazon Linux..."
    
    curl -fsSl https://pkg.cloudflare.com/cloudflared-ascii.repo | sudo tee /etc/yum.repos.d/cloudflared-ascii.repo

    #update repo
    sudo yum update

    # install cloudflared
    sudo yum install cloudflared -y
}

install_rhel() {
    echo "Installing on RHEL..."
    
    # Add cloudflared.repo to /etc/yum.repos.d/ 
    curl -fsSl https://pkg.cloudflare.com/cloudflared-ascii.repo | sudo tee /etc/yum.repos.d/cloudflared.repo

    #update repo
    sudo yum update

    # install cloudflared
    sudo yum install cloudflared -y
}

install_centos_7() {
    echo "Installing on CentOS 7..."
    
    # Install yum-utils
    sudo yum install yum-utils
    
    # Add cloudflared.repo to config-manager
    sudo yum-config-manager --add-repo https://pkg.cloudflare.com/cloudflared-ascii.repo
    
    # Install cloudflared
    sudo yum install cloudflared -y
}

install_centos_8_stream() {
    echo "Installing on CentOS 8/Stream..."
    
    # Add cloudflared.repo to config-manager
    sudo dnf config-manager --add-repo https://pkg.cloudflare.com/cloudflared-ascii.repo
    
    # Install cloudflared
    sudo dnf install cloudflared -y
}

# check if cloudflared is already available in $PATH
if command -v cloudflared &> /dev/null; then
    echo "cloudflared is already installed"
    exit 0
fi

# Determine OS and version
if [ -f /etc/os-release ]; then
    . /etc/os-release
    case $ID in
        amzn)
            install_amazon_linux
            ;;
        debian|ubuntu)
            install_debian_ubuntu
            ;;
        rhel)
            install_rhel
            ;;
        centos)
            if [ -f /etc/centos-release ]; then
                if grep -q "CentOS Stream" /etc/centos-release; then
                    install_centos_8_stream
                else
                    centos_version=$(cat /etc/centos-release | awk '{print $4}' | cut -d. -f1)
                    case $centos_version in
                        7)
                            install_centos_7
                            ;;
                        *)
                            echo "Unsupported CentOS version: $centos_version"
                            exit 1
                            ;;
                    esac
                fi
            else
                echo "Cannot determine CentOS version"
                exit 1
            fi
            ;;
        *)
            echo "Unsupported OS: $ID"
            exit 1
            ;;
    esac
else
    echo "Cannot determine OS"
    exit 1
fi

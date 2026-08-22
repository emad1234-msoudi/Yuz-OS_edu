#!/usr/bin/env bash

########## Copyright C 2026 MIT Emad-ms ##########

# project: yuz-os runtime module
# project git : https://github.com/emad1234-msoudi/Yuz-OS_edu

# /opt/yuz-os/scripts/apt/apt.sh

# build time module for mange apt and packageing.

########### setup environment ##########

set -Eeuo pipefail

#source "../../bootstrap.sh" #-> this source just for development

export DEBIAN_FRONTEND=noninteractive

########## Variables #########

DEB_REPO_DIR="${DATA_DIR}/deb-packages"

########## func ##########

#-> check neaded to run
apt_system_check()
{
    #-> checking root
    if [[ ! "$EUID" -eq 0 ]]
    then
        die "Please run this with sudo."
    fi

    return 0
}

#-> Updata apt and system func
apt_update()
{
    info "Updating package lists..."

    if apt-get update >/dev/null 2>&1; then
        ok "System is updated"
    else
        error "Failed to update package lists."
        return 1
    fi

    return 0
}

#-> install packages from local deb packages
apt_install_local()
{
    ui_title_small "$BLUE" "Local packages :"

    #-> Checking repo dir exists
    [ -d "$DEB_REPO_DIR" ] ||\
    {
        warn "Repo dir : ${DEB_REPO_DIR} , not exist . nothing to install."
        return 0
    }

    #-> Read all deb file in repo
    set -- "$DEB_REPO_DIR"/*.deb
    [ -e "$1" ] ||\
    {
        warn "Not available any packages , nothing to install form repo : ${DEB_REPO_DIR}."
        return 0
    }

    #-> install packages
    info "installing packages..."

    if apt-get install -y --no-install-recommends "$@"
    then
        ok "All packages installed."
        info "installed packages : $*"
    else
        error "Failed to install packages : $*."
        return 1
    fi

	return 0
}

########## main apt  ##########
#-> main for load apt funcs

main_apt()
{
    apt_system_check    || return 1
    apt_update          || return 1
    apt_install_local   || return 1

    return 0
}

#main_apt "$@"

########## end ##########

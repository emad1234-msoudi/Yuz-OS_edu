#!/usr/bin/env bash

########## Copyright C 2026 MIT Emad-ms ##########

# project: yuz-os builder framework
# project git : https://github.com/emad1234-msoudi/Yuz-OS.git

# setup.sh
# script for setup project builder 

########### setup environment ##########
#--> note :

# tihs variable just for bootstarp
# all variable fully setup in "framework/env.sh" 

set -Eeuo pipefail # set terminal mod

SETUP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SETUP_ROOT"

[[ -f "./scripts/bootstrap.sh" ]] || { 
    echo "[ ERROR ] project bootstrap file not found !"
    return 1
}

source "./scripts/bootstrap.sh"

########## main setup ##########
#-> main for load setup func

main_setup()
{
    #-> setup system to lunch
    ui_banner_project "$YELLOW"
    
    ui_title_small "$BLUE" "cheking system"

    if ! check_root 
    then 
        exec sudo -E bash "$0" "$@" 
    fi
    
    check_system_arch
    check_system_dist
    
    check_network || return 0
    package_update || return 0
    check_disk_space

    #-> setup module to lunch 

    #Run_module "config live build" main_build_set
    #Run_module "flatpak build repo" main_flatpak
    #Run_module "build iso file" main_build
}

main_setup "$@"
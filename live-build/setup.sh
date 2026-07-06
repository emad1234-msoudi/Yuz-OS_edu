#!/usr/bin/env bash

########## Copyright C 2026 MIT Emad-ms ##########

# project: yuz-os builder framework
# project git : https://github.com/emad1234-msoudi/Yuz-OS_edu

# setup.sh
# script for setup project builder 

########### setup environment ##########
#--> note :

# tihs variable just for setup
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
    #### setup system to launch ####
    ui_banner_project "$YELLOW"
    
    #-> checking system
    ui_title_small "$BLUE" "Checking system"

    if ! check_root 
    then 
        exec sudo -E bash "$0" "$@" 
    fi
    
    check_system_arch
    check_system_dist
    check_disk_space

    ui_title_small_close "$BLUE" "Checking system completed"

    #-> Preparing environment

    ui_title_small "$BLUE" "Preparing environment"

    if ! check_network  ; then return 0 ; fi
    if ! package_update ; then return 0 ; fi
    if ! install_require "git" "curl" "wget" ; then die "Required apps not installed." ; fi

    ui_title_small_close "$BLUE" "Environment setup completed"

    # go and run all project module
    run_pipeline

    success "Setup completed ."
}

main_setup "$@"

########## end ##########

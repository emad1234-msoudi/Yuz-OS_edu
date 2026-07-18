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
    ui_banner_project "$RED"
    
    # go and run all project module
    run_pipeline

    success "Setup completed ."
}

main_setup "$@"

########## end ##########

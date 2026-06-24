#!/bin/bash

########## Copyright C 2026 MIT Emad-ms ##########

# project: yuz-os builder
# project git : https://github.com/emad1234-msoudi/Yuz-OS.git

########## set terminal ##########

set -euo pipefail # set termainl mod

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export PROJECT_ROOT

cd "$PROJECT_ROOT"
source "$PROJECT_ROOT/scripts/lib/terminal-set.sh" # import trminal lib

########### var ##########

module_file="$PROJECT_ROOT/scripts/module.list"
module_list=""

need_gb=15

########### set script func ##########

#-> titel script // use patorjk.com for make patern
ui_titel()
{
	clear

    echo " █████ █████                                                      █████                 ███  ████      █████"
    echo "░░███ ░░███                                                      ░░███                 ░░░  ░░███     ░░███ "
    echo " ░░███ ███   █████ ████  █████████             ██████   █████     ░███████  █████ ████ ████  ░███   ███████ "
    echo "  ░░█████   ░░███ ░███  ░█░░░░███  ██████████ ███░░███ ███░░      ░███░░███░░███ ░███ ░░███  ░███  ███░░███ "
    echo "   ░░███     ░███ ░███  ░   ███░  ░░░░░░░░░░ ░███ ░███░░█████     ░███ ░███ ░███ ░███  ░███  ░███ ░███ ░███ "
    echo "    ░███     ░███ ░███    ███░   █           ░███ ░███ ░░░░███    ░███ ░███ ░███ ░███  ░███  ░███ ░███ ░███ "
    echo "    █████    ░░████████  █████████           ░░██████  ██████     ████████  ░░████████ █████ █████░░████████"
    echo "   ░░░░░      ░░░░░░░░  ░░░░░░░░░             ░░░░░░  ░░░░░░     ░░░░░░░░    ░░░░░░░░ ░░░░░ ░░░░░  ░░░░░░░░ "
    echo "                                                                                                            "
    echo "                                                                                                            "
    echo "                                                                                                            "
    echo
}

#-> chek system root arch distro
check_system()
{
	# arch chek
	if [ "$(uname -m)" == "x86_64" ]
	then
		ok "your system is $(uname -m)."
	else
		die "this script only writed for 64bit system , but your system is $(arch)."
	fi

	# distro chek

	if ! source /etc/os-release 2>/dev/null 2>&1 
    then
        die "system source not found !"
    fi

	if [[ "$ID" == "debian" && "$VERSION_ID" == "13"* ]]
	then
		ok "your system is $ID $VERSION_ID."
	else
		die "this script only writed for Debian 13 (Trixie) , but your system is $ID $VERSION_ID."
	fi

    # update system
    
    #if apt update >/dev/null 2>&1
    #then
    #    ok "your system is updated"
    #else
    #    die "updating failed , chek your connection"
    #fi

    # install requir packages
	
    install_require "wget" "curl" "git"

    # check system free space

    
    if check_disk_space "$need_gb"
    then
        ok "yuor disk has free space "
    else
        warn "your system don't have enough free space"
        warn "for build this project nead $need_gb free scpae !"
    fi
}

#-> Chek script files are exist or aren't 
check_module()
{
    [[ ! -f "$module_file" ]] && die "module_file not found"
    while IFS= read -r module_list    
    do

        #-> skip line if started whith "#" or "space" 
        [[ -z "$module_list" ]] && continue
        [[ "$module_list" =~ ^# ]] && continue

        local file="$PROJECT_ROOT/scripts/${module_list#/}"

        #-> source module if exist
        [[ -f "$file" ]] || die "$module_list not found !"
        ok "$module_list exist"
        
        [[ -r "$file" ]] || die "syntax error in $module_list"

        # shellcheck source=/dev/null
        source "$file" || die "failed to source $module_list module"
    
    done < "$module_file"
    
    #declare -F | grep main
}

#-> Fix File Permissions
fix_perms()
{
    # directories
    find "$PROJECT_ROOT/config" -type d -exec chmod 755 {} +

    # files
    find "$PROJECT_ROOT/config" -type f -exec chmod 644 {} +

    # executables
    find "$PROJECT_ROOT/config" -type f -exec sh -c '
        for f; do
            head -n 1 "$f" | grep -q "^#!" && chmod 755 "$f"
        done
    ' sh {} +
}

########## main setup ##########
#-> main for load setup func

main_setup()
{
    #-> setup system to lunch
    ui_titel

    check_root # check root
    Run "Check system" "$debug_check" check_system
    Run "Cheking project modules" "$debug_check" check_module
    #Run "Fix permission" "$debug_check" fix_perms

    #-> setup module to lunch 

    echo "  __                     __         __                "
    echo " |  | .--------.-----.--|  |.--.--.|  |.-----.-----.  "
    echo " |  | |        |  _  |  _  ||  |  ||  ||  -__|__ --|  "
    echo " |  | |__|__|__|_____|_____||_____||__||_____|_____|  "
    echo " |  |                                                 "
    echo " |  |   setup project modules                         "
    echo "  ¯¯                                                  "
    echo ""

    Run_module "config live build" main_build_set
    Run_module "flatpak build repo" main_flatpak
    Run_module "build iso file" main_build
}

main_setup "$@"

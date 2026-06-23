#!/bin/bash

########## Copyright C 2026 MIT Emad-ms ##########

# project: yuz-os builder
# project git : https://github.com/emad1234-msoudi/Yuz-OS.git

##### this script made for build os iso #####

######### setup ##########

#set -eEuo pipefail # set terminal mod 


source "$PROJECT_ROOT/scripts/lib/terminal-set.sh" # import terminal lib

check_root #chek system root    

########## var ##########

need_gb=15

########## set script func ##########
#-> chek build require
build_check()
{
	# install neaded packages
	install_require "live-build" "squashfs-tools" "xorriso" "debootstrap"
	
	# chek system free space
	if ! check_disk_space "$need_gb"
    then
        warn "your system don't have enough free space"
        die "for build this project nead $need_gb free scpae ."
    fi
}

#-> clean old make
build_clean()
{
	if ask "do you want to start clean old release ?"
	then
		if ls "$PROJECT_ROOT/"*.iso >/dev/null 2>&1
       	then
			info "backuping old iso"
			mkdir -p "$PROJECT_ROOT"/Release_old
			mv "$PROJECT_ROOT"/*.iso "$PROJECT_ROOT"/Release_old
			success "Old ISO files backed up to Release_old"
		fi
		lb clean --all
	else
		warn "old build files were not removed."
	fi

	Run "clean old config file " "$debug_empty" \
		rm -rf "$PROJECT_ROOT"/config/{"binary","bootstrap","chroot","common","source"}
}

#-> set config
build_config()
{
	Run "" "$debug_empty" bash "$PROJECT_ROOT/scripts/build/realse-config.sh"
}

#-> start build
build_start()
{
	if ask "do you want to start build ?"
	then
		clear
		echo "                               __                                    "
		echo "    _           _         _   |  |  build started !                  "
		echo "___| |_ ___ ___| |_ ___ _| |  |  |                                   "
		echo "|_ -|  _| .'|  _|  _| -_| . |  |__|  Please wait ...                  "
		echo "|___|_| |__,|_| |_| |___|___|  |__|  This will take about a few hours."
        echo ""

		info "OvO"
		lb build
	else
        	info  "see you soon agian!"
        	die ">-<"
	fi
}


########## main build ##########
#-> main for load build func

main_build_set()
{
	Run "Cheking build require" "$debug_build" build_check
	Run "Clean old make" "$debug_build" build_clean
	Run "Config build path" "$debug_build" build_config
}

main_build()
{
	Run "Build distro" "$debug_build" build_start
}

#main_build_set "$@"
#main_build "$@"
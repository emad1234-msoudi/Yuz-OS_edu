#!/bin/bash

########## Copyright C 2026 MIT Emad-ms ##########

# project: yuz-os builder
# project git : https://github.com/emad1234-msoudi/Yuz-OS.git

########## set terminal ##########

#set -eEuo pipefail

########## system var ##########

#-> system color // i use ai for find color

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

#-> debug

: "${PROJECT_ROOT:?PROJECT_ROOT is not set}"

debug_dir="$PROJECT_ROOT/log/$(date '+%Y-%m-%d_%H-%M-%S')"
#mkdir -p "$debug_dir"

debug_empty="/dev/null"

debug_check="$debug_dir/chek_system.log"
debug_build="$debug_dir/build.log"
debug_flatpak="$debug_dir/flatpak.log"

export debug_dir debug_empty debug_check debug_build debug_flatpak 

#->local var

yuz_clone="$PROJECT_ROOT/config/includes.chroot/opt/yuz_os"
mkdir -p "$yuz_clone"

########## set script func ##########

#-> show message func // ai for how to set color

info()    { printf "%b\n" "${BLUE}[ INFO ]${NC} $*"; }
success() { printf "%b\n" "${GREEN}[ SUCCESS ]${NC} $*"; }
ok()	  { printf "%b\n" "${GREEN}[ OK ]${NC} $*"; }
warn()    { printf "%b\n" "${YELLOW}[ WARN ]${NC} $*"; }
error()   { printf "%b\n" "${RED}[ ERROR ]${NC} $*" >&2; }
die()     { error "$*"; exit 1 ; }

ask()
{
	local ask_question="$1 [y/n] "
	local answer=""

	read  -r -p  "$(printf "%b\n" "${YELLOW}[ ASK ]${NC} $ask_question")"  answer
	answer="${answer,,}"

	if [[ "$answer" = "y" || "$answer" = "yes" ]]
	then
		return 0 	
	else
		return 1
	fi  
}

#-> run my code // ai for what is this && make my run proJect beter
Run()
{
	# run argument 
	local run_event="$1"
	local run_debugfile="$2"
	shift 2

	#run command and save debug
	info "$run_event ..."

	if "$@"   
 	then
		success "$run_event finished !"
	else
		die "oh! $run_event failed. see log : $run_debugfile"
	fi

	echo
}

#-> run my project modules 
Run_module()
{
	local module_name="$1"
	local module_func="$2"
	shift 2

	if ask "do you want run $module_name ?"
	then
		"$module_func"
	else
		ok "skip run $module_name"
	fi 
}

#-> chek root system
check_root()
{
	# root chek
	if [ "$EUID" -eq 0 ]
	then
		ok "your system is root"
	else
		error "nead run this with sudo"
		exec sudo -E bash "$0" # "$@"
		exit 	
    fi
}

#-> func for chek free space
check_disk_space()
{
    local need_gb="$1"

    local avail_kb
    avail_kb=$(df -Pk "$PROJECT_ROOT" | awk 'NR==2 {print $4}')

    local need_kb=$((need_gb * 1024 * 1024))

    if (( avail_kb >= need_kb ))
    then
		return 0
	else
		return 1
	fi
}

#-> install neads app
install_require()
{
	local app=""
	for app in "$@"
	do
		if ! dpkg -s "$app" >/dev/null 2>&1
		then
			info "installing $app ..."
			if  apt install -y "$app" >/dev/null 2>&1
			then
				ok "$app is installed."
			else
				die "$app is not installed."
			fi
		fi
	done
	success "require packages installed !"
}
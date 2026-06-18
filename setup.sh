#!/bin/bash

########## Copyright C 2026 MIT Emad-ms ##########

# project: yuz-os builder
# project git : https://github.com/emad1234-msoudi/Yuz-OS_edu

########## set terminal ##########

set -Eeuo pipefail # set termainl mod

#-> system color // i use ai for find color

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

#-> var

mkdir -p log #dir for log file
file_debug="./log/$(date '+%Y-%m-%d_%H:%M:%S').log"

packages=("live-build" "squashfs-tools" "xorriso" "debootstrap" "git")


########## set script func ##########

#-> show massage func // ai for how to set color

info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[success]${NC} $*"; }
ok() { echo -e "${GREEN}[OK]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }
die()     { error "$*"; exit 1 ; }

#-> run my code // ai for what is this && make my run proJect beter
Run()
{
	local run_event="$1"
	local run_func="$2"

	info "$run_event..."

	if  { "$run_func" 2>&1 | tee -a "$file_debug"; }
 	then
		success "$run_event finished !"
	else
		die "oh! run_event filed. see log : $file_debug"
	fi

	echo
}

#-> titel script // use patorjk.com for make patern
Titel()
{
	clear
	echo " /\$\$     /\$\$                    /\$\$\$\$\$\$                  /\$\$\$\$\$\$\$            /\$\$ /\$\$       /\$\$";
	echo "|  \$\$   /\$\$/                   /\$\$__  \$\$                | \$\$__  \$\$          |__/| \$\$      | \$\$";
	echo " \\  \$\$ /\$\$//\$\$   /\$\$ /\$\$\$\$\$\$\$\$| \$\$  \\ \$\$  /\$\$\$\$\$\$\$      | \$\$  \\ \$\$ /\$\$   /\$\$ /\$\$| \$\$  /\$\$\$\$\$\$\$";
	echo "  \\  \$\$\$\$/| \$\$  | \$\$|____ /\$\$/| \$\$  | \$\$ /\$\$_____/      | \$\$\$\$\$\$\$ | \$\$  | \$\$| \$\$| \$\$ /\$\$__  \$\$";
	echo "   \\  \$\$/ | \$\$  | \$\$   /\$\$\$\$/ | \$\$  | \$\$|  \$\$\$\$\$\$       | \$\$__  \$\$| \$\$  | \$\$| \$\$| \$\$| \$\$  | \$\$";
	echo "    | \$\$  | \$\$  | \$\$  /\$\$__/  | \$\$  | \$\$ \\____  \$\$      | \$\$  \\ \$\$| \$\$  | \$\$| \$\$| \$\$| \$\$  | \$\$";
	echo "    | \$\$  |  \$\$\$\$\$\$/ /\$\$\$\$\$\$\$\$|  \$\$\$\$\$\$/ /\$\$\$\$\$\$\$/      | \$\$\$\$\$\$\$/|  \$\$\$\$\$\$/| \$\$| \$\$|  \$\$\$\$\$\$\$";
	echo "    |__/   \\______/ |________/ \\______/ |_______/       |_______/  \\______/ |__/|__/ \\_______/";
	echo "                                                                                              ";
	echo "                                                                                              ";
	echo "                                                                                              ";
	echo
}

#-> chek system root arch distro
System_chek()
{
	# root chek
	if [ "$EUID" == 0 ]
	then
		ok "your system is root"
	else
		error "Error! it's nead run this with sudo"
		exec sudo "$0" "$@"
		exit 1
	fi

	# arch chek
	if [ "$(arch)" == "x86_64" ]
	then
		ok "your system is $(arch)."
	else
		die "this script only writed for 64bit system , but your system is $(arch)."
	fi

	# distro chek

	. /etc/os-release #run for save system info in var

	if [[ "$ID" == "debian" && "$VERSION_ID" == "13"* ]]
	then
		ok "your system is $ID $VERSION_ID."
	else
		die "this script only writed for Debian 13 (Trixie) , but your system is $ID $VERSION_ID."
	fi
}


#-> install neads app
System_install()
{
	apt update

	for p in "${packages[@]}"
	do

		if ! dpkg -s "$p" >/dev/null 2>&1
		then
			info "installing $p :"
			apt install -y "$p"
		fi
	done
}


#-> Fix File Permissions
Build_perms()
{
	chmod +x  ./hooks/live/*
	chmod 755 ./config
	chmod 755 ./config/*
	chmod +x  ./Realse_config
}

#-> clean old make
Build_clean()
{
	read  -r -p "do you want to start clean old release ? [y/n] " answer

	if [[ "$answer" = "y" || "$answer" = "yes" ]]
	then
		if ls *.iso >/dev/null 2>&1
       		then
			info "backuping old iso"
			mkdir -p Release_old
			mv *.iso Release_old
			success "Old ISO files backed up to Release_old"
		fi
		lb clean --all
	else
		warn "for clean code nead clean old backup."
	fi

	info "clean old config "

	rm -rf ./config/{"binary","bootstrap","chroot","common","source"}
}

#-> set config
Build_config()
{
./release_config
}

#-> start build
Build_start()
{
	read -r -p "do you want to start build ? [y/n] " answer

	if [[ $answer = "y" || $answer = "yes" ]]
	then
		info "build started !"
		lb build
	else
        	info  "see you son agian!"
        	exit
	fi
}


########## main ##########
main()
{
	Titel

	Run "Cheking system" System_chek
	Run "Install requirements package" System_install
	Run "Fixing permission" Build_perms
	Run "Clean old make" Build_clean
	Run "Config build path" Build_config
	Run "Build distro" Build_start

}


main

#!/usr/bin/env bash

########## Copyright C 2026 MIT Emad-ms ##########

# project: yuz-os builder framework
# project git : https://github.com/emad1234-msoudi/Yuz-OS_edu

# framework/log.sh
# framework for manage log

########## shell load ckeck ##########

[[ -n "${BASH_VERSION:-}" ]] ||\
{
    echo "This framework requires bash !"
    return 1 2>/dev/null
}

########## framework load ckeck ##########

if [[ -n "${FRAMEWORK_LOG_LOADED:-}" ]]
then
    # shellcheck source=/dev/null
    return 0
else
    readonly FRAMEWORK_LOG_LOADED=1
fi

########## set framework func ##########

#-> show message func // ai for how to set color

info()    
{
	echo 
	printf "%b\n" "${BLUE}[ INFO ]${NC} $*"
	echo
}

ok()	  { printf "%b\n" "${GREEN}[ OK ]${NC} $*"      ; }

success()
{ 
	echo
	printf "%b\n" "${GREEN}[SUCCESS]${NC} $*"
	echo
}

warn()    { printf "%b\n" "${YELLOW}[ WARN ]${NC} $*"   ; }
error()   { printf "%b\n" "${RED}[ ERROR ]${NC} $*" >&2 ; }
die()     { error "$*"; exit 1 ; }

ask()
{
	local question="$1 [y/n] "
	local answer=""


	read -r -p "$(printf "%b" "${YELLOW}[ ASK ]${NC} $question")" answer < /dev/tty
	answer="${answer,,}"

	if [[ "$answer" = "y" || "$answer" = "yes" ]]
	then
		return 0 	
	else
		return 1
	fi  
}

########## end ##########

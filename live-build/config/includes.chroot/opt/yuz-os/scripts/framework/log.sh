#!/usr/bin/env bash

########## Copyright C 2026 MIT Emad-ms ##########

# project: yuz-os builder framework
# project git : https://github.com/emad1234-msoudi/Yuz-OS_edu

# /opt/yuz-os/scripts/framework/log.sh
# core framework for manage log

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

#-> show message func

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

########## end ##########

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

#-> show message func 

info()    { printf "%b\n" "\n${BLUE}[ INFO ]${NC} $* \n"; }
ok()      { printf "%b\n" "${GREEN}[  OK  ]${NC} $*"; }
success() { printf "%b\n" "\n${GREEN}[SUCCESS]${NC} $* \n"; }
warn()    { printf "%b\n" "${YELLOW}[ WARN ]${NC} $*" >&2; }

die()
{
    local message="$1"

    { 
		printf "\n"
		
		ui_title_big "$RED" "FATAL ERROR"
        printf "%b\n" \
            "${RED} ░█ ${NC}Message   : ${BOLD}${message}${NC}"
        printf "%b\n" \
            "${RED} ░█ ${NC}Exit Code : ${CYAN}1${NC}"
        ui_title_big_close "$RED" "HALTED"

        printf "\n"
    } >&2

    exit 1
}

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

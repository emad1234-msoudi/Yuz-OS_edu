#!/usr/bin/env bash

########## Copyright C 2026 MIT Emad-ms ##########

# project: yuz-os builder framework
# project git : https://github.com/emad1234-msoudi/Yuz-OS.git

# framework/ui.sh
# framework for manage ui 

########## shell load ckeck ##########

[[ -n "${BASH_VERSION:-}" ]] ||\
{
    echo "This framework requires bash !"
    return 1 2>/dev/null
}

########## frameware load ckeck ##########

if [[ -n "${FRAMEWORK_UI_LOADED:-}" ]]
then
    # shellcheck source=/dev/null
    return 0
else
    readonly FRAMEWORK_UI_LOADED=1
fi

########## framework var ##########

#-> system color // i use ai for find color

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

export RED GREEN YELLOW BLUE NC

########## tools for ui style ##########
ui_title_small()
{
    local color="$1"
    shift 1

    local title="$*"
    
    printf "%b\n" "${color}                                     ${NC}"
    printf "%b\n" "${color} ╱█▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█      ${NC}" 
    printf "%b\n" "${color}░█  ⇀ $title                         ${NC}"
    printf "%b\n" "${color}                                     ${NC}"                                       
}

ui_title_big()
{
    local color="$1"
    shift 1

    local title="$*"
    
    printf "%b\n" "${color}                                         ${NC}"
    printf "%b\n" "${color}     ╱█▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█      ${NC}" 
    printf "%b\n" "${color}    ░█  ⇀ $title                         ${NC}"
    printf "%b\n" "${color}   ░█                                    ${NC}"
    printf "%b\n" "${color}  ░█▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█         ${NC}"
    printf "%b\n" "${color} ╱░░░░░░░░░░░░░░░░░░░░░░░░░░░░╱          ${NC}"
    printf "%b\n" "${color}                                         ${NC}"
    printf "%b\n" "${color}                                         ${NC}"
}


########## banner framework func ##########

#-> titel script // use "ascii draw" app to make it

ui_banner_project()
{
    local color="$1"

	clear

    printf "%b\n"  "${color}   █████ █████                                                      █████                 ███  ████      █████ ${NC}"
    printf "%b\n"  "${color}  ░░███ ░░███                                                      ░░███                 ░░░  ░░███     ░░███  ${NC}"
    printf "%b\n"  "${color}   ░░███ ███   █████ ████  █████████             ██████   █████     ░███████  █████ ████ ████  ░███   ███████  ${NC}"
    printf "%b\n"  "${color}    ░░█████   ░░███ ░███  ░█░░░░███  ██████████ ███░░███ ███░░      ░███░░███░░███ ░███ ░░███  ░███  ███░░███  ${NC}"
    printf "%b\n"  "${color}     ░░███     ░███ ░███  ░   ███░  ░░░░░░░░░░ ░███ ░███░░█████     ░███ ░███ ░███ ░███  ░███  ░███ ░███ ░███  ${NC}"
    printf "%b\n"  "${color}      ░███     ░███ ░███    ███░   █           ░███ ░███ ░░░░███    ░███ ░███ ░███ ░███  ░███  ░███ ░███ ░███  ${NC}"
    printf "%b\n"  "${color}      █████    ░░████████  █████████           ░░██████  ██████     ████████  ░░████████ █████ █████░░████████ ${NC}"
    printf "%b\n"  "${color}     ░░░░░      ░░░░░░░░  ░░░░░░░░░             ░░░░░░  ░░░░░░     ░░░░░░░░    ░░░░░░░░ ░░░░░ ░░░░░  ░░░░░░░░  ${NC}"
    printf "%b\n"  "${color}                                                                                                               ${NC}"
    printf "%b\n"  "${color}                                                                                                               ${NC}"
    printf "%b\n"  "${color}     || a builder to build $PROJECT_FULL_NAME                                                                  ${NC}"
    echo
}

######### framework event banner #########

ui_banner_module()
{
    local color="$1"

    printf "%b\n"  "${color}  __                     __         __                ${NC}"
    printf "%b\n"  "${color} |  | .--------.-----.--|  |.--.--.|  |.-----.-----.  ${NC}"
    printf "%b\n"  "${color} |  | |        |  _  |  _  ||  |  ||  ||  -__|__ --|  ${NC}"
    printf "%b\n"  "${color} |  | |__|__|__|_____|_____||_____||__||_____|_____|  ${NC}"
    printf "%b\n"  "${color} |  |                                                 ${NC}"
    printf "%b\n"  "${color} |  |   setup project modules                         ${NC}"
    printf "%b\n"  "${color}  ¯¯                                                  ${NC}"
    echo

}

########## end ##########

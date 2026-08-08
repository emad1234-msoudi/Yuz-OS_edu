#!/usr/bin/env bash

########## Copyright C 2026 MIT Emad-ms ##########

# project: yuz-os runtime module
# project git : https://github.com/emad1234-msoudi/Yuz-OS_edu

# /opt/yuz-os/scripts/brand/plymouth_brand.sh

# build time module for set plymouth theme.
# This module install Yuz-os os barnd plymouth theme from plymouth_brand.conf configuration

########### setup environment ##########

set -Eeuo pipefail

#source "../../bootstrap.sh" #-> this source just for development
#source "./plymouth_brand.conf"       #-> this source just for development

########## func ##########

#-> check neaded to run
plymouth_brand_check()
{
    #-> checking root
    if [[ ! "$EUID" -eq 0 ]]
    then
        die "Please run this with sudo."
    fi

    #-> source plymouth_brand.conf
    if [[ -f "$MODULE_DIR/brand/plymouth_brand.conf" ]]
    then
        source "$MODULE_DIR/brand/plymouth_brand.conf"
    else
        die "plymouth_brand.conf file not found."
    fi

    #-> check plymouth theme theme from data
    exist_file "${PLYMOUTH_DATA}"

    #-> checking needed optaional command
    for pkg in "${PLYMOUTH_REQUIRED_PACKAGES[@]}"
    do
        if ! dpkg -s "$pkg" >/dev/null 2>&1
        then
            die "Package is not installed: ${pkg}"
        fi
    done

    return 0
}

#-> prepare system to deploy plymouth theme
plymouth_brand_prepare()
{
    info "Preparing plymouth theme directory"
    
    #-> remove all old plymouth theme
    if [[ -d "${PLYMOUTH_TARGET_DIR}" ]]
    then
        info "Cleaning old plymouth theme"
        if safe_remove "${PLYMOUTH_TARGET_DIR}"
        then
            ok "Old plymouth themes removed."
        else
            die "Failed to clean old plymouth themes."
        fi
    fi

    #-> make plymouth theme directory
    ensure_dir "${PLYMOUTH_TARGET_DIR}"

    return 0
}

#-> deploy plymouth theme
plymouth_brand_deploy()
{
    info "Deploying plymouth theme."

    #-> deploy plymouth theme
    if unzip_file "$PLYMOUTH_DATA" "$PLYMOUTH_TARGET_DIR" 
    then
        #-> double check theme entrypoint file layout
        if [[ -f "${PLYMOUTH_THEME_FILE}" ]]; then
            ok "Plymouth theme assets deployed successfully."
        else
            error "Theme file not found at expected path: ${PLYMOUTH_THEME_FILE}"
            return 1
        fi
    else
        error "Failed to deploy plymouth theme."
        return 1
    fi   

    return 0
}

#-> update plymouth configuration
plymouth_brand_update()
{
    info "Updating plymouth configurations."


    #-> detect and execute the correct plymouth update tool
    if command -v plymouth-set-default-theme >/dev/null 2>&1; then
        info "Updating plymouth menu using plymouth-set-default-theme ..."
        plymouth-set-default-theme -R "${PLYMOUTH_THEME_NAME}" >/dev/null 2>&1 ||\
        { 
            die "Failed to execute plymouth-set-default-theme"
        }
    else
        error "plymouth update tool (plymouth-set-default-theme) not found on target system."
        return 1
    fi

    ok "Plymouth configuration updated successfully."
    return 0
}

########## main plymouth brand ##########
#-> main for load plymouth brand func

main_plymouth_brand()
{
    plymouth_brand_check    || return 1
    plymouth_brand_prepare  || return 1
    plymouth_brand_deploy   || return 1
    plymouth_brand_update   || return 1

    return 0
}

#main_plymouth_brand "$@"

########## end ##########
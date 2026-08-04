#!/usr/bin/env bash

########## Copyright C 2026 MIT Emad-ms ##########

# project: yuz-os runtime module
# project git : https://github.com/emad1234-msoudi/Yuz-OS_edu

# /opt/yuz-os/scripts/brand/grub_brand.sh

# build time module for set grub theme.
# This module install Yuz-os os barnd grub theme from grub_brand.conf configuration

########### setup environment ##########

set -Eeuo pipefail

source "../../bootstrap.sh" #-> this source just for development
source "./grub_brand.conf"       #-> this source just for development

########## func ##########

#-> check neaded to run
grub_brand_check()
{
    #-> checking root
    if [[ ! "$EUID" -eq 0 ]]
    then
        die "Please run this with sudo."
    fi

    #-> source grub_brand.conf
    if [[ -f "$MODULE_DIR/brand/grub_brand.conf" ]]
    then
        source "$MODULE_DIR/brand/grub_brand.conf"
    else
        die "grub_brand.conf file not found."
    fi

    #-> check Grub theme theme from data
    exist_file "${GRUB_DATA}"

    #-> checking needed optaional command
    for pkg in "${GRUB_REQUIRED_PACKAGES[@]}"
    do
        if ! dpkg -s "$pkg" >/dev/null 2>&1
        then
            die "Package is not installed: ${pkg}"
        fi
    done

    return 0
}

#-> prepare system to deploy grub theme
grub_brand_prepare()
{
    info "Preparing grub theme directory"
    
    #-> remove all old grub theme
    if [[ -d "${GRUB_TARGET_DIR}" ]]
    then
        info "Cleaning old Grub theme"
        if safe_remove "${GRUB_TARGET_DIR}"
        then
            ok "Old Grub theme removed."
        else
            die "Failed to clean old grub theme."
        fi
    fi

    #-> make grub theme directory
    ensure_dir "${GRUB_TARGET_DIR}"

    return 0
}

#-> deploy grub theme
grub_brand_deploy()
{
    info "Deploying grub bootloader theme."

    #-> deploy Grub theme
    if unzip_file "$GRUB_DATA" "$GRUB_TARGET_DIR" 
    then
        #-> double check theme entrypoint file layout
        if [[ -f "${GRUB_THEME_FILE}" ]]; then
            ok "Grub theme assets deployed successfully."
        else
            error "Theme file not found at expected path: ${GRUB_THEME_FILE}"
            return 1
        fi
    else
        error "Failed to deploy Grub theme."
        return 1
    fi   

    return 0
}

#-> update GRUB bootloader configuration
grub_brand_update()
{
    info "Updating GRUB configurations."

    #-> ensure grub.d directory exists
    ensure_dir "$(dirname "${GRUB_DROPIN_CONF}")"

    #-> create drop-in configuration file for grub theme
    info "Creating drop-in configuration at ${GRUB_DROPIN_CONF}"
    cat << EOF > "${GRUB_DROPIN_CONF}"
# Active GRUB theme configuration for Yuz-OS_Edu
GRUB_THEME="${GRUB_THEME_FILE}"
EOF

    #-> detect and execute the correct grub update tool
    if command -v update-grub >/dev/null 2>&1; then
        info "Updating GRUB menu using update-grub..."
        update-grub >/dev/null 2>&1 || { error "Failed to execute update-grub"; return 1; }
    elif command -v grub-mkconfig >/dev/null 2>&1; then
        info "Updating GRUB menu using grub-mkconfig..."
        grub-mkconfig -o /boot/grub/grub.cfg >/dev/null 2>&1 || { error "Failed to execute grub-mkconfig"; return 1; }
    else
        error "GRUB update tool (update-grub / grub-mkconfig) not found on target system."
        return 1
    fi

    ok "GRUB bootloader configuration updated successfully."
    return 0
}

########## main grub brand ##########
#-> main for load grub brand func

main_grub_brand()
{
    grub_brand_check    || return 1
    grub_brand_prepare  || return 1
    grub_brand_deploy   || return 1
    grub_brand_update   || return 1

    return 0
}

#main_grub_brand "$@"

########## end ##########
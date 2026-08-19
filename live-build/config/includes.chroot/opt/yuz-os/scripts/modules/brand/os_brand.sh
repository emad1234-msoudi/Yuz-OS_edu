#!/usr/bin/env bash

########## Copyright C 2026 MIT Emad-ms ##########

# project: yuz-os runtime module
# project git : https://github.com/emad1234-msoudi/Yuz-OS_edu

# /opt/yuz-os/scripts/brand/os_brand.sh

# build time module for Yuz-OS set branding & information .
# This configuration set from brand.conf :

# - /etc/os-release , modern linux information.
# - /etc/lsb-release , classic linux information file.
# - /etc/issue & /etc/issue.net for TTY or SSH Walcome !

########### setup environment ##########

set -Eeuo pipefail

#source "../../bootstrap.sh" #-> this source just for development
#source "./os_brand.conf"       #-> this source just for development

########## func ##########

#-> check neaded to run
os_brand_check()
{
    #-> checking root
    if [[ ! "$EUID" -eq 0 ]]
    then
        die "Please run this with sudo."
    fi

    #-> source os_brand.conf 
    if [[ -f "$MODULE_DIR/brand/os_brand.conf" ]]
    then
        source "$MODULE_DIR/brand/os_brand.conf"
    else
        die "os_brand.conf file not found."
    fi

    return 0
}

#-> Helper function to generate and write a brand file
os_brand_write_template() 
{
    local title="$1"
    local target_path="$2"
    local raw_content="$3"

    ui_title_small "$BLUE" "${title} :"

    #-> remove old os-realse config files.
    info "Removing old ${title} config file"
    safe_remove --ignore-missing "${target_path}"

    #-> write new config file
    info "Writing new ${title} config file"
    
    # Note: we use 'eval' to generate content filled with used conf variables
    eval "cat <<EOF
${raw_content}
EOF" | write_text_file "${target_path}" "0644" "root" "root" || die "Failed to write ${title} config file."

    ok "${title} config file writed."
}

#-> func to deploy brand templates configuration files 
os_brand_deploy_templates()
{
    #-> deploy os-realse brand templates
    os_brand_write_template \
        "OS-Release" \
        "$OS_RELEASE_TARGET_FILE" \
        "$OS_RELEASE_CONTENT" \
        || return 1

    #-> deploy lsb-realse brand templates
    os_brand_write_template \
        "Lsb-Release" \
        "$LSB_RELEASE_FILE" \
        "$LSB_RELEASE_CONTENT" \
        || return 1

    #-> deploy Issuse brand templates
    os_brand_write_template \
        "Issue" \
        "$ISSUE_FILE" \
        "$ISSUE_CONTENT" \
        || return 1

    #-> deploy issues-net brand templates
    os_brand_write_template \
        "Issue-Net" \
        "$ISSUE_NET_FILE" \
        "$ISSUE_NET_CONTENT" \
        || return 1

    return 0
}

#-> func to link os-release from /usr/lib/ to /etc/
os_brand_os_realse_config()
{
    ui_title_small "$BLUE" "OS-Release Symlink :"

    #-> link os-tree shortcut form /usr/lib/ to /etc/
    info "link os-tree shortcut form /usr/lib/ to /etc/"

    #-> check shortcut file  
    [[ -f "${OS_RELEASE_TARGET_FILE}" ]] || die "${OS_RELEASE_TARGET_FILE} not found to make link."

    #-> remove old config file
    info "Removing old os-release symlink config file"
    safe_remove --ignore-missing "${OS_RELEASE_FILE}"

    #-> make link
    if ln -s "${OS_RELEASE_TARGET_FILE}" "${OS_RELEASE_FILE}"
    then
        ok "Linked."
    else
        die "Failed to link config file."
    fi

    return 0
}

#-> func to show summary about deployed brand templates configuration files 
os_brand_summary()
{
    ui_title_small "$BLUE" "Summary :"

    lsb_release

    return 0
}

########## main os brand ##########
#-> main for load os brand func

main_os_brand()
{
    os_brand_check             || return 1
    os_brand_deploy_templates  || return 1
    os_brand_os_realse_config  || return 1
    os_brand_summary           || return 1

    return 0
}

#main_os_brand "$@"

########## end ##########
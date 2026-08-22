#!/usr/bin/env bash

########## Copyright C 2026 MIT Emad-ms ##########

# project: yuz-os runtime module
# project git : https://github.com/emad1234-msoudi/Yuz-OS_edu

# /opt/yuz-os/scripts/prefix/path_prefix.sh

# build time module for prefix system path.

# some path this module add to all user 'PATH' :

# - /usr/local/sbin
# - /usr/sbin
# - /sbin

########### setup environment ##########

set -Eeuo pipefail

##source "../../bootstrap.sh" #-> this source just for development

########## func ##########

#-> check neaded to run
path_prefix_check()
{
    #-> checking root
    if [[ ! "$EUID" -eq 0 ]]
    then
        die "Please run this with sudo."
    fi

    return 0
}

#-> write path prefix config file 
path_prefix_write()
{
    info "Writing path prefix"

    if write_text_file "/etc/profile.d/yuz-path.sh" 0644 << 'EOF'
# Added by Yuz Builder Framework , path prefix - Set default system paths for all users
case ":$PATH:" in
    *:/usr/local/sbin:*) ;;
    *) PATH="/usr/local/sbin:$PATH" ;;
esac

case ":$PATH:" in
    *:/usr/sbin:*) ;;
    *) PATH="/usr/sbin:$PATH" ;;
esac

case ":$PATH:" in
    *:/sbin:*) ;;
    *) PATH="/sbin:$PATH" ;;
esac

export PATH
EOF
    then
        info "Path prefix configuration written."

    else
        die "Failed to write path prefix."
    fi

    return 0
}

########## main path prefix ##########
#-> main for load path prefix func

main_path_prefix()
{
    path_prefix_check   || return 1
    path_prefix_write   || return 1    

    return 0
}

#main_grub_brand "$@"

########## end ##########

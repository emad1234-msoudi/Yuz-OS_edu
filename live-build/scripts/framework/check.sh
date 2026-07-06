#!/usr/bin/env bash

########## Copyright C 2026 MIT Emad-ms ##########

# project: yuz-os builder framework
# project git : https://github.com/emad1234-msoudi/Yuz-OS_edu

# framework/check.sh
# framework for check system & framework environment

########## shell load ckeck ##########

[[ -n "${BASH_VERSION:-}" ]] ||\
{
    echo "This framework requires bash !"
    return 1 2>/dev/null
}

########## framework load ckeck ##########

if [[ -n "${FRAMEWORK_CHECK_LOADED:-}" ]]
then
    # shellcheck source=/dev/null
    return 0
else
    readonly FRAMEWORK_CHECK_LOADED=1
fi

########## set framework func ##########

#-> chek root system
check_root()
{
	if (( "$EUID" == 0 ))
    then
        ok "Your system is root."
        return 0
    else
        error "Please run this with sudo."
        return 1
    fi
}

#-> func for chek free space
check_disk_space()
{
    local need_gb="${REQUIRED_DISK_SPACE_GB:-$1}"
    local need_kb=$((need_gb * 1024 * 1024))

    local avail_kb
    avail_kb=$(df -Pk "$PROJECT_ROOT" | awk 'NR==2 {print $4}')
    
    if (( avail_kb >= need_kb ))
    then
        ok "Required disk space (${need_gb} GB) is available."
		return 0
	else
		warn "At least ${need_gb} GB of free disk space is required."
        return 1
	fi
}

#-> check network connection
check_network()
{
    local required_host="${1:-2}"
    (( $# >0 )) && shift 1

    local count=0
    
    local -a urls=("$@")
    
    urls+=(
        "deb.debian.org"
        "github.com"
        "dl.flathub.org"
    )

    info "Checking network connection."

    for url in "${urls[@]}"
    do
        if nc -zw2 "$url" 443 >/dev/null 2>&1
        then
            ok "Connected to : $url"
            ((count++))

            if (( count >= required_host )) 
            then
                ok "Network connection verified."
                return 0
            fi
        else
            error "Failed to connect : $url"
            return 1
        fi
    done

    warn "Unable to verify network connectivity."

    return 1
}

#-> read system arch and check 
check_system_arch()
{
    local system_arch
    system_arch="$(uname -m)"
    
	if [[ "$system_arch" == "$REQUIRED_ARCH" ]]
	then
		ok "Your system is $system_arch."
        return 0
	else
        die "This script support only $REQUIRED_ARCH system , but your system is $system_arch."
	fi
}

#-> distro chek
check_system_dist()
{
    if [[ -r /etc/os-release ]] 
    then
        source /etc/os-release
    else
        die "System os-release not found ."
    fi

	if [[ "$ID" == "$REQUIRED_DISTRO" && "$VERSION_ID" == "$REQUIRED_DISTRO_VERSION"* ]]
	then
		ok "Your system is $ID $VERSION_ID."
        return 0
	else
		die "This script support only $REQUIRED_DISTRO $REQUIRED_DISTRO_VERSION , but your system is $ID $VERSION_ID."
	fi
}

########## end ##########

#!/usr/bin/env bash

########## Copyright C 2026 MIT Emad-ms ##########

# project: yuz-os builder framework
# project git : https://github.com/emad1234-msoudi/Yuz-OS.git

# framework/check.sh
# framework for check system & framework environment

########## shell load ckeck ##########

[[ -n "${BASH_VERSION:-}" ]] ||\
{
    echo "This framework requires bash !"
    return 1 2>/dev/null
}

########## frameware load ckeck ##########

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
        ok "your system is root"
        return 0
    else
        error "nead run this with sudo !"
        return 1
    fi
}

#-> func for chek free space
check_disk_space()
{
    local need_gb="$REQUIRED_DISK_SPACE_GB"
    local need_kb=$((need_gb * 1024 * 1024))

    local avail_kb
    avail_kb=$(df -Pk "$PROJECT_ROOT" | awk 'NR==2 {print $4}')
    
    if (( avail_kb >= need_kb ))
    then
        ok "your disk has $need_gb GB free space "
		return 0
	else
        warn "your system don't have enough free space"
		return 1
	fi
}

#-> check network connection
check_network()
{
    local urls=(
        "github.com"
        "flathub.org"
        "deb.debian.org"
        "google.com"
    )

    for url in "${urls[@]}"
    do
        if ping -c 1 -W 2 "$url" >/dev/null 2>&1
        then
            ok "your system connected to : $url"
            return 0
        fi
    done

    warn "no network connection"
    return 1
}

#-> read system arch and check 
check_system_arch()
{
    local system_arch
    system_arch="$(uname -m)"
    
	if [[ "$system_arch" == "$REQUIRED_ARCH" ]]
	then
		ok "your system is $system_arch."
        return 0
	else
        die "this script only writed for $REQUIRED_ARCH system , but your system is $system_arch."
	fi
}

#-> distro chek
check_system_dist()
{
    if [[ -r /etc/os-release ]] 
    then
        source /etc/os-release
    else
        die "system source not found !"
    fi

	if [[ "$ID" == "$REQUIRED_DISTRO" && "$VERSION_ID" == "$REQUIRED_DISTRO_VERSION"* ]]
	then
		ok "your system is $ID $VERSION_ID."
        return 0
	else
		die "this script only writed for $REQUIRED_DISTRO $REQUIRED_DISTRO_VERSION , but your system is $ID $VERSION_ID."
	fi
}

########## end ##########

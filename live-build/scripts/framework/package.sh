#!/usr/bin/env bash

########## Copyright C 2026 MIT Emad-ms ##########

# project: yuz-os builder framework
# project git : https://github.com/emad1234-msoudi/Yuz-OS.git

# framework/package.sh
# framework for manage system package

########## shell load ckeck ##########

[[ -n "${BASH_VERSION:-}" ]] ||\
{
    echo "This framework requires bash !"
    return 1 2>/dev/null
}

########## frameware load ckeck ##########

if [[ -n "${FRAMEWORK_PACKAGE_LOADED:-}" ]]
then
    # shellcheck source=/dev/null
    return 0
else
    readonly FRAMEWORK_PACKAGE_LOADED=1
fi

########## set framework func ##########

#-> install required packages
package_install()
{
	local app

    for app in "$@"
	do
		if  dpkg -s "$app" >/dev/null 2>&1
		then
			ok "$app is already installed"
		esle
			info "installing $app ..."
			if  apt-get install -y "$app" >/dev/null 2>&1
			then
				ok "$app is installed."
			else
				if ! check_network >/dev/null 2>&1
				then
					error "no network connection to download"
				fi

				die "$app is not installed."
			fi
		fi
	done
	success "all required packages available !"
}

#-> update system
package_update()
{
	info "updating system"

	if check_network >/dev/null 2>&1
	then	
		if apt-get update >/dev/null 2>&1
		then
			ok "system is updated"
			return 0
		fi
	fi

	warn warn "system is not updated."
	return 1
}

########## end ##########

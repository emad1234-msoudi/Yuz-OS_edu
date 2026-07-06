#!/usr/bin/env bash

########## Copyright C 2026 MIT Emad-ms ##########

# project: yuz-os builder framework
# project git : https://github.com/emad1234-msoudi/Yuz-OS_edu

# framework/package.sh
# framework for manage system package

########## shell load ckeck ##########

[[ -n "${BASH_VERSION:-}" ]] ||\
{
    echo "This framework requires bash !"
    return 1 2>/dev/null
}

########## framework load ckeck ##########

if [[ -n "${FRAMEWORK_PACKAGE_LOADED:-}" ]]
then
    # shellcheck source=/dev/null
    return 0
else
    readonly FRAMEWORK_PACKAGE_LOADED=1
fi

########## set framework func ##########

#-> install required packages
install_require()
{
	local app
	
	info "Checking required package(s)."

    for app in "$@"
	do
		if  dpkg -s "$app" >/dev/null 2>&1
		then
			ok "$app is already installed."
		else
			info "installing $app ..."
			if  DEBIAN_FRONTEND=noninteractive apt-get install -y -- "$app" >/dev/null 2>&1
			then
				ok "$app is installed."
			else
				die "Failed to install $app."
			fi
		fi
	done
	
	echo
	ok "All required packages available."
	return 0
}

#-> update system
package_update()
{
	info "Updating package lists..."

	if apt-get update >/dev/null 2>&1
		then
			ok "System is updated"
			return 0
		fi

	warn "Failed to update package lists."
	return 1
}

########## end ##########

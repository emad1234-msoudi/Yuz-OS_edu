#!/usr/bin/env bash

########## Copyright C 2026 MIT Emad-ms ##########

# project: yuz-os builder module
# project git : https://github.com/emad1234-msoudi/Yuz-OS_edu

# module/build/build.sh
# module for build this project

########### setup environment ##########

# source "../../bootstrap.sh" #-> tihs source just for development

set -Eeuo pipefail

########## var ##########

build_output=".hybrid.iso"

build_old_dir="${PROJECT_ROOT}/old_build/${PROJECT_FULL_NAME}"
build_old_output="${PROJECT_ROOT}/*${build_output}"

########## set script func ##########
# check build requirements
build_check()
{
	ui_title_small "$GREEN" "Checking build requirements"

	#chek system root 
	if ! check_root >/dev/null 2>&1 ; then die "Required run this with sudo." ; fi  

	# check & install neaded packages
	install_require "live-build" "squashfs-tools" "xorriso" "debootstrap"
	
	# chek system free space
	if ! check_disk_space >/dev/null 2>&1
    then 
		die "For build this project needed $REQUIRED_DISK_SPACE_GB free space."
	fi

	ui_title_small_close "$GREEN" "Build requirements completed"
	return 0
}

#-> clean old make
build_clean()
{
	ui_title_small "$GREEN" "Cleaning previous build"

	if ask "Do you want to clean previous build ?"
	then

		#-> back up old build outputs
		exist_file "$build_output" >/dev/null 2>&1 && \
		{
			info "Old build outputs files exists."

			if ask "Do yo want back up outputs files ?" 
       		then
				info "Backing up old build outputs..."
				ensure_dir "$build_old_dir"
				safe_move  "$build_old_output" "$build_old_dir"
				success "old ISO files backed up to $build_old_dir"
			fi
		}

		#-> clean old build outputs :
		# chroot , binnary , auto , build outputs 
		info "Cleaning old build outputs"
		
		run_task \
		"Clean old build file" "$LOG_EMPTY" \
		lb clean --all >/dev/null
		
		success "Cleaning old build outputs completed."

		#-> clean old build config files to rebuild
		run_task \
		"Clean old config file" "$LOG_EMPTY" \
		safe_remove "true" \
	    "$CONFIG_DIR/binary" \
		"$CONFIG_DIR/bootstrap" \
		"$CONFIG_DIR/chroot" \
		"$CONFIG_DIR/common" \
		"$CONFIG_DIR/source"
	else
		warn "Previous build files & config not cleaned."
	fi

	ui_title_small_close "$GREEN" "Cleaning previous build completed."
	return 0
}

#-> set config
build_config()
{
	ui_title_small "$GREEN" "Configuring live_build"

	if bash "$MODULE_DIR/build/config.sh" 1>/dev/null
	then
		ok "Configuration generated."
	else
		die "Configuring live_build not finished. this is required to build."
	fi
		
	ui_title_small_close "$GREEN" "Configuring live_build completed."
	return 0
}

#-> start build
build_start()
{
	ui_title_small "$GREEN" "Building $PROJECT_NAME"

	if ask "Are you sure to start build ?"
	then
		ui_banner_build "$BLUE"

		run_task \
		"Build " "$LOG_EMPTY" \
		lb build
	else
        info  "Build cancelled by user"
        return 0
	fi

	ui_title_small_close "$GREEN" "Building project completed"
	return 0
}

########## main build ##########
#-> main for load build func

main_build_setup()
{
	build_check
	build_clean
	build_config
}

main_build()
{
	build_start
}

#main_build_set "$@"
#main_build "$@"

########## end ##########

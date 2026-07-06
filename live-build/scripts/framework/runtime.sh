#!/usr/bin/env bash

########## Copyright C 2026 MIT Emad-ms ##########

# project: yuz-os builder framework
# project git : https://github.com/emad1234-msoudi/Yuz-OS_edu

# framework/runtime.sh
# framework for manage run framework prompt

########## shell load ckeck ##########

[[ -n "${BASH_VERSION:-}" ]] ||\
{
    echo "This framework requires bash !"
    return 1 2>/dev/null
}

########## framework load ckeck ##########

if [[ -n "${FRAMEWORK_RUNTIME_LOADED:-}" ]]
then
    # shellcheck source=/dev/null
    return 0
else
    readonly FRAMEWORK_RUNTIME_LOADED=1
fi

########## set framework func ##########

#-> run my code // ai for what is this && make my run proJect better
run_task()
{
	# run argument 
	local run_event="$1"
	local run_log_file="$2"
	export run_log_file

	shift 2

	# information run mangement
	[[ -n "$run_event" ]] && info "$run_event"

	# run command and mannage log 
	if "$@"   
 	then
		[[ -n "$run_event" ]] && success "$run_event completed."
	else
		if [[ "$run_log_file" == "$LOG_EMPTY" ]]
		then
			die "$run_event failed."
		else
			die "$run_event failed. see log : $run_log_file"
		fi
	fi

	echo
	return 0
}

#-> run project modules 

run_pipeline()
{
	local id title function enabled mandatory

	ui_banner_module "$BLUE"
	
    while IFS='|' read -r id title function enabled mandatory   
    do
        #-> skip line if started whith "#" or "space" 
        [[ -z "$id" ]] && continue
        [[ "$id" =~ ^# ]] && continue

        #-> check and if enable to run
		if [[ "$enabled" != "yes" ]]
		then
			warn "Module $title is disabled. Skipping"
			echo 
			continue 
		fi

        #-> run module function if sourcde
        if ! declare -F "$function" >/dev/null
		then
			if [[ "$mandatory" == "yes" ]]
			then
				error "$function is not loaded. this is required to build"
				return 1
			else
				warn  "$function is not loaded, but not required to build"
				echo 
				continue
			fi
		fi

		if ask "Run $title ?"
		then
			ui_title_big "$BLUE" "$title"
			if "$function"
			then
				ui_title_big_close "$BLUE" "$title completed."
				echo
			else
				if [[ "$mandatory" == "yes" ]]
				then
					error "$function isn't finished. this is required to build"
					return 1
				else
					warn  "$function isn't finished, but not required to build"
					echo
					continue
				fi
			fi
		else
			ok "Skipping run $title"
			echo		
		fi 

    done < "$MODULE_RUN"

	return 0
}

########## end ########

#!/usr/bin/env bash

########## Copyright C 2026 MIT Emad-ms ##########

# project: yuz-os builder framework
# project git : https://github.com/emad1234-msoudi/Yuz-OS.git

# framework/runtime.sh
# framework for manage run framework prompt

########## shell load ckeck ##########

[[ -n "${BASH_VERSION:-}" ]] ||\
{
    echo "This framework requires bash !"
    return 1 2>/dev/null
}

########## frameware load ckeck ##########

if [[ -n "${FRAMEWORK_RUNTIME_LOADED:-}" ]]
then
    # shellcheck source=/dev/null
    return 0
else
    readonly FRAMEWORK_RUNTIME_LOADED=1
fi

########## set framework func ##########

#-> run my code // ai for what is this && make my run proJect better
Run()
{
	# run argument 
	local run_event="$1"
	local run_log_file="$2"
	shift 2

	#run command and save debug
	info "$run_event ..."

	if "$@"   
 	then
		success "$run_event finished !"
	else
		die "oh! $run_event failed. see log : $run_log_file"
	fi

	echo
}

#-> run project modules 

Run_module()
{
	local module_name="$1"
	local module_func="$2"
	shift 2

	declare -F "$module_func" >/dev/null \
    || die "$module_func not found"

	if ask "do you want run $module_name ?"
	then
		"${module_func}"
	else
		ok "skip run $module_name"
	fi 
}

########## end ##########

#!/usr/bin/env bash

########## Copyright C 2026 MIT Emad-ms ##########

# project: yuz-os builder framework
# project git : https://github.com/emad1234-msoudi/Yuz-OS_edu

# framework/file.sh
# framework for manage project filesystem

########## shell load ckeck ##########

[[ -n "${BASH_VERSION:-}" ]] ||\
{
    echo "This framework requires bash !"
    return 1 2>/dev/null
}

########## framework load ckeck ##########

if [[ -n "${FRAMEWORK_FILE_LOADED:-}" ]]
then
    # shellcheck source=/dev/null
    return 0
else
    readonly FRAMEWORK_FILE_LOADED=1
fi

########## set framework func ##########

exist_dir()
{
    local dir

    for dir in "$@"
    do
        if [[ -d "$dir" ]]
        then
            ok "$dir already exists."
        else
            error "$dir doesn't exists."
            return 1
        fi
    done

    return 0
}

exist_file()
{
    local file

    for file in "$@"
    do
        if [[ -f "$file" ]]
        then
            ok "$file already exists."
        else
            error "$file dosen't exists."
            return 1
        fi
    done

    return 0
}

#-> check project directories
ensure_dir()
{
    local dir
    
    for dir in "$@"
    do
        if [[ -d "$dir" ]]
        then
            ok "$dir already exist."
        else
            if [[ -f "$dir" ]] 
            then
                error "$dir is file !"
                return 1
            else
                if mkdir -p "$dir" >/dev/null 2>&1
                then
                    ok "$dir created."
                else
                    error "Failed to create $dir"
                    return 1
                fi
            fi
        fi
    done 

    return 0
}

#-> check project files
ensure_file()
{
    local file
    
    for file in "$@"
    do
        if [[ -f "$file" ]]
        then
            ok "$file already exist."
        else
            if [[ -d "$file" ]] 
            then
                error "$file is directory !"
                return 1
            else
                ensure_dir "$(dirname "$file")"
                if touch "$file" >/dev/null 2>&1
                then
                    ok "$file created."
                else
                    error "Failed to create $file."
                    return 1
                fi  
            fi
        fi
    done 

    return 0
}

#-> ckeck and try to safe copy files or directories
safe_copy()
{
    local copy_location="${!#}"
    local items

    (( $# >= 2 )) || {
        error "No file selected to copy."
        return 1
    }

    if [ ! -d "$copy_location" ]
    then    
        [[ -f "$copy_location" ]] &&\
            error "$copy_location is file."&&\
            return 1  

        error "$copy_location doesn't exist."

        return 1
    fi

    for (( items=1 ; items<$# ; items++ ))
    do
        if [[ -f "${!items}" || -d "${!items}" ]]
        then
            if cp -a "${!items}" "$copy_location" >/dev/null 2>&1
            then
                ok "Copied ${!items} to $copy_location."
            else
                error "Failed to copy ${!items} to $copy_location."
                return 1
            fi
        else
            error "${!items} doesn't exist."
            return 1
        fi
    done

    return 0
}

#-> ckeck and try to safe move files or directories
safe_move()
{
    local move_location="${!#}"
    local items

    (( $# >= 2 )) || {
        error "No file selected to move."
        return 1
    }

    if [ ! -d "$move_location" ]
    then    
        [[ -f "$move_location" ]] &&\
            error "$move_location is file."&&\
            return 1

        error "$move_location doesn't exist."

        return 1
    fi

    for (( items=1 ; items<$# ; items++ ))
    do
        if [[ -f "${!items}" || -d "${!items}" ]]
        then
            if mv -- "${!items}" "$move_location" >/dev/null 2>&1
            then
                ok "Moved ${!items} to $move_location."
            else
                error "Failed to move ${!items} to $move_location."
                return 1
            fi
        else
            error "${!items} doesn't exist."
            return 1
        fi
    done

    return 0
}

#-> ckeck and try to safe remove files or directories
safe_remove()
{
    local items
    local ignore_missing="${1:-false}"
    shift 1

    for items in "$@"
    do
        if [[ -d "$items" || -f "$items" ]]
        then    
            if rm -rf -- "$items" >/dev/null 2>&1
            then
                ok "$items removed."
            else
                error "$items failed to remove."
                return 1
            fi
        else
            if [[ "$ignore_missing" == "true" ]]
            then
                warn "$items doesn't exist , skipping."
            else
                error "$items doesn't exist to remove."
                return 1
            fi
        fi

    done

    return 0
}

reset_dir()
{
    local ignore_missing="${1:-false}"
    shift 1    

    safe_remove "$ignore_missing" "$@" || return 1
    ensure_dir "$@" || return 1

    return 0
}

########## end ##########

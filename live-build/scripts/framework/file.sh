#!/usr/bin/env bash

########## Copyright C 2026 MIT Emad-ms ##########

# project: yuz-os builder framework
# project git : https://github.com/emad1234-msoudi/Yuz-OS.git

# framework/file.sh
# framework for manage project filesystem

########## shell load ckeck ##########

[[ -n "${BASH_VERSION:-}" ]] ||\
{
    echo "This framework requires bash !"
    return 1 2>/dev/null
}

########## frameware load ckeck ##########

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
            ok "$dir exist"
        else
            error "$dir not exist."
            return 1
        fi
    done

    success "all directories exist."
    return 0
}

exist_file()
{
    local file

    for file in "$@"
    do
        if [[ -f "$file" ]]
        then
            ok "$file exist"
        else
            error "$file not exist."
            return 1
        fi
    done

    success "all files exist."
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
            ok "$dir is already exist."
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
                    error "failed to create $dir"
                    return 1
                fi
            fi
        fi
    done 

    success "all directories safely checked and created."
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
            ok "$file is already exist."
        else
            if [[ -d "$file" ]] 
            then
                error "$file is directory !"
                return 1
            else
                if touch "$file" >/dev/null 2>&1
                then
                    ok "$file created."
                else
                    error "failed to create $file"
                    return 1
                fi  
            fi
        fi
    done 

    success "all files safely checked and created."
    return 0
}

#-> ckeck and try to safe copy files or directories
safe_copy()
{
    local copy_location="${!#}"
    local items

    (( $# >= 2 )) || {
        error "no file selected to copy"
        return 1
    }

    if [ ! -d "$copy_location" ]
    then    
        [[ -f "$copy_location" ]] &&\
            error "$copy_location is file."&&\
            return 1  

        error "$copy_location isn't exist."

        return 1
    fi

    for (( items=1 ; items<$# ; items++ ))
    do
        if [[ -f "${!items}" || -d "${!items}" ]]
        then
            if cp -a "${!items}" "$copy_location" >/dev/null 2>&1
            then
                ok "copyed ${!items} to $copy_location"
            else
                error "failed to copy ${!items} to $copy_location ."
                return 1
            fi
        else
            error "${!items} doesn't exist."
            return 1
        fi
    done

    success "all items copid."
    return 0
}

#-> ckeck and try to safe move files or directories
safe_move()
{
    local move_location="${!#}"
    local items

    (( $# >= 2 )) || {
        error "no file selected to move"
        return 1
    }

    if [ ! -d "$move_location" ]
    then    
        [[ -f "$move_location" ]] &&\
            error "$move_location is file."&&\
            return 1

        error "$move_location isn't exist."

        return 1
    fi

    for (( items=1 ; items<$# ; items++ ))
    do
        if [[ -f "${!items}" || -d "${!items}" ]]
        then
            if mv "${!items}" "$move_location" >/dev/null 2>&1
            then
                ok "moved ${!items} to $move_location"
            else
                error "failed to move ${!items} to $move_location ."
                return 1
            fi
        else
            error "${!items} doesn't exist."
            return 1
        fi
    done

    success "all items moved."
    return 0
}

#-> ckeck and try to safe remove files or directories
safe_remove()
{
    local items
    
    for items in "$@"
    do
        if [[ -d "$items" || -f "$items" ]]
        then    
            if rm -r "$items" >/dev/null 2>&1
            then
                ok "$items removed."
            else
                error "$items failed to remove"
                return 1
            fi
        else
            error "$items isn't exist to remove."
            return 1
        fi

    done

    success "all items removed."
    return 0

}

########## end ##########

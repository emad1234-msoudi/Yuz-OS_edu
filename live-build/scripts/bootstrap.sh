#!/usr/bin/env bash

########## Copyright C 2026 MIT Emad-ms ##########

# project: yuz-os builder framework
# project git : https://github.com/emad1234-msoudi/Yuz-OS_edu

# bootstrap.sh
# loader for load project framework && modules

########## shell load ckeck ##########

[[ -n "${BASH_VERSION:-}" ]] ||\
{
    echo "This framework requires bash !"
    return 1 2>/dev/null
}

set -Eeuo pipefail # set terminal mod

########### variable environment ##########
#--> note :

# tihs variable just for bootstarp
# all variable fully setup in "framework/env.sh" 

#-> scripts tree 

BOOTSTRAP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

framework_dir="${BOOTSTRAP_ROOT}/framework"
framework_file="${framework_dir}/load.list"

module_dir="${BOOTSTRAP_ROOT}/modules"
module_file="${module_dir}/load.list"


########## set framework func ##########

#-> func for load and manage project farmework and modules 
bootstrap_load()
{
    local load_title="$1"
    local load_dir="$2"
    local load_file="$3"
    
    local load_item=""
    local file

    echo "===> Loading $load_title <==="
    echo ""

    [[ ! -f "$load_file" ]] && {
        echo "$load_title list file not found"
        return 1
    }

    while IFS= read -r load_item    
    do
        #-> skip line if started whith "#" or "space" 
        [[ -z "$load_item" ]] && continue
        [[ "$load_item" =~ ^# ]] && continue

        file="$load_dir/${load_item}"
        echo "[ info ] sourcing $load_item"

        #-> source module if exist
        [[ -f "$file" ]] || {
            echo "$load_item not found !"
            return 1
        }

        [[ -r "$file" ]] || {
            echo "$load_item isn't readable"
            return 1
        }

        # shellcheck source=/dev/null
        if source "$file" 
        then
            echo "[ OK ] $load_item sourced ."
        else
            echo "failed to source $load_item $load_title"
            return 1
        fi

    done < "$load_file"

    echo ""
    echo "===> $load_title loaded successfully <==="
}

######## load all module and lib ########

#-> load all framework
bootstrap_load \
    "Framework" \
    "$framework_dir" \
    "$framework_file"

#-> load all modulse
bootstrap_load \
    "Modules" \
    "$module_dir" \
    "$module_file"

######### check #########

#-> setup log 
ui_title_small "$BLUE" "makeing project log"
ensure_dir "$LOG_DIR" "$LOG_SESSION_DIR" "$LOG_MODULE_DIR"  

#-> check project tree
ui_title_small "$BLUE" "checking project tree"
exist_dir "$CONFIG_DIR" "$SCRIPTS_DIR" "$MODULE_DIR" "$FRAMEWORK_DIR" 

########################
#-> note :
# this is just for shellcheck and development

: <<'src'

source ./framework/env.sh
source ./framework/ui.sh
source ./framework/log.sh
source ./framework/runtime.sh
source ./framework/filesystem.sh
source ./framework/check.sh
source ./framework/package.sh

src

########## end ##########

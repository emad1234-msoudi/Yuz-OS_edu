#!/usr/bin/env bash

########## Copyright C 2026 MIT Emad-ms ##########

# project: yuz-os runtime module
# project git : https://github.com/emad1234-msoudi/Yuz-OS_edu

# /opt/yuz-os/scripts/flatpak/flatpak_install.sh
# build time module to install local yuz-os flatpak repository

########### setup environment ##########

set -Eeuo pipefail

#source "../../bootstrap.sh" #-> this source just for development

########## var ##########

readonly flatpak_repo_dir="${DATA_DIR}/flatpak"
readonly flatpak_apps_file="$flatpak_repo_dir/apps.list"

########## func ##########

#-> check neaded to run
flatpak_check()
{
    #-> checking flatapk app exist
    command -v "flatpak" >/dev/null 2>&1  ||\
    {
        die "flatpak not installed. this is needed to add repository."
    }

    #-> checking ostree exist
    command -v "ostree" >/dev/null 2>&1  ||\
    {
        die "ostree not installed. this is needed to add repository."
    }

    #-> checking root 
    if [[ ! "$EUID" -eq 0 ]]
    then
        die "Please run this with sudo."
    fi

    return 0
}

#-> adding needed repositorty
flatpak_add_repo()
{
    #-> check & add flathub repository
    info "Adding flathub repository."

    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || return 1
    flatpak remote-modify --no-filter --collection-id=org.flathub.Stable flathub || return 1

    ok "Flathub repository added successfully."

    #-> check & add yuz-os repository
    info "Adding yuz-os repository."
    
    flatpak remote-add \
        --system \
        --if-not-exists \
        --no-gpg-verify \
        --default-branch=stable \
        --title="Yuz OS Offline Repository" \
        --comment="Offline Flatpak repository for Yuz OS Education Edition" \
        --description="Offline Flatpak repository used by the Yuz OS installer." \
        --homepage="https://github.com/emad1234-msoudi/Yuz-OS_edu" \
        yuz-os \
        "file://$flatpak_repo_dir" \
        || { error "Failed to add yuz-os repository" ; return 1 ;}
    
    flatpak remote-modify --no-gpg-verify yuz-os || return 1

    ok "yuz-os repository added successfully."

    return 0
}

# verifying flatpak repo
flatpak_verify()
{
    #-> data var

    local repo_files=(
        "$flatpak_repo_dir/apps.list"
        "$flatpak_repo_dir/config"
        "$flatpak_repo_dir/summary"
        "$flatpak_repo_dir/summary.idx"
    )

    local item=""

    info "Verifying flatpak repository"

    #-> checking repo files
    printf "%b\n" "   ${BLUE}Checking repo files${NC}"
    for item in "${repo_files[@]}"
    do
        if [[ -f "$item" ]]
        then
            printf "%b\n" "   ${GREEN}✓${NC} $item file exists."
        else
            printf "%b\n" "   ${RED}⨯${NC} Missing repository item : $item ."
            return 1
        fi
    done

    #-> checking repo tree
    printf "%b\n" "   ${BLUE}Checking repository metadata${NC}"
    if \
        flatpak repo --info "$flatpak_repo_dir" && \
        ostree refs --repo="$flatpak_repo_dir" >/dev/null 2>&1
    then
        printf "%b\n" "   ${GREEN}✓${NC} Repository meta data is available."
    else
        printf "%b\n" "   ${RED}⨯${NC} Repository meta data in unavailable."
        return 1
    fi

    ok "Flatpak repository verified."
    return 0
}

#-> script for install flathub app 
flatpak_install()
{
    local flatpak_apps_item=""
    
    info "Installing apps..."

    while IFS= read -r flatpak_apps_item
    do
        #-> skip line if started whith "#" or "space" 
        [[ -z "$flatpak_apps_item" ]] && continue
        [[ "$flatpak_apps_item" =~ ^# ]] && continue

        #-> skip unavailable app
        #if ! flatpak remote-info yuz-os "$flatpak_apps_item" >/dev/null 2>&1 
        #then
        #    echo "[ WARN ] $flatpak_apps_item not found !"
        #    continue
        #fi

        #-> apps process
        info "${YELLOW}Package${NC} → ${GREEN}$flatpak_apps_item${NC}"

        printf "%b\n" "   ⇀${BLUE} Installing on system ... ${NC}"
         
        if \
            flatpak install \
            --system --noninteractive\
            yuz-os "$flatpak_apps_item" -y \
            1>/dev/null
        then 
            printf "%b\n" "   ${GREEN}✓${NC} Installed."
        else
            printf "%b\n" "   ${RED}⨯${NC} Failed to Install."
        fi

    done < "$flatpak_apps_file"
    
    ok "Flatpak apps installed."
    return 0
}

#-> finishing setup for flatpak installer
flatpak_finish_setup()
{
    echo
    info "Finishing up flatpak installer ..."
    
    echo
    echo "${BLUE}Repairing flatpak ...${NC}"
    #-> repairing flatpak system
    if flatpak repair --system
    then
        printf "%b\n" "   ${GREEN}✓${NC} Flatpak repair completed."
    else
        printf "%b\n" "   ${YELLOW}!${NC} Flatpak repair failed."
    fi

    #-> Rmoving unused apps
    echo
    echo "${BLUE}Removing unused apps ...${NC}" 
    
    if flatpak uninstall --system --unused -y
    then
        printf "%b\n" "   ${GREEN}✓${NC} Unused flatpak apps removed."
    else
        printf "%b\n" "   ${YELLOW}!${NC} Failed to remove unused flatpak apps."
    fi

    #-> remove old 
    echo
    echo "${BLUE}Removing offline repository ...${NC}"

    if safe_remove "$flatpak_repo_dir"
    then
        printf "%b/n" "   ${GREEN}✓${NC} Flatpak repository removed."
    else
        printf "%b/n" "   ${RED}⨯${NC} Failed to remove flatpak repository."
        return 1
    fi

    ok "Flatpak installer Finished."
    return 0
}

########## main flatpak ##########
#-> main for load flatpak func

main_flatpak_install()
{
    flatpak_check        || return 1
    flatpak_add_repo     || return 1
    flatpak_verify       || return 1
    flatpak_install      || return 1
    flatpak_finish_setup || return 1

    return 0
}

#main_flatpak_install "$@"

########## end ##########

#!/usr/bin/env bash

########## Copyright C 2026 MIT Emad-ms ##########

# project: yuz-os builder module
# project git : https://github.com/emad1234-msoudi/Yuz-OS_edu

# module/flatpak/flatpak.sh
# module for make local flatpak repo

########### setup environment ##########

# source "../../bootstrap.sh" #-> tihs source just for development

set -Eeuo pipefail

########## var ##########

#-> repo dir
readonly flatpak_repo_build_dir="$CACHE_DIR/flatpak"
readonly flatpak_repo_build_main_dir="$flatpak_repo_build_dir/.ostree/repo"
readonly flatpak_repo_iso_dir="$CHROOT_YUZ_DIR/flatpak"

#-> app list
readonly flatpak_apps_file="$MODULE_DIR/flatpak/apps.list"

#-> required var
readonly flatpak_required_disk_space_gb=5

########## func ##########

#-> add & check requirements flathub repo ####
flatpak_check()
{
    ui_title_small "$BLUE" "Checking flatpak requirements"

    exist_file "$flatpak_apps_file" || return 1

	#check system root 
    if ! check_root >/dev/null 2>&1 ; then die "Required run this with sudo." ; fi  

    #check system network connection
    check_network 1 dl.flathub.org || die "Network connection required"

    #check & install neaded packages
    install_require "ostree" "flatpak"

    # chek system free space
    if ! check_disk_space "$flatpak_required_disk_space_gb" >/dev/null 2>&1
    then 
        die "At least ${flatpak_required_disk_space_gb} GB of free disk space is required."
	fi

    #check & add flathub repo
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || return 1
    flatpak remote-modify --no-filter --collection-id=org.flathub.Stable flathub || return 1

    ui_title_small_close "$BLUE" "Checking flatpak requirements completed."
    return 0
}


#-> clean other build files
flatpak_repo_prepare()
{
    ui_title_small "$BLUE" "Cleaning previous repository"

    if [[ -d "$flatpak_repo_iso_dir" ]]
    then
        if ask "Do you wnat to clean previous repository ?"
        then
            reset_dir true "$flatpak_repo_build_dir" || return 1
            reset_dir true "$flatpak_repo_iso_dir"   || return 1
            
            ui_title_small_close "$BLUE" "Previous repository keeped"
            return 2
        fi 
    fi

    ok "Use previous repository fo build"
    ui_title_small_close "$BLUE" "Cleanig previous repository completed"
    return 0
}

#->this script it's main script for build 
flatpak_repo_build()
{
    local flatpak_apps_item

    ui_title_small "$BLUE" "Creating offline flatpak repository"

    while IFS= read -r flatpak_apps_item
    do

        #-> skip line if started whith "#" or "space" 
        [[ -z "$flatpak_apps_item" ]] && continue
        [[ "$flatpak_apps_item" =~ ^# ]] && continue

        #-> install app if exist
        if flatpak remote-info flathub "$flatpak_apps_item" >/dev/null 2>&1 
        then

            info "${YELLOW}Package${NC} → ${GREEN}$flatpak_apps_item${NC}"

            #-> this part check app installation on host system
            printf "%b\n" "   ⇀${BLUE} Installing ... ${NC}"

            run_task \
                ""  "$LOG_EMPTY" \
                flatpak install \
                    --system --noninteractive --or-update \
                    flathub "$flatpak_apps_item" -y

            printf "%b\n" "   ✓${GREEN} Installed. ${NC}"

            #-> this part export apps on host system to repository
            printf  "%b\n" "   ⇀${BLUE} Exporting to repo ... ${NC}"
            
            run_task \
                "" "$LOG_EMPTY" \
                flatpak create-usb \
                    --system --allow-partial \
                    "$flatpak_repo_build_dir" \
                    "$flatpak_apps_item" \
                    >/dev/null

            printf "%b\n" "   ✓${GREEN} Exported to repo. ${NC}"
       else
            warn "$flatpak_apps_item not found !"
            continue
        fi
    done < "$flatpak_apps_file"

    ui_title_small_close "$BLUE" "Flatpak repository created"
    return 0
}

#-> update repo 
flatpak_repo_update()
{
    ui_title_small "$BLUE" "Updating flatpak repo tree"

    #-> update changes to repo
    run_task \
        "Updating flatpak repository"  "$LOG_EMPTY" \
        flatpak build-update-repo \
            --title="yuz-os offline repo" \
            --comment="offline flatpak repo for yuz-os edu" \
            --authenticator-name="Emad-ms" \
            --authenticator-install \
            "$flatpak_repo_build_main_dir"

    ui_title_small_close "$BLUE" "Flatpak repo tree updated"
    return 0
}

#-> move flatpak new repo to iso
flatpak_repo_move()
{ 
    ui_title_small "$BLUE" "Moving flatpak repository to iso"

    run_task \
        "Copying repository into iso" "$LOG_EMPTY" \
        safe_copy "$flatpak_repo_build_main_dir"/* "$flatpak_repo_iso_dir"
        
    run_task \
        "Copying repository apps.list to iso" "$LOG_EMPTY" \
        safe_copy "$flatpak_apps_file" "$flatpak_repo_iso_dir"

    ui_title_small_close "$BLUE" "Flatpak repository moved to iso"
    return 0
}

########## main flatpak ##########
#-> main for load flatpak func
 
main_flatpak()
{
    flatpak_check || return 1

    flatpak_repo_prepare

    if (( $? == 2 ))
    then
        flatpak_repo_build  || return 1
        flatpak_repo_update || return 1
        flatpak_repo_move   || return 1
        return 0
    else
        return 0
    fi
}

#main_flatpak "$@"

########## end ##########

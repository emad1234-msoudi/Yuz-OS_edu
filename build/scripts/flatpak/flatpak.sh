#!/bin/bash

########## Copyright C 2026 MIT Emad-ms ##########

# project: yuz-os builder
# project git : https://github.com/emad1234-msoudi/Yuz-OS.git

##### this script made for make local flatpak repo #####

######### setup ##########

#set -eEuo pipefail # set terminal mod 

source "$PROJECT_ROOT/scripts/lib/terminal-set.sh" # import terminal lib

check_root #chek system root    

########## flatpak var ##########

#-> repo dir
flatpak_repo="$PROJECT_ROOT/scripts/flatpak/repo"
rm -rf "$flatpak_repo"
mkdir -p "$flatpak_repo"

flatpak_repo_iso="$yuz_clone/flatpak"
rm -rf "$flatpak_repo_iso"
mkdir -p "$flatpak_repo_iso"

flatpak_repo_update="$flatpak_repo/.ostree/repo/"

#-> app list

flatpak_apps="$PROJECT_ROOT/scripts/flatpak/apps.list"


flatpak_apps_list=""

########## func ##########

#-> add requirements flathub repo ####
flatpak_add_repuirments()
{
    install_require "ostree" "flatpak"  
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak remote-modify --collection-id=org.flathub.Stable flathub
}

#->this script it's main script for build 
flatpak_make()
{
    while read -r flatpak_apps_list
    do

        #-> skip line if started whith "#" or "space" 
        [[ -z "$flatpak_apps_list" ]] && continue
        [[ "$flatpak_apps_list" =~ ^# ]] && continue

        #-> install app if exist
        if flatpak remote-info flathub "$flatpak_apps_list" >/dev/null 2>&1 
        then
            ok "$flatpak_apps_list exist"
            Run "install $flatpak_apps_list"  "$debug_empty" \
            flatpak install \
            --system --noninteractive --or-update \
            flathub "$flatpak_apps_list" -y

            #-> this part add downloaded app on host system to repo
            Run "adding $flatpak_apps_list to repo ..." "$debug_empty" \
                flatpak --system --allow-partial create-usb \
                "$flatpak_repo" \
                "$flatpak_apps_list"

            
        else
            warn "$flatpak_apps_list not found !"
        fi

    done < "$flatpak_apps"
}

flatpak_update_config()
{
    #-> update changes to repo
    flatpak build-update-repo \
        --title="yuz-os offline repo" \
        --comment="offline flatpak repo for yuz-os edu" \
        --authenticator-name="Emad-ms" \
        --authenticator-install \
        "$flatpak_repo_update"
}

flatpak_move()
{ 
    #-> move repo
    mv "$flatpak_repo_update"/* "$flatpak_repo_iso"
    mv ./"$flatpak_apps" "$flatpak_repo_iso"
    
    #-> clean all old repo
    [[ -d "$flatpak_repo" ]] && rm -rf "$flatpak_repo"  
}

########## main flatpak ##########
#-> main for load flatpak func
 
main_flatpak()
{
    Run "Install requirments" "$debug_flatpak" flatpak_add_repuirments
    Run "Download repo" "$debug_flatpak" flatpak_make
    Run "Update && makeing repo" "$debug_flatpak" flatpak_update_config
    Run "Move repo" "$debug_flatpak" flatpak_move
}

#main_flatpak "$@"
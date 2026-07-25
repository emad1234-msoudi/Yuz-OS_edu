#!/usr/bin/env bash

########## Copyright C 2026 MIT Emad-ms ##########

# project: yuz-os builder module
# project git : https://github.com/emad1234-msoudi/Yuz-OS_edu

# module/flatpak/flatpak_build.sh
# module for build flatpak local flatpak repository

########### setup environment ##########

# source "../../bootstrap.sh" #-> tihs source just for development

set -Eeuo pipefail

########## var ##########

#-> repo dir
readonly repo_system_dir="/var/lib/flatpak/repo"
readonly repo_build_dir="$CACHE_DIR/flatpak"
readonly repo_iso_dir="$CHROOT_YUZ_DIR/data/flatpak"

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

	#-> check system root 
    if ! check_root >/dev/null 2>&1 ; then die "Required run this with sudo." ; fi  

    #-> check system network connection
    check_network 1 flathub.org || die "Network connection required"

    #-> check & install needed packages
    install_require "ostree" "flatpak"

    #-> chek system free space
    if ! check_disk_space "$flatpak_required_disk_space_gb" >/dev/null 2>&1
    then 
        die "At least ${flatpak_required_disk_space_gb} GB of free disk space is required."
	fi

    #-> check & add flathub repo
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || return 1
    flatpak remote-modify --no-filter --collection-id=org.flathub.Stable flathub || return 1

    ui_title_small_close "$BLUE" "Checking flatpak requirements completed."
    return 0
}

#-> check app exists in flatpak 
flatpak_check_app()
{
    local app="$1"

    if flatpak remote-info flathub "$app" 1>/dev/null 
    then
        return 0
    else
        warn "$app not found !"
        return 1
    fi
}

#-> install app on host system
flatpak_host_install()
{
    local app_id="$1"

    printf "%b\n" "   ⇀${BLUE} Installing on host system ... ${NC}"

    if \
        flatpak install \
            --system --noninteractive --or-update \
            flathub "$app_id" -y
    then
        printf "%b\n" "   ✓${GREEN} Installed. ${NC}"
        return 0
    else
        printf "%b\n" "   ⨯${RED} Failed to Install. ${NC}"
        return 1
    fi

}

#-> check and load mata data app
# use flatpak information command to get it

flatpak_get_depends()
{
    local app_id="$1"

    unset flatpak_refs
    declare -gA flatpak_refs=()
    

    local line
    local key
    local value

    while IFS= read -r line
    do
        #-> skip empty line
        [[ -z "$line" ]] && continue 

        key="${line%%: *}"
        value="${line#*: }"
        key="$(xargs <<< "$key")"
        case "$key" in
            Runtime)
            if [[ -n "${flatpak_refs[runtime]:-}" ]]
            then
                flatpak_refs[runtime]+=";"
            fi
            flatpak_refs[runtime]+="runtime/$value"
            ;;

            Sdk)
            if [[ -n "${flatpak_refs[sdk]:-}" ]]
            then
                flatpak_refs[sdk]+=";"
            fi
            flatpak_refs[sdk]+="runtime/$value"
            ;;

            Extension)
            if [[ -n "${flatpak_refs[extension]:-}" ]]
            then
                flatpak_refs[extension]+=";"
            fi
            flatpak_refs[extension]+="$value"
            ;;
        esac

    done < <(
        flatpak info --show-extensions "$app_id" 
    )

    flatpak_refs[app]="$(flatpak info --show-ref "$app_id")"
    flatpak_refs[origin]="$(flatpak info --show-origin "$app_id")"
}

#-> commit apps on host system to repository
# use flathub repositroy on system app
# to commit & add to build repository

flatpak_commit_refs()
{
    local ref_dst="$1"
    local ref_src="$2"

    if \
    flatpak build-commit-from \
        --src-repo="$repo_system_dir" \
        --src-ref="${ref_src}" \
        "$repo_build_dir" \
        "${ref_dst}" \
        >/dev/null 2>&1
    then
        printf "%b\n" "   ✓${GREEN} Exported to repo. ${NC}"
        return 0
    else
        printf "%b\n" "   ⨯${RED} Failed to export. ${NC}"
        return 1
    fi
}

flatpak_commit_dependencies()
{
    #-> meta data keys
    # Only fields required for repository export
    local meta_key
    local meta_keys=(
        app
        runtime
        sdk
        extension
    )

    #-> meta data values
    # all get fome mata data keys
    #  use for commit into reository
    local meta_value
    local meta_values=()

    #-> get meta data from app
    local app_id="$1"

    flatpak_get_depends "$app_id"



    #-> loop for loads all keys
    printf "%b\n" "   ⇀${BLUE} exporting $app_id to repo...${NC}"
    for meta_key in "${meta_keys[@]}"
    do
        #-> skip empty keys
        [[ -z "${flatpak_refs[$meta_key]:-}" ]] && continue

        printf "%b\n" "   ⇀${BLUE}${meta_key} : ${NC}"

        #-> sort sprited values whith ';' and go to array
        # ssv semicolon sorted value
        
        meta_values=() # clean old values

        IFS=';' read -ra meta_values <<< "${flatpak_refs[$meta_key]}"

        for meta_value in "${meta_values[@]}"
        do
            printf "%b\n" "    $meta_value ..."

            #-> check needed depends , whith installed depends in host system
            if ! ostree refs --repo="$repo_system_dir" | grep -- "$meta_value" >/dev/null 2>&1  
            then
                printf "%b\n" "    Not available."
                continue
            fi

            #-> skip to commit exported refrance
            if [[ -n "${exported[$meta_value]:-}" ]]
            then
                printf "%b\n" "    Allready exported."
                continue
            fi

            #-> commit refrance
            if flatpak_commit_refs "${meta_value}" "${flatpak_refs[origin]}:${meta_value}" 
            then
                exported[$meta_value]="$meta_key"
                continue
            else
                if [[ "$meta_value" == *".Locale"* ]]
                then
                    printf "%b\n" "   !${YELLOW} this isn't needed , skiping ... ${NC}"
                    continue
                else
                    printf "%b\n" "   ⨯${RED} this is needed ${NC}"
                    return 1
                fi
            fi

        done
    done

    printf "%b\n" "   ✓${GREEN} $app_id exported to repo. ${NC}"
    return 0
}

#->this script it's main script for build 
flatpak_repo_build()
{
    local flatpak_apps_item
    
    local flatpak_apps_number=0

    local process=0
    local success=0
    local failed=0
    local skipped=0

    declare -gA exported=()

    ui_title_small "$BLUE" "Creating offline flatpak repository"

    #-> Generate standard repository with ostree
    info "Generateing repository tree"

    if ostree init --repo="${repo_build_dir}" --mode=archive-z2
    then
        ok "Repository tree generated."
    else
        error "Failed to generate repository tree."
        return 1
    fi

    #-> find number of processing apps
    while IFS= read -r flatpak_apps_item
    do
        #-> skip line if started whith "#" or "space"
        [[ -z "$flatpak_apps_item" ]] && continue
        [[ "$flatpak_apps_item" =~ ^# ]] && continue
        (( flatpak_apps_number++ ))

    done < "$flatpak_apps_file"

    #-> apps process
    while IFS= read -r flatpak_apps_item
    do
        #-> skip line if started whith "#" or "space" 
        [[ -z "$flatpak_apps_item" ]] && continue
        [[ "$flatpak_apps_item" =~ ^# ]] && continue

        #-> skip app if not exist
        if flatpak_check_app "$flatpak_apps_item"
        then
            (( process++ ))
        else
            (( skipped++ ))
            continue
        fi

        info "${YELLOW}Package ${process}${NC} → ${GREEN}$flatpak_apps_item${NC}"

        #-> install app on system host
        if flatpak_host_install "$flatpak_apps_item"
        then
            #-> commit app ro repo
            if flatpak_commit_dependencies "$flatpak_apps_item"
                then
                    (( success++ ))
                    continue
                else
                    (( failed++ ))
                    return 1
                fi
        else
            (( failed++ ))
            return 1            
        fi

    done < "$flatpak_apps_file"

    #-> install other repository requirements
    local exported_key
    local exported_value
    
    info "${BLUE}Commit other reqiuremnts ${NC}:"

    for exported_value in "${!exported[@]}"
    do
        #-> skip other progress
        exported_key="${exported[$exported_value]}"

        [[ "${exported_key}" == "runtime" || "$exported_key" == "sdk" ]] || continue

        (( process++ ))

        info "${YELLOW}Package ${process}${NC} → ${GREEN}$exported_value${NC}"
        #-> commit app ro repo
        if flatpak_commit_dependencies "$exported_value"
        then
            (( success++ ))
            continue
        else
            (( failed++ ))
            return 1
        fi

    done

    #-> build summary

    ui_title_small "$BLUE" "Summary : "

    printf "%b\n" "${BLUE} Packages ${NC}: $flatpak_apps_number"
    printf "%b\n" "${BLUE} Packages found ${NC}: $process"
    printf "%b\n" "${GREEN} Succeeded ${NC}: $success"
    printf "%b\n" "${YELLOW} Skipped ${NC}: $skipped"
    printf "%b\n" "${RED} Failed ${NC}: $failed "
 
    ui_title_small_close "$BLUE" "Flatpak repository created"
    return 0
}

#-> finalizeing repo
# update flatpak : metadate summary
# make my repo informaition

flatpak_repo_finalize()
{
    ui_title_small "$BLUE" "Finalizing flatpak repo tree"

    #-> update changes to repo
    run_task \
        "Updating flatpak repository"  "$LOG_EMPTY" \
        flatpak build-update-repo \
            --generate-static-deltas \
            --deploy-sideload-collection-id \
            --default-branch=stable \
            --prune \
            --title="Yuz OS Offline Repository" \
            --comment="Offline Flatpak repository for Yuz OS Education Edition" \
            --homepage="https://github.com/emad1234-msoudi/Yuz-OS_edu" \
            --description="Offline Flatpak repository used by the Yuz OS installer." \
            "$repo_build_dir" \
            >/dev/null 2>&1

    ui_title_small_close "$BLUE" "Flatpak repo tree updated"
    return 0
}

# verifying flatpak repo
flatpak_verify()
{
    #-> data var

    local repo_files=(
        "$repo_build_dir/config"
        "$repo_build_dir/summary"
        "$repo_build_dir/summary.idx"
    )

    local item=""

    ui_title_small "$BLUE" "Verifying flatpak repository"

    #-> checing repository directory

    exist_dir "$repo_build_dir" || return 1

    #-> checking repo files
    info "Checking repo files"
    for item in "${repo_files[@]}"
    do
        if [[ -f "$item" ]]
        then
            ok "$item file exists."
        else
            error "Missing repository item : $item."
            return 1
        fi
    done

    #-> checking repo tree
    info "Checking repository metadata"
    if \
        flatpak repo --info "$repo_build_dir"  && \
        ostree refs --repo="$repo_build_dir" >/dev/null 2>&1
    then
        ok "Repository meta data is available."
    
    else
        error "Repository meta data in unavailable."
        return 1
    fi

    ui_title_small "$BLUE" "Flatpak repository verified."
    return 0
}

#-> move flatpak new repo to iso
flatpak_repo_publish()
{ 
    ui_title_small "$BLUE" "Moving flatpak repository to iso"

    run_task \
        "Copying repository into iso" "$LOG_EMPTY" \
        safe_copy "$repo_build_dir"/* "$repo_iso_dir"
        
    run_task \
        "Copying repository apps.list to iso" "$LOG_EMPTY" \
        safe_copy "$flatpak_apps_file" "$repo_iso_dir"

    ui_title_small_close "$BLUE" "Flatpak repository moved to iso"
    return 0
}

flatpak_repo_build_pipeline()
{
    #-> prepare needed directory

    reset_dir true "$repo_build_dir" || return 1
    
    #-> start build

    flatpak_repo_build    || return 1
    flatpak_repo_finalize || return 1
    flatpak_verify        || return 1

    #-> publish repo
    reset_dir true "$repo_iso_dir"   || return 1
    flatpak_repo_publish  || return 1
}

#-> prapre flatpak builder environment
flatpak_repo_prepare()
{
    ui_title_small "$BLUE" "Prepare build repository"

    #-> check used repository in iso system
    if [[ -d "$repo_iso_dir" ]]
    then
        info "Previous repository now in iso."
        if ask "Reuse existing repository from ISO ?"
        then
            ok "Use previous repository for build."
            ui_title_small_close "$BLUE" "Previous repository kept."
            return 0
        else   
            flatpak_repo_build_pipeline || return 1           
            
            ui_title_small_close "$BLUE" "Build repository successfully completed."
            return 0
        fi 
    fi  

    #-> check chached repository
    if [[ -d "$repo_build_dir" && ! -d "$repo_iso_dir" ]]
    then
        info "Previous repository cached , but not used in iso ."
        if ask "Reuse cached repository ?"
        then
            #-> reset iso repository
            reset_dir true "$repo_iso_dir"   || return 1

            #-> verify cached repo            
            if flatpak_verify
            then
                #-> publish cached repo
                flatpak_repo_finalize || return 1
                flatpak_repo_publish  || return 1

                ui_title_small_close "$BLUE" "Used previous repository from cache"
                return 0
            else
                #-> rebuild broken repo  
                error "Cached repository is broken."
                if ask "Do you want start build ?"
                then
                    flatpak_repo_build_pipeline || return 1                    

                    ui_title_small_close "$BLUE" "Build repository successfully completed."
                    return 0
                else
                    info "Build cancelled by user."
                    ui_title_small_close "$BLUE" "Repository build cancelled."
                    return 0
                fi
            fi
        else
            flatpak_repo_build_pipeline || return 1

            ui_title_small_close "$BLUE" "Build repository successfully completed."
            return 0
        fi
    fi

    #-> make repo if no chache & iso exist

    if [[ ! -d "$repo_build_dir" && ! -d "$repo_iso_dir" ]]
    then
        info "No cached repository found."
        info "No iso repository found."
        info "Starting a build..."
         
        flatpak_repo_build_pipeline || return 1

        ui_title_small_close "$BLUE" "Build repository successfully completed."
        return 0
    fi
}

########## main flatpak ##########
#-> main for load flatpak func

main_flatpak()
{
    flatpak_check || return 1
    flatpak_repo_prepare || return 1
}

#main_flatpak "$@"

########## end ##########

#!/usr/bin/env bash

########## Copyright C 2026 MIT Emad-ms ##########

# project: yuz-os runtime module
# project git : https://github.com/emad1234-msoudi/Yuz-OS_edu

# /opt/yuz-os/scripts/style/style.sh

# build time module for GNOME defaults on Debian 13 / GNOME 48
# This script installs user-changeable desktop defaults for GNOME, libadwaita, and Qt.
# It does not lock settings, so users can still modify them later.

########### setup environment ##########

set -Eeuo pipefail

#source "../../bootstrap.sh" #-> this source just for development
#source "./style.conf"       #-> this source just for development

########## func ##########

#-> check neaded to run
style_check()
{
    #-> checking root
    if [[ ! "$EUID" -eq 0 ]]
    then
        die "Please run this with sudo."
    fi

    #-> source style.conf 
    if [[ -f "$MODULE_DIR/style/style.conf" ]]
    then
        source "$MODULE_DIR/style/style.conf"
    else
        die "style.conf file not found."
    fi

    #-> checking needed optaional command
    info "Checking required packages"
    for pkg in "${REQUIRED_PACKAGES[@]}"
    do
        if ! dpkg -s "$pkg" >/dev/null 2>&1
        then
            die "Package is not installed: ${pkg}"
        fi
    done

    return 0
}

# verifying style data files
style_verify()
{
    #-> data var

    local item=""

    info "Verifying style data"

    #-> checking data files
    printf "%b\n" "   ${BLUE}Checking repo files${NC}"
    
    for item in "${STYLE_DATA_FILES[@]}"
    do
        if [[ -f "$item" ]]
        then
            printf "%b\n" "   ${GREEN}✓${NC} $item file exists."
        else
            printf "%b\n" "   ${RED}⨯${NC} Missing repository item : $item ."
            return 1
        fi
    done

    ok "Style data verified."
    return 0
}

#-> Prepare environment directories
style_prepare()
{
    info "Preparing target directories"
    
    install -d -m 0755 "${DCONF_PROFILE_DIR}"   || return 1
    install -d -m 0755 "${DCONF_DB_DIR}"        || return 1
    install -d -m 0755 "${ENVIRONMENT_DIR}"     || return 1
    install -d -m 0755 "${SKEL_DIR}"            || return 1
    install -d -m 0755 "${GTK4_SKEL_DIR}"       || return 1
    install -d -m 0755 "${GTK3_SKEL_DIR}"       || return 1

    ok "Target directories prepared."
    return 0
}

#-> Deploy style assets
style_deploy()
{
    info "Starting style assets deployment."

    #-> deploy GTK theme
    if unzip_file "$THEME_DATA" "$THEME_TARGET_DIR" 
    then
        ok "GTK theme assets deployed."
    else
        error "Failed to deploy GTK theme assets."
        return 1
    fi    

    #-> deploy icon theme
    if unzip_file "$ICON_DATA" "$ICON_TARGET_DIR"
    then
        ok "Icon theme assets deployed."
    else
        error "Failed to deploy icon theme assets."
        return 1
    fi

    #-> deploy cursor theme
    if unzip_file "$CURSOR_DATA" "$CURSOR_TARGET_DIR"  
    then
        ok "Cursor theme assets deployed."
    else
        error "Failed to deploy cursor theme assets."
        return 1
    fi

    #-> deploy wallpapers
    if unzip_file "$WALLPAPER_DATA" "$WALLPAPER_TARGET_DIR"
    then
        ok "Wallpaper assets deployed."
    else
        error "Failed to deploy wallpaper assets."
        return 1
    fi

    #-> deploy fonts
    if unzip_file "$FONT_DATA" "$FONT_TARGET_DIR"
    then
        ok "Font assets deployed."
    else        
        error "Failed to deploy font assets."
        return 1
    fi

    #-> rebuild font cache
    if fc-cache -f "$FONT_TARGET_DIR" >/dev/null 2>&1
    then
        ok "Font cache updated successfully."
    else
        error "Failed to update font cache for $FONT_TARGET_DIR."
        return 1
    fi

    ok "All style assets were deployed successfully."
    return 0
}


#-> set dconf profile
style_dconf_config()
{
    info "Writing dconf profile"

    if write_text_file "${DCONF_PROFILE_FILE}" 0644 <<'EOF'
user-db:user
system-db:local
EOF
    then
        info "Dconf profile Writed."
        return 0
    else
        error "Failed to write dconf profile."
        return 1
    fi
}

#-> prepare GNOME Shell extensions list for dconf
style_extensions_config()
{
    local uuid
    local enabled_exts=""
    local extension_dir

    info "Preparing GNOME Shell extensions."

    #-> no extension configured
    if (( ${#EXTENSIONS_LIST[@]} == 0 ))
    then
        ENABLED_EXTENSIONS="[]"
        warn "No GNOME Shell extensions configured."
        return 0
    fi

    #-> validate extensions and build dconf array
    for uuid in "${EXTENSIONS_LIST[@]}"
    do
        extension_dir="${EXTENSIONS_TARGET_DIR}/${uuid}"

        if [[ -d "$extension_dir" ]]
        then
            ok "GNOME Shell extension found: $uuid"
            enabled_exts+="'${uuid}',"            
        else
            error "Required GNOME Shell extension is missing: $uuid"
            return 1
        fi
    done

    #-> convert to dconf array format: ['uuid1', 'uuid2']
    ENABLED_EXTENSIONS="[${enabled_exts%,}]"
    declare -g ENABLED_EXTENSIONS

    ok "GNOME Shell extensions prepared: $ENABLED_EXTENSIONS"
    return 0
}

#->  GNOME defaults
style_gnome_config()
{
    info "Writing GNOME desktop defaults"

    if ! write_text_file "${DCONF_DEFAULTS_FILE}" 0644 <<EOF
[org/gnome/desktop/interface]
gtk-theme='${THEME_SELECTED_NAME}'
icon-theme='${ICON_SELECTED_NAME}'
cursor-theme='${CURSOR_SELECTED_NAME}'
color-scheme='${COLOR_SCHEME}'

[org/gnome/desktop/wm/preferences]
theme='${THEME_SELECTED_NAME}'
button-layout=':minimize,maximize,close'

[org/gnome/desktop/background]
picture-uri='${WALLPAPER_LIGHT_URI}'
picture-uri-dark='${WALLPAPER_DARK_URI}'
picture-options='${WALLPAPER_OPTIONS}'

[org/gnome/desktop/input-sources]
sources=${INPUT_SOURCES}
xkb-options=${XKB_OPTIONS}

[org/gnome/shell]
enabled-extensions=${ENABLED_EXTENSIONS}

[org/gnome/desktop/screensaver]
picture-uri='${WALLPAPER_LIGHT_URI}'


[org/gnome/shell/extensions/user-theme]
name='${THEME_SELECTED_NAME}'
EOF
    then
        error "Failed to write GNOME desktop defaults dconf file." 
        return 1
    fi

    run_task \
    "Compiling dconf database" "$LOG_EMPTY" \
    dconf update

    ok "GNOME desktop defaults Writed."
    return 0
}


#-> libadwaita / GTK4 seeding for new users
# GNOME/libadwaita does not reliably follow gtk-theme for all GTK4/libadwaita apps.
# To provide a visual default for newly created users, copy GTK4 theme assets into /etc/skel.
# This remains user-changeable because it only seeds files for future home directories.

style_libadwaita_config()
{
    info "Installing GTK4 theme overrides into /etc/skel"

    if [[ -d "${GTK4_THEME_DIR}" ]]
    then
        #-> copy theme assets
        if [[ -d "${GTK4_THEME_DIR}/assets" ]]
        then
            safe_remove "${GTK4_SKEL_DIR}/assets" || return 1
            safe_copy "${GTK4_THEME_DIR}/assets" "${GTK4_SKEL_DIR}/assets" || return 1
        else
            warn "GTK4 theme assets directory not found: ${GTK4_THEME_DIR}/assets"
        fi

        #-> copy "gtk.css" main theme base
        if [[ -f "${GTK4_THEME_DIR}/gtk.css" ]]; then
            safe_copy "${GTK4_THEME_DIR}/gtk.css" "${GTK4_SKEL_DIR}/gtk.css" || return 1
            chmod 0644 "${GTK4_SKEL_DIR}/gtk.css" || return 1
        else
            warn "GTK4 gtk.css not found: ${GTK4_THEME_DIR}/gtk.css"
        fi

        #-> copy "gtk-dark.css" main dark theme base
        if [[ -f "${GTK4_THEME_DIR}/gtk-dark.css" ]]; then
            safe_copy "${GTK4_THEME_DIR}/gtk-dark.css" "${GTK4_SKEL_DIR}/gtk-dark.css" || return 1
            chmod 0644 "${GTK4_SKEL_DIR}/gtk-dark.css" || return 1
        else
            warn "GTK4 gtk-dark.css not found: ${GTK4_THEME_DIR}/gtk-dark.css"
        fi
    else
        warn "GTK4 theme directory not found, skipping GTK4 overrides: ${GTK4_THEME_DIR}"
        return 0
    fi

    ok "GTK4 theme overrides Installed."
    return 0
}


#-> Optional GTK3 fallback for non-GNOME-aware applications
# Most GNOME applications will honor dconf defaults, so GTK3 fallback is usually unnecessary.
# This file is intentionally minimal and acts only as a compatibility fallback.

style_gtk3_config()
{
    info "Writing GTK3 fallback settings"
    if write_text_file \
    "${GTK3_SKEL_DIR}/settings.ini" 0644 <<EOF
[Settings]
gtk-theme-name=${THEME_SELECTED_NAME}
gtk-icon-theme-name=${ICON_SELECTED_NAME}
gtk-cursor-theme-name=${CURSOR_SELECTED_NAME}
EOF
    then
        ok "GTK3 fallback settings writed."
        return 0
    else
        error "Failed to write GTK3 fallback settings"
        return 1
    fi
}

#-> Qt integration
# qgnomeplatform lets Qt applications integrate better with GNOME settings.
# adwaita-qt provides a Qt widget style closer to GNOME/Adwaita.

style_qt_config()
{
    info  "Writing Qt environment defaults" 
    if write_text_file \
    "${QT_ENV_FILE}" 0644 <<'EOF'
QT_QPA_PLATFORMTHEME=gnome
QT_STYLE_OVERRIDE=adwaita
EOF
    then
        ok "Qt environment defaults writed."
        return 0
    else
        error "Failed to write Qt environment defaults."
        return 1
    fi
}

#-> configure Flatpak desktop defaults
style_flatpak_config()
{
    local flatpak_override_file="/var/lib/flatpak/overrides/global"
    local -a context_entries=(
        "filesystems=xdg-config/gtk-3.0:ro;xdg-config/gtk-4.0:ro"
    )
    local -a env_entries=(
        "GTK_THEME=${THEME_SELECTED_NAME}"
        "ICON_THEME=${ICON_SELECTED_NAME}"
        "XCURSOR_THEME=${CURSOR_SELECTED_NAME}"
    )
    local context_block=""
    local env_block=""
    local entry

    info "Writing Flatpak overrides"

    install -d -m 0755 "/var/lib/flatpak/overrides" || {
        error "Failed to create Flatpak overrides directory"
        return 1
    }

    for entry in "${context_entries[@]}"
    do
        context_block+="${entry}"$'\n'
    done

    for entry in "${env_entries[@]}"
    do
        env_block+="${entry}"$'\n'
    done

    if write_text_file "${flatpak_override_file}" 0644 <<EOF
[Context]
${context_block%$'\n'}

[Environment]
${env_block%$'\n'}
EOF
    then
        ok "Flatpak GTK config and theme environment overrides written."
        return 0
    else
        error "Failed to write Flatpak overrides"
        return 1
    fi
}

#-> Fix permissions
style_fix_perm()
{
    info "Fixing directory permissions"

    install -d -m 0755 "${SKEL_DIR}/.config" || return 1

    chmod 0755 "${SKEL_DIR}" || return 1
    chmod 0755 "${SKEL_DIR}/.config" || return 1
    chmod 0755 "${GTK4_SKEL_DIR}" || return 1
    chmod 0755 "${GTK3_SKEL_DIR}" || return 1

    if [[ -d "${GTK4_SKEL_DIR}/assets" ]]
    then
        find "${GTK4_SKEL_DIR}/assets" -type d -exec chmod 0755 {} + || return 1
        find "${GTK4_SKEL_DIR}/assets" -type f -exec chmod 0644 {} + || return 1
    fi

    ok "Directory permissions fixed."
    return 0
}

#-> clean stlye data 
style_clean_data()
{
    info "Cleaning style data"

    for item in "${STYLE_DATA_DIRS[@]}"
    do
        safe_remove -i "${item}" || return 1
    done

    ok "Style data cleaned."
    return 0
}

#-> Build summary
style_summary()
{
    printf '\n'
    printf 'Yuz desktop defaults installed:\n'
    printf '%b\n' "  ${BLUE}GTK theme:        ${NC}${THEME_SELECTED_NAME}"
    printf '%b\n' "  ${BLUE}Icon theme:       ${NC}${ICON_SELECTED_NAME}"
    printf '%b\n' "  ${BLUE}Cursor theme:     ${NC}${CURSOR_SELECTED_NAME}"
    printf '%b\n' "  ${BLUE}Color scheme:     ${NC}${COLOR_SCHEME}"
    printf '%b\n' "  ${BLUE}Wallpaper light:  ${NC}${WALLPAPER_LIGHT_URI}"
    printf '%b\n' "  ${BLUE}Wallpaper dark:   ${NC}${WALLPAPER_DARK_URI}"
    printf '%b\n' "  ${BLUE}Extensions:       ${NC}${ENABLED_EXTENSIONS:-[]}"
    printf '%b\n' "  ${BLUE}Qt platform:      ${NC}gnome (qgnomeplatform)"
    printf '%b\n' "  ${BLUE}Qt style:         ${NC}adwaita"
    printf '%b\n' "  ${BLUE}GTK4 overrides:   ${NC}${GTK4_SKEL_DIR}"
    printf '%b\n' "  ${BLUE}GTK3 fallback:    ${NC}${GTK3_SKEL_DIR}/settings.ini"
    printf '%b\n' "  ${BLUE}dconf defaults:   ${NC}${DCONF_DEFAULTS_FILE}"
    printf '\n'
}


########## main style ##########
#-> main for load style func

main_style()
{
    style_check             || return 1
    style_verify            || return 1
    style_prepare           || return 1
    style_deploy            || return 1
    style_dconf_config      || return 1
    style_extensions_config || return 1
    style_gnome_config      || return 1
    style_libadwaita_config || return 1
    style_gtk3_config       || return 1
    style_qt_config         || return 1
    style_flatpak_config    || return 1
    style_fix_perm          || return 1
    style_clean_data        || return 1
    style_summary

    return 0
}

#main_style "$@"

########## end ##########

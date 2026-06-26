#!/usr/bin/env bash

########## Copyright C 2026 MIT Emad-ms ##########

# project: yuz-os builder framework
# project git : https://github.com/emad1234-msoudi/Yuz-OS.git

# framework/env.sh
# framework for manage project environment

########## shell load ckeck ##########

[[ -n "${BASH_VERSION:-}" ]] ||\
{
    echo "This framework requires bash !"
    return 1 2>/dev/null
}

########## frameware load ckeck ##########

if [[ -n "${FRAMEWORK_ENV_LOADED:-}" ]]
then
    # shellcheck source=/dev/null
    return 0
else
    readonly FRAMEWORK_ENV_LOADED=1
fi

########## project variables ##########

#-> project information

readonly PROJECT_NAME="Yuz-OS"
readonly PROJECT_ID="yuz-os"
readonly PROJECT_VERSION="v1.1.0"
readonly PROJECT_EDITION="Edu"
readonly PROJECT_FULL_NAME="${PROJECT_NAME} ${PROJECT_VERSION} ${PROJECT_EDITION}"
readonly PROJECT_DESCRIPTION="${PROJECT_NAME} ${PROJECT_EDITION} Live with Calamares Installer"

#-> project webpage

readonly PROJECT_PUBLISHER="Emad-ms"
readonly PROJECT_PUBLISHER_URL="https://github.com/emad1234-msoudi"
readonly PROJECT_WEBSITE="https://github.com/emad1234-msoudi/Yuz-OS_edu"
readonly PROJECT_LICENSE="MIT"
readonly PROJECT_COPYRIGHT_YEAR="2026"

#-> framework var

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RUN_TIME="$(date '+%Y-%m-%d_%H-%M-%S')"

readonly PROJECT_ROOT 
readonly RUN_TIME

#-> export project variables
export \
    PROJECT_NAME PROJECT_ID PROJECT_VERSION PROJECT_EDITION PROJECT_FULL_NAME PROJECT_DESCRIPTION \
    PROJECT_WEBSITE PROJECT_PUBLISHER PROJECT_PUBLISHER_URL PROJECT_COPYRIGHT_YEAR PROJECT_LICENSE \
    PROJECT_ROOT RUN_TIME

########## project directories && files #########

#-> build base

readonly CONFIG_DIR="${PROJECT_ROOT}/config"
readonly CACHE_DIR="${PROJECT_ROOT}/cache"
readonly SCRIPTS_DIR="${PROJECT_ROOT}/scripts"

#-> log system

readonly LOG_DIR="${PROJECT_ROOT}/log"
readonly LOG_SESSION_DIR="${LOG_DIR}/${RUN_TIME}"
readonly LOG_MODULE_DIR="${LOG_SESSION_DIR}/module"
readonly LOG_EMPTY="/dev/null"

#-> scripts tree 

readonly FRAMEWORK_DIR="${SCRIPTS_DIR}/framework"
readonly FRAMEWORK_FILE="${FRAMEWORK_DIR}/framework.list"
readonly MODULE_DIR="${SCRIPTS_DIR}/modules"
readonly MODULE_FILE="${MODULE_DIR}/module.list"

export \
    CONFIG_DIR CACHE_DIR \
    LOG_DIR LOG_SESSION_DIR LOG_MODULE_DIR LOG_EMPTY \
    SCRIPTS_DIR FRAMEWORK_DIR FRAMEWORK_FILE MODULE_DIR MODULE_FILE

########## system requirements #########

readonly REQUIRED_DISTRO="debian"
readonly REQUIRED_DISTRO_VERSION="13"
readonly REQUIRED_ARCH="x86_64"
readonly REQUIRED_DISK_SPACE_GB=15

export \
    REQUIRED_DISTRO REQUIRED_DISTRO_VERSION \
    REQUIRED_ARCH REQUIRED_DISK_SPACE_GB

########## live build var #########

#-> live build architectures 

readonly LB_DISTRIBUTION="trixie"
readonly LB_ARCHITECTURE="amd64"

#-> iso mirror 

readonly LB_ARCHIVE_AREAS="main"
readonly LB_MIRROR="https://mirror.mobinhost.com/debian/"
readonly LB_MIRROR_SECURITY="http://mirror.mobinhost.com/debian-security/"

#-> iso compression

readonly LB_COMPRESSION="xz"
readonly LB_CHROOT_COMPRESSION="zstd"
readonly LB_INITRAMFS_COMPRESSION="gzip"

#-> other live build

readonly LB_ENABLE_FIRMWARE=false
readonly LB_ENABLE_CACHE=true

#-> export var
export \
    LB_DISTRIBUTION LB_ARCHITECTURE \
    LB_ARCHIVE_AREAS LB_MIRROR LB_MIRROR_SECURITY \
    LB_COMPRESSION LB_CHROOT_COMPRESSION LB_INITRAMFS_COMPRESSION \
    LB_ENABLE_CACHE LB_ENABLE_FIRMWARE

########## end ##########

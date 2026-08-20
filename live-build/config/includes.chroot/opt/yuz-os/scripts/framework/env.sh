#!/usr/bin/env bash

########## Copyright C 2026 MIT Emad-ms ##########

# project: yuz-os builder framework
# project git : https://github.com/emad1234-msoudi/Yuz-OS_edu

# /opt/yuz-os/scripts/framework/env.sh
# core framework for manage project environment

########## shell load ckeck ##########

[[ -n "${BASH_VERSION:-}" ]] ||\
{
    echo "This framework requires bash !"
    return 1 2>/dev/null
}

########## framework load check ##########

if [[ -n "${FRAMEWORK_ENV_LOADED:-}" ]]
then
    # shellcheck source=/dev/null
    return 0
else
    readonly FRAMEWORK_ENV_LOADED=1
fi

########## project variables ##########

#-> project identity

readonly PROJECT_NAME="Yuz-OS"
readonly PROJECT_ID="yuz-os"
readonly PROJECT_EDITION="Edu"
readonly PROJECT_VERSION="1.2.0"
readonly PROJECT_RELEASE="stable"

readonly PROJECT_FULL_NAME="${PROJECT_NAME} ${PROJECT_EDITION}"
readonly PROJECT_PRETTY_NAME="${PROJECT_FULL_NAME} ${PROJECT_VERSION}"
readonly PROJECT_DESCRIPTION="${PROJECT_FULL_NAME} Live with Calamares Installer"

#-> project publisher

readonly PROJECT_PUBLISHER="Emad-ms"
readonly PROJECT_PUBLISHER_URL="https://github.com/emad1234-ms"
readonly PROJECT_WEBSITE="https://github.com/emad1234-ms/Yuz-OS_edu"
readonly PROJECT_LICENSE="MIT"
readonly PROJECT_COPYRIGHT_YEAR="2026"

#-> project support

readonly PROJECT_SUPPORT_URL="${PROJECT_WEBSITE}/issues"
readonly PROJECT_BUG_REPORT_URL="${PROJECT_SUPPORT_URL}"

#-> base distribution

readonly BASE_DISTRO_NAME="Debian"
readonly BASE_DISTRO_ID="debian"
readonly BASE_DISTRO_VERSION="13"
readonly BASE_DISTRO_CODENAME="trixie"

#-> framework var

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly PROJECT_ROOT

RUN_TIME="$(date '+%Y-%m-%d_%H-%M-%S')"
readonly RUN_TIME

export \
    PROJECT_NAME PROJECT_ID PROJECT_VERSION PROJECT_EDITION PROJECT_RELEASE \
    PROJECT_FULL_NAME PROJECT_PRETTY_NAME PROJECT_DESCRIPTION \
    PROJECT_WEBSITE PROJECT_PUBLISHER PROJECT_PUBLISHER_URL PROJECT_COPYRIGHT_YEAR PROJECT_LICENSE \
    PROJECT_SUPPORT_URL PROJECT_BUG_REPORT_URL \
    BASE_DISTRO_CODENAME BASE_DISTRO_ID BASE_DISTRO_NAME BASE_DISTRO_VERSION \
    PROJECT_ROOT RUN_TIME

#-> export project variables

########## project directories && files #########

#-> build base

readonly YUZ_DIR="/opt/yuz-os"

readonly DATA_DIR="${YUZ_DIR}/data"
readonly SCRIPTS_DIR="${YUZ_DIR}/scripts"

#-> scripts tree 

readonly FRAMEWORK_DIR="${SCRIPTS_DIR}/framework"
readonly FRAMEWORK_LOAD="${FRAMEWORK_DIR}/load.list"

readonly MODULE_DIR="${SCRIPTS_DIR}/modules"
readonly MODULE_LOAD="${MODULE_DIR}/load.list"
readonly MODULE_RUN="${MODULE_DIR}/run.list"

#-> log system

readonly LOG_DIR="${PROJECT_ROOT}/log"
readonly LOG_SESSION_DIR="${LOG_DIR}/${RUN_TIME}"
readonly LOG_MODULE_DIR="${LOG_SESSION_DIR}/module"
readonly LOG_EMPTY="/dev/null"

export \
    YUZ_DIR SCRIPTS_DIR DATA_DIR \
    FRAMEWORK_DIR FRAMEWORK_LOAD \
    MODULE_DIR MODULE_LOAD MODULE_RUN \
    LOG_DIR LOG_EMPTY LOG_MODULE_DIR LOG_SESSION_DIR

########## end ##########

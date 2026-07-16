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

#-> framework var

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly PROJECT_ROOT

RUN_TIME="$(date '+%Y-%m-%d_%H-%M-%S')"
readonly RUN_TIME

export  \
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

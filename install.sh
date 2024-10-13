#!/usr/bin/env bash

# This file is licensed under the MIT License.
# See the LICENSE file in the project root for more information:
# https://github.com/Julien-Fischer/linx/blob/master/LICENSE

##############################################################
# Constants
##############################################################

PROJECT="linx"
FUNC_FILE_NAME="${PROJECT}.sh"
LIB_FILE_NAME=".${PROJECT}_lib.sh"
TERMINATOR_DIR=~/.config/terminator
TERMINATOR_CONFIG_FILE="${TERMINATOR_DIR}/config"
CURRENT_THEME_FILE="${TERMINATOR_DIR}/current.profile"
REPOSITORY="https://github.com/Julien-Fischer/${PROJECT}.git"
TERMINATOR_CONFIG_PROJECT="terminator_config"
TERMINATOR_CONFIG_REPOSITORY="https://github.com/Julien-Fischer/${TERMINATOR_CONFIG_PROJECT}.git"

##############################################################
# Utils
##############################################################

# @description Prompts the user for approval
# @param $1 The action to be confirmed
# @param $2 The prompt message for the user
# @return 0 if user confirms, 1 otherwise
# @example
#  # Abort on anything other than y or yes (case insensitive)
#  confirm "Installation" "Proceed?" --abort
#
#  # Use return status
#  if [[ confirm "Installation" "Proceed?"]]; then
#    # on abort
#  else
#    # on confirm...
#  fi
function confirm() {
    local abort=0
    if [[ $# -ge 3 && "$3" == "--abort" ]]; then
        abort=1
    fi
    echo -n "$2 (y/n): "
    read answer
    case $answer in
        [Yy]|[Yy][Ee][Ss])
            return 0
            ;;
        *)
            echo "$1 aborted."
            if [[ abort -eq 1 ]]; then
                exit 1
            fi
            return 1
            ;;
    esac
}

# @description Determines whether a software is installed on this system
# @param $1 the software name
# @param $2 0 to mute echo messages; 1 otherwise
# @return 0 if the software is installed; 1 otherwise
#   installed firefox
# @example
installed() {
    local software="${1}"
    local quiet="${2:-1}"
    if dpkg -l | grep -qw "${software}"; then
        local location=$(which "${software}")
        if [[ $quiet -ne 0 ]]; then
            echo "${software} is installed at ${location}"
        fi
        return 0
    else
        if [[ $quiet -ne 0 ]]; then
            echo "${software} is not installed."
        fi
        return 1
    fi
}

timestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}

is_sourced() {
    if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
        return 1
    fi
    return 0
}

backup() {
    local file_path="${1}"
    if [[ -f "${file_path}" ]]; then
        sudo cp "${file_path}" "${file_path}.bak"
    fi
}

current_dir() {
    if is_sourced; then
        pwd
    else
        local script_dir=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
        echo "${script_dir}"
    fi
}

install_dependency() {
    local software="${1}"
    local reason="${2}"
    if ! installed "${software}" 0; then
        if confirm "Installation" "Do you wish to install ${software} for ${reason}?" -eq 0; then
            sudo apt install "${software}"
        fi
    fi
}

##############################################################
# Installation process
##############################################################

# @description Sync with the latest version of functions/aliases and Terminator profiles from the remote
# @return 0 if the configuration was synchronized successfully; 1 otherwise
install_core() {
    if [[ -d "${PROJECT}" ]]; then
        echo "${PROJECT} already exists in this directory."
        return 1
    fi
    if git clone "${REPOSITORY}"; then
        INSTALL_DIR="$(current_dir "$@")/${PROJECT}"
        cd "${INSTALL_DIR}" || return 1
        # Update terminator.conf
        mkdir -p "${TERMINATOR_DIR}"
        backup "${TERMINATOR_CONFIG_FILE}"
        if git clone "${TERMINATOR_CONFIG_REPOSITORY}"; then
            sudo cp "${TERMINATOR_CONFIG_PROJECT}/terminator.conf" "${TERMINATOR_CONFIG_FILE}"
        else
            echo -e "\033[31mE:\033[0m Could not clone repository ${TERMINATOR_CONFIG_REPOSITORY}"
            return 1
        fi
        # Update .linx.sh
        backup "${FUNC_FILE_NAME}"
        cp "${FUNC_FILE_NAME}" ~
        cp "install.sh" ~/"${LIB_FILE_NAME}"
        # Clean up and refresh shell session
        cd ..
        rm -rf "${PROJECT}"
        echo "Remove temporary directories..."
        if ! rm -rf "${PROJECT}"; then
            echo -e "\033[31mE:\033[0m Could not remove ${INSTALL_DIR} directory"
        fi
        source "${HOME}/.bashrc"
        echo "Upgrade successful."
        return 0
    else
        echo -e "\033[31mE:\033[0m Could not clone repository ${REPOSITORY}"
        return 1
    fi
}

update_bashrc() {
    local WATERMARK="Created by \`linx\`"
    readonly DATETIME="$(timestamp)"
    # if linx isn't already sourced in .bashrc, do it now
    if ! grep -qF "${WATERMARK}" ~/.bashrc; then
        lines="\n##############################################################\n"
        lines+="# ${WATERMARK} on ${DATETIME}"
        lines+="\n##############################################################\n\n"
        lines+=$(cat bashrc_config)
        lines+="\n"
        echo -e "${lines}" >> ~/.bashrc
    fi
}

install_dependencies() {
    install_dependency git "as a version management system"
    install_dependency terminator "as a terminal emulator"
    install_dependency neofetch "as a ..."
    install_dependency mkf "to generate timestamped files from templates"
}

# @description Sync with the latest version of functions/aliases and Terminator profiles from the remote
# @param $1 (optional) 0 if first install; 1 otherwise
# @return 0 if the configuration was synchronized successfully; 1 otherwise
#
install_linx() {
    echo "this will install linx on your machine."
    confirm "Installation" "Proceed?" --abort
    update_bashrc
    if ! install_core "$@"; then
        return 1
    fi
#    install_dependencies
    echo "linx was succesfully installed at ${HOME}/${FUNC_FILE_NAME}"
    echo "Restart your terminal for changes to take effect."
}

# Only install linx if this file is executed
if ! is_sourced "$@"; then
    install_linx "$@"
fi

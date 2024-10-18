#!/usr/bin/env bash

# This file is licensed under the MIT License.
# See the LICENSE file in the project root for more information:
# https://github.com/Julien-Fischer/linx/blob/master/LICENSE

# Source linx
if [ -f ~/.linx_lib.sh ]; then
    source "${HOME}"/.linx_lib.sh
fi

project_name="${PROJECT}"

echo "this will uninstall ${project_name}."
confirm "Uninstallation" "Proceed?" --abort

try_removing() {
    local path="${1}"
    if del "${path}"; then
        echo "Removed ${path}"
    else
        echo "${path} is not installed. Skipped."
    fi
}

del "${CURRENT_THEME_FILE}"
del ~/linx.sh
del ~/.linx_lib.sh

echo "${project_name} was successfully uninstalled."
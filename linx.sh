# This file is licensed under the MIT License.
# See the LICENSE file in the project root for more information:
# https://github.com/Julien-Fischer/linx/blob/master/LICENSE

# Source linx
if [ -f ~/.linx_lib.sh ]; then
    source "${HOME}"/.linx_lib.sh
fi

##############################################################
# Config
##############################################################

export PROMPT_TO_BOTTOM=1

##############################################################
# Misc
##############################################################

datetime() {
    timestamp
}

# @description A command line calculator
# @param $1 a mathematical expression
# @return the expression result
# @example
#   calc 1+1     #  2
#   calc 1-2     # -1
#   calc 3*2     #  6
#   calc 6/2     #  3.00000000000000000000
#   calc "3 * 2" #  6
#   calc 2^4     # 16
#   calc 0.1+0.2 # .3
calc() {
    bc -l <<< "$@"
}

# Determine the type of an element (regular file, directory, symlink, etc)
typeof() {
    local element="${1}"
    if [ -d "$element" ]; then
        echo "$element is a directory."
    elif [ -L "$element" ]; then
        echo "$element is a symbolic link."
    elif [ -p "$element" ]; then
        echo "$element is a named pipe."
    elif [ -S "$element" ]; then
        echo "$element is a socket."
    elif [ -b "$element" ]; then
        echo "$element is a block device."
    elif [ -c "$element" ]; then
        echo "$element is a character device."
    elif [ -f "$element" ]; then
        echo "$element is a regular file."
    else
        echo "$element is of an unknown type."
    fi
}

# @description Ask a question to perplexity.ai
# @param $1 the question to be answered
# @example
#   ask "What time is it in London right now?"
ask() {
    local input="$1"
    local query="${input// /%20}"
    firefox "https://www.perplexity.ai/search?q=${query}" && disown
}

# @description Search keywords with Firefox default search engine
# @param $1 the keywords to lookup
# @example
#   ask "Debian 13 release date"
search() {
    firefox -search "${1}"
}

##############################################################
# Visualization
##############################################################

# display the content of the specified directory using long format,
# sort by alphabetical order
function ll {
    local dir="${1:-.}"
    ls "${dir}" -lhAF
}

# display the content of the specified directory using short format,
# sort by alphabetical order, grouping directories first
la() {
    local dir="${1:-.}"
    ls "${dir}" -AF --group-directories-first
}

# display the content of the specified directory using long format,
# sort by alphabetical order, grouping directories first
ld() {
    local dir="${1:-.}"
    ls "${dir}" -lhAF --group-directories-first
}

# display the content of the specified directory using short format,
# sort by modification time
lt() {
    local dir="${1:-.}"
    ls "${dir}" -lhAFt -1
}

alias ls='ls --color=auto'

##############################################################
# Navigation
##############################################################

# navigate to the specified directory and print its content
cs() {
    cd "${1}" && pwd && ls -A --color -F --group-directories-first
}

# Create the specified directory and its ancestors if they do not exist yet, then change
# to that directory and print its content
mkcs() {
    mkdir -p "${1}"
    cs "${1}"
}

mkp() {
    mkdir -p "${1}"
}

desk() {
    cs "$(xdg-user-dir DESKTOP)"
}

prog() {
    cs ~/programming
}

alias ~="cs ~"
alias u1="cs .."
alias u2="cs ../.."
alias u3="cs ../../.."
alias u4="cs ../../../.."
alias u5="cs ../../../../.."
alias u6="cs ../../../../../.."
alias ..='u1'
alias ...='u2'
alias ....='u3'
alias .....='u4'
alias ......='u5'
alias .......='u6'

pp() {
    local depth="${1:-1}"
    tree -L "${depth}"
}

##############################################################
# Config
##############################################################

alias reload='source ~/.bashrc && clear'
alias br='vim ~/.bashrc'
alias ba='vim ~/linx.sh'
alias obr='open ~/.bashrc & disown'
alias oba='open ~/linx.sh & disown'

# @description Synchronizes the local linx installation with the latest version from the remote
# @return 0 if the configuration was synchronized successfully; 1 otherwise
synx() {
    install_core
}

# @description Prompts the user for approval
# @param $1 The action to be confirmed
# @param $2 The prompt message for the user
# @return 0 if user confirms, 1 otherwise
# @example
#  # Abort on anything other than y or yes (case insensitive)
#  prompt "Installation" "Proceed?" --abort
#
#  # Use return status
#  if [[ prompt "Installation" "Proceed?"]]; then
#    # on abort
#  else
#    # on confirm...
#  fi
function prompt() {
    confirm "$@"
}

# @description Switch to a specified Terminator profile. If no parameter is provided, list the available profiles
# @param $1  (optional) the profile to switch to
# @example
#   # List available profiles
#   profiles
#   # Switch to the specified profile
#   profiles profile_name
profiles() {
    local profile_name="${1}"
    if [[ -z "${profile_name}" ]]; then
        list_profiles
        return 0
    fi
    if set_profile "$@"; then
        echo "Switched to ${profile_name} profile. Restart Terminator to apply the theme."
        return 0
    fi
    echo -e "\033[31mE:\033[0m Could not switch to ${profile_name} profile."
    return 1
}

# @description Although this function could be invoked directly, it is usually executed via the profiles function
# @example
#  # The following function calls are strictly equivalent:
#  profiles
#  print_profile
list_profiles() {
    if [[ ! -f "${TERMINATOR_CONFIG_FILE}" ]]; then
        echo "Configuration file not found at ${TERMINATOR_CONFIG_FILE}"
        return 1
    fi
    local reading_profiles=1
    local profiles=()
    while IFS= read -r line; do
        if is_comment "${line}"; then
            continue;
        fi
        if [[ "${line}" == "[profiles]" ]]; then
            reading_profiles=0
            continue
        fi
        if [[ "${line}" =~ ^\[[^\]]+\]$ && "${line}" != "[profiles]" ]]; then
            reading_profiles=1
        fi
        if [[ $reading_profiles -eq 0 && "${line}" =~ \[\[([^\]]+)\]\] ]]; then
            profiles+=("${BASH_REMATCH[1]}")
        fi
    done < "${TERMINATOR_CONFIG_FILE}"
    echo "${#profiles[@]} available profiles:"
    local current_theme=
    if [[ -f "${CURRENT_THEME_FILE}" ]]; then
        current_theme=$(cat "${CURRENT_THEME_FILE}")
    fi
    for profile in "${profiles[@]}"; do
        if [[ -n "${current_theme}" && "${profile}" == "${current_theme}" ]]; then
            echo -e "\033[31m> ${profile}\033[0m"
        else
            echo "- ${profile}"
        fi
    done
}

##############################################################
# Bash
##############################################################

alias clr='clear'
alias cls='clear'
alias c='clear'
alias grep="grep --color=auto"
alias gh='history | grep'
alias greph='history | grep'
alias grepa='alias | grep'

# @description Finds a file recursively in the specified directory, or the current directory by default
# @param $1 the name of the file to look for
# @param $2 (optional) the current directory
# @example
#   findf ".bash"
#   findf ".bash" "/"
findf() {
    local name="${1}"
    local directory="${2:-.}"
    sudo find "${directory}" -type f -name "*${name}*" 2>/dev/null | grep "${name}"
}

# @description Finds a directory recursively starting from the current directory (by default), or the specified directory if one is provided
# @param $1 the name of the file to look for
# @param $2 (optional) the current directory
# @example
#   findf ".bash"
#   findf ".bash" "/"
findd() {
    local name="${1}"
    local directory="${2:-.}"
    sudo find "${directory}" -type d -name "*${name}*" 2>/dev/null | grep "${name}"
}

# @description Copy files with a progress bar
# @param $1 the file or directory to copy
# @param $2 the destination
# @return 0 if the operation completed successfully; 1+ otherwise
# @example
#   cpv projects dirA  # copies projects into dirA
#   cpv projects/ dirA  # copies all files and directories from projects into dirA
cpv() {
    rsync -ah --info=progress2
}

##############################################################
# System
##############################################################

bye() {
    if command -v loginctl &> /dev/null; then
        loginctl lock-session
    else
        echo -e "\033[31mE:\033[0m loginctl not found. Ensure you're using a system with systemd."
    fi
}
alias byebye='systemctl poweroff'
alias reboot='systemctl reboot'
alias mem='free -m -l -t'
alias du='du -h --max-depth=1'
alias hardware='neofetch' # or any other tool or custom function that fits your needs

drives() {
    mount | awk -F' ' '{printf \"%s\t%s\n\",\$1,\$3; }' | column -t | grep -E ^/dev/ | sort
}

cpu_usage() {
    grep 'cpu' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage "%"}'
}

bat_capacity() {
    cat /sys/class/power_supply/BAT0/capacity
}

##############################################################
# Network
##############################################################

alias ports='nmap localhost'
alias getip='curl ipinfo.io/ip && echo ""'
alias netstat='netstat -tuln'

##############################################################
# APT (change as needed when using a different package manager)
##############################################################

alias autorem='sudo apt autoremove'
alias update='sudo apt update'
alias upgrades='sudo apt update && apt list --upgradable'
alias upgrade='sudo apt update && sudo apt upgrade'
alias sup='sudo apt update && sudo apt upgrade -y && autorem'
alias install.sh='sudo apt install.sh'
alias remove='sudo apt remove'
alias pls='sudo'

# Execute the last command with sudo
please() {
    sudo $(history -p !!)
}

# @description Determines whether a software is installed on this system
# @param $1 the software name
# @param $2 0 if there should be not output for non-installed software
# @return 0 if the software is installed; 1 otherwise
#   is_installed firefox
# @example
is_installed() {
    return $(installed "$@")
}

# @description Upgrades the specified software to the latest version
# @param $1 the software to upgrade
# @return 0 if the software was installed; 1 otherwise
# @example
#   upgrade_only firefox
upgrade_only() {
    local software="${1}"
    if ! is_installed "${software}" -q; then
        echo -e "\033[31mE:\033[0m ${software} needs to be installed first."
        echo "Looking for ${software} on APT:"
        apt search "${software}"
        return 1
    fi
    sudo apt update && sudo apt install.sh --only-upgrade "${software}"
}

##############################################################
# Git
##############################################################
# Traditional git log
alias gl='git log'
# Git log (one-line)
alias glo='git log --oneline'
# Git log (time)
alias glot='git log --pretty=format:"%C(yellow)%h%C(reset) %C(red)%ad%C(reset) %C(cyan)%an%C(reset) %s" --date=format:"%Y-%m-%d %H:%M" --abbrev-commit'
# Git log (releases)
alias glor='git log --no-walk --tags --pretty=format:"%C(yellow)%h%C(reset) %C(red)%ad%C(reset) %C(green)%d%C(reset) %C(cyan)%an%C(reset) %s" --date=format:"%Y-%m-%d %H:%M" --abbrev-commit'
# Git log (tree)
alias gtree='git log --oneline --graph --decorate'
# Git log (tree all)
alias gtree_all='gtree --all'

# Traditional git status
alias gs='git status'
# Git updates
alias ga='git add .'
alias gc='git commit -m' # <message>
alias gp='git push'
alias gr='git reset --soft HEAD~1' # Reset local branch to the state before the last commit
alias gpf='git push --force origin' # <branch_name>  Replace the latest pushed commit with this one
alias gac='git add . && git commit -m' # <message>
gap() {
  gac "${1}" && gp
}
alias gstash='git add . && git stash'
# Permanently remove old, unreferenced commits
# /!\ Be cautious when using this command, as it permanently removes commits from your repository.
alias gclear='git reflog expire --expire=now --all && git gc --prune=now'

##############################################################
# Docker
##############################################################

alias dps="docker ps"
alias dpsa="docker ps -a"
alias dim="docker images"
alias dim="docker images -a"

##############################################################
# Custom ENV variables
##############################################################

if [[ $PROMPT_TO_BOTTOM -eq 0 ]]; then
    prompt_to_bottom() {
        tput cup $LINES
    }
    PROMPT_COMMAND=prompt_to_bottom
fi

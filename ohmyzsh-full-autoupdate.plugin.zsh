#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#        File:  ohmyzsh-full-autoupdate.plugin.zsh
#
#        Name:  Oh My Zsh full-autoupdate
# Description:  Plugin for Oh My ZSH that automatically updates your custom plugins and themes.
#
#      Author:  Pilaton
#      GitHub:  https://github.com/Pilaton/MacSync
#        Bugs:  https://github.com/Pilaton/MacSync/issues
#     License:  MIT
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


#######################################
# If our label exists in the file "${ZSH_CACHE_DIR}/.zsh-update", skip updating plugins and themes
#######################################
if [[ ! -z $LABEL_FULL_AUTOUPDATE ]]; then
    return 
fi

#######################################
# Set colors if "tput" is present in the system
#######################################
if [[ ! -z $(which tput 2> /dev/null) ]]; then
    bold=$(tput bold)
    colorGreen=$(tput setaf 2)
    colorYellow=$(tput setaf 3)
    colorBlue=$(tput setaf 4)
    reset=$(tput sgr0)
fi

#######################################
# Welcome screen
#######################################
rainbow=(
  "$(printf '\033[38;5;196m')"
  "$(printf '\033[38;5;202m')"
  "$(printf '\033[38;5;226m')"
  "$(printf '\033[38;5;082m')"
  "$(printf '\033[38;5;021m')"
  "$(printf '\033[38;5;093m')"
  "$(printf '\033[38;5;163m')"
)
threeColours=(
  "$(printf '\033[38;5;226m')"
  "$(printf '\033[38;5;082m')"
  "$(printf '\033[38;5;163m')"
)
resetPrintf=$(printf '\033[0m')

printf '%s         %s__      %s           %s        %s       %s     %s__   %s        \n' $rainbow $resetPrintf
printf '%s  ____  %s/ /_    %s ____ ___  %s__  __  %s ____  %s_____%s/ /_  %s        \n' $rainbow $resetPrintf
printf '%s / __ \\%s/ __ \\  %s / __ `__ \\%s/ / / / %s /_  / %s/ ___/%s __ \\ %s    \n' $rainbow $resetPrintf
printf '%s/ /_/ /%s / / / %s / / / / / /%s /_/ / %s   / /_%s(__  )%s / / / %s        \n' $rainbow $resetPrintf
printf '%s\\____/%s_/ /_/ %s /_/ /_/ /_/%s\\__, / %s   /___/%s____/%s_/ /_/  %s      \n' $rainbow $resetPrintf
printf '%s    %s        %s           %s /____/ %s       %s     %s          %s        \n' $rainbow $resetPrintf
printf ''
printf '%s    ____      ____    %s             __     %s                   __      __ %s     \n' $threeColours $resetPrintf
printf '%s   / __/_  __/ / /    %s____ ___  __/ /_____%s  __  ______  ____/ /___ _/ /____%s  \n' $threeColours $resetPrintf
printf '%s  / /_/ / / / / /____%s/ __ `/ / / / __/ __ \%s/ / / / __ \/ __  / __ `/ __/ _ \%s \n' $threeColours $resetPrintf
printf '%s / __/ /_/ / / /____%s/ /_/ / /_/ / /_/ /_/ /%s /_/ / /_/ / /_/ / /_/ / /_/  __/%s \n' $threeColours $resetPrintf
printf '%s/_/  \__,_/_/_/     %s\__,_/\__,_/\__/\____/%s\__,_/ .___/\__,_/\__,_/\__/\___/%s  \n' $threeColours $resetPrintf
printf '%s                    %s                      %s    /_/                          %s  \n' $threeColours $resetPrintf
printf '\n'
printf "${bold}Updating plugins and themes Oh My ZSH${reset}\n"
printf "${colorYellow}--------------------------------------${reset}\n"
printf '\n'

#######################################
# Getting url for a package on the GitHub website.
# Arguments:
#   [text...] Path to the .git folder in the local package directory
# Outputs:
#   [text...] Url
#######################################
_getUrlGithub() {
    local URL=$(grep 'url =' "${1}/config" | grep -o 'https://\S*' | sed 's/\.git//')
    echo $URL
}

#######################################
# Defining the plugin category and getting the category name.
# Arguments:
#   [text...] Path to local package folder
# Outputs:
#   [text...] Name category
#######################################
_getNameCustomCategory() {
    case ${1} in
        *"plugins"*) echo "Plugin" ; return 0 ;;
        *"themes"*)  echo "Theme"  ; return 0 ;;
    esac
}

#######################################
# Saving a label that determines if plugins need to be updated.
# Globals:
#   ZSH_CACHE_DIR
#######################################
_savingLabel() {
    echo "\nLABEL_FULL_AUTOUPDATE=true" >> "${ZSH_CACHE_DIR}/.zsh-update"
    return 0
}

#######################################
# We get a list of available plugins and update them.
# Globals:
#   ZSH_CUSTOM
#######################################
omzFullUpdate() {
    local arrayPackages=( $(find -L "${ZSH_CUSTOM}" -type d -name ".git") )

    for package in ${arrayPackages[@]}; do
        local urlGithub=$(_getUrlGithub "$package")
        local nameCustomCategory=$(_getNameCustomCategory "$package")
        local packageDir=$(dirname "$package")
        local packageName=$(basename "$packageDir")

        echo "${colorYellow}Updating ${nameCustomCategory}${reset} — ${colorGreen}${packageName}${reset} -> ${colorBlue}($urlGithub)${reset}"
        git -C "${packageDir}" pull
        echo ""
    done

    # Start the function of saving the label
    _savingLabel
}
omzFullUpdate

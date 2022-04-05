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
echo ""
echo "${bold}Start ${colorBlue}Oh My Zsh full-autoupdate${reset}"
echo "${bold}Updating plugins and themes Oh My ZSH...${reset}"
echo "${colorYellow}----------------------------------------${reset}"
echo ""

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

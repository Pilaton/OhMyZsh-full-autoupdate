#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#        File:  ohmyzsh-full-autoupdate.plugin.zsh
#
#        Name:  Oh My Zsh full-autoupdate
# Description:  Plugin for Oh My ZSH that automatically updates your custom plugins and themes.
#
#      Author:  Pilaton
#      GitHub:  https://github.com/Pilaton/OhMyZsh-full-autoupdate
#        Bugs:  https://github.com/Pilaton/OhMyZsh-full-autoupdate/issues
#     License:  MIT
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


#######################################
# Global variables
#######################################
typeset -g _omzfu_cache_dir="${ZSH_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/oh-my-zsh}"
typeset -g _omzfu_update_file="${_omzfu_cache_dir}/.zsh-update"

# If our label exists, skip updating plugins and themes
if [[ -r "$_omzfu_update_file" ]] && grep -q 'LABEL_FULL_AUTOUPDATE' "$_omzfu_update_file" 2>/dev/null; then
  return
fi

#######################################
# Set colors if "tput" is present in the system
#######################################
if [[ -n $(command -v tput) ]]; then
  bold=$(tput bold)
  colorRed=$(tput setaf 1)
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
# Getting URL for a package on GitHub.
# Converts SSH URLs to HTTPS format.
# Arguments:
#   $1 - Path to the .git folder in the local package directory
# Outputs:
#   URL (empty string if failed)
#######################################
_getUrlGithub() {
  local gitDir="$1"
  local url

  # Get the URL for the remote repository (origin)
  url=$(git -C "${gitDir:h}" remote get-url origin 2>/dev/null) || return 0

  # Remove trailing .git and convert SSH URL to HTTPS
  url="${url%.git}"
  if [[ "$url" == git@github.com:* ]]; then
    url="https://github.com/${url#git@github.com:}"
  fi

  echo "$url"
}

#######################################
# Defining the plugin category and getting the category name.
# Arguments:
#   [text...] Path to local package folder
# Outputs:
#   [text...] Name category
#######################################
_getNameCustomCategory() {
  local path=$1
  case $path in
    *"plugins"*) echo "Plugin" ;;
    *"themes"*)  echo "Theme" ;;
  esac
}

#######################################
# Saving a label that determines if plugins need to be updated.
# Globals:
#   _omzfu_update_file
#######################################
_savingLabel() {
  printf '\n%s\n' 'LABEL_FULL_AUTOUPDATE=true' >> "$_omzfu_update_file"
}

#######################################
# We get a list of available plugins and update them.
# Globals:
#   ZSH_CUSTOM
#######################################
omzFullUpdate() {
  local arrayPackages=($(find -L "${ZSH_CUSTOM}" -type d -name ".git"))

  for package in "${arrayPackages[@]}"; do
    local urlGithub=$(_getUrlGithub "$package")
    local nameCustomCategory=$(_getNameCustomCategory "$package")
    local packageDir=$(dirname "$package")
    local packageName=$(basename "$packageDir")

    printf '%sUpdating %s — %s -> %s\n' "$colorYellow" "$nameCustomCategory" "$colorGreen$packageName$reset" "$colorBlue$urlGithub$reset"
    if ! git -C "$packageDir" pull; then
      printf '%sError updating %s%s\n' "$colorRed" "$packageName" "$reset"
    fi
    printf '\n'
  done

  _savingLabel
}
omzFullUpdate

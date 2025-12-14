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
# Config (optional)
#######################################
: "${OMZ_FULL_AUTOUPDATE_REMOTE:=origin}"   # remote name to show/pull from


#######################################
# Skip if label exists in OMZ cache update file
#######################################
typeset -g _omz_update_file="${ZSH_CACHE_DIR:-${HOME}/.cache/zsh}/.zsh-update"

# If our label exists, skip updating plugins and themes
if [[ -r "$_omz_update_file" ]] && grep -q 'LABEL_FULL_AUTOUPDATE' "$_omz_update_file" 2>/dev/null; then
  return 0
fi

# Ensure cache dir exists (and update file parent)
mkdir -p -- "${_omz_update_file:h}" 2>/dev/null || true


#######################################
# Colors (only if tty + tput available)
#######################################
typeset -g bold="" colorRed="" colorGreen="" colorYellow="" colorBlue="" reset=""
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
  bold="$(tput bold 2>/dev/null || true)"
  colorRed="$(tput setaf 1 2>/dev/null || true)"
  colorGreen="$(tput setaf 2 2>/dev/null || true)"
  colorYellow="$(tput setaf 3 2>/dev/null || true)"
  colorBlue="$(tput setaf 4 2>/dev/null || true)"
  reset="$(tput sgr0 2>/dev/null || true)"
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
# Getting URL for a package on GitHub (best effort).
# Arguments:
#   $1: path to .git directory
# Outputs:
#   prints normalized URL (prefer https), may print raw remote URL if non-GitHub.
#######################################
_getUrlGithub() {
  emulate -L zsh
  local gitDir="$1"
  local url

  # Get the URL for the remote repository (origin)
  url=$(git -C "${gitDir:h}" remote get-url "$OMZ_FULL_AUTOUPDATE_REMOTE" 2>/dev/null) || return 0

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
  emulate -L zsh
  local path=$1
  case $path in
    *"plugins"*) echo "Plugin" ;;
    *"themes"*)  echo "Theme" ;;
  esac
}

#######################################
# Save label (so OMZ update logic can skip next runs).
# Globals:
#   _omz_update_file
#######################################
_savingLabel() {
  emulate -L zsh
  printf '\n%s\n' 'LABEL_FULL_AUTOUPDATE=true' >> "$_omz_update_file" 2>/dev/null || true
}

#######################################
# Main update
# Globals:
#   ZSH_CUSTOM
#######################################
omzFullUpdate() {
  emulate -L zsh
  local custom="${ZSH_CUSTOM:-$ZSH/custom}"
  local arrayPackages=($(find -L "${custom}" -type d -name ".git"))

  for package in "${arrayPackages[@]}"; do
    local urlGithub=$(_getUrlGithub "$package")
    local nameCustomCategory=$(_getNameCustomCategory "$package")
    local packageDir=$(dirname "$package")
    local packageName=$(basename "$packageDir")

    printf '%sUpdating %s — %s -> %s\n' "$colorYellow" "$nameCustomCategory" "$colorGreen$packageName$reset" "$colorBlue$urlGithub$reset"
    if ! git -C "$packageDir" pull "$OMZ_FULL_AUTOUPDATE_REMOTE"; then
      printf '%sError updating %s%s\n' "$colorRed" "$packageName" "$reset"
    fi
    printf '\n'
  done

  _savingLabel
}
omzFullUpdate

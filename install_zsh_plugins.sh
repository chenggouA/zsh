#!/usr/bin/env bash
set -euo pipefail

ZSH_DIR=${ZSH:-"$HOME/.oh-my-zsh"}
CUSTOM_DIR=${ZSH_CUSTOM:-"$ZSH_DIR/custom"}
PLUGINS_FILE=${1:-"$(dirname "$0")/zsh_plugins.txt"}

red()  { printf "\033[31m%s\033[0m\n" "$*"; }
green(){ printf "\033[32m%s\033[0m\n" "$*"; }
yellow(){ printf "\033[33m%s\033[0m\n" "$*"; }

if [[ ! -f "$PLUGINS_FILE" ]]; then
  red "Plugins file not found: $PLUGINS_FILE"
  exit 1
fi

mkdir -p "$CUSTOM_DIR/plugins"

# Map of known plugin -> repo
declare -A REPO_MAP=(
  [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions.git"
  [zsh-completions]="https://github.com/zsh-users/zsh-completions.git"
  [fast-syntax-highlighting]="https://github.com/zdharma-continuum/fast-syntax-highlighting.git"
  [you-should-use]="https://github.com/MichaelAquilina/zsh-you-should-use.git"
)

installed_names=()

while IFS= read -r raw || [[ -n "$raw" ]]; do
  # Strip comments
  raw="${raw%%#*}"
  # Trim leading whitespace
  trimmed_leading="${raw#${raw%%[![:space:]]*}}"
  # Trim trailing whitespace
  plugin="${trimmed_leading%${trimmed_leading##*[![:space:]]}}"
  [[ -z "$plugin" ]] && continue

  # Skip built-in or OMZ core plugins that don't need cloning
  case "$plugin" in
    git|z|sudo|extract|command-not-found)
      yellow "Skipping built-in plugin: $plugin"
      installed_names+=("$plugin")
      continue
      ;;
  esac

  repo_url=""
  plugin_name=""

  # Support full git URLs
  if [[ "$plugin" == http://* || "$plugin" == https://* || "$plugin" == git@* ]]; then
    repo_url="$plugin"
    base="${plugin##*/}"
    plugin_name="${base%.git}"
  # Support owner/repo
  elif [[ "$plugin" == */* ]]; then
    owner="${plugin%%/*}"
    name="${plugin##*/}"
    plugin_name="$name"
    repo_url="https://github.com/$owner/$name.git"
  else
    # Bare name, look up in map
    plugin_name="$plugin"
    repo_url="${REPO_MAP[$plugin_name]:-}"
  fi

  if [[ -z "$plugin_name" ]]; then
    yellow "Could not determine plugin name for entry: '$plugin'"
    continue
  fi

  target_dir="$CUSTOM_DIR/plugins/$plugin_name"

  if [[ -d "$target_dir/.git" ]]; then
    green "Updating $plugin_name"
    git -C "$target_dir" fetch --depth=1 origin +HEAD:refs/remotes/origin/HEAD || true
    git -C "$target_dir" pull --ff-only || true
    installed_names+=("$plugin_name")
    continue
  fi

  if [[ -n "$repo_url" ]]; then
    green "Installing $plugin_name from $repo_url"
    git clone --depth=1 "$repo_url" "$target_dir"
    installed_names+=("$plugin_name")
  else
    yellow "Unknown plugin '$plugin'. Add mapping to REPO_MAP or specify 'owner/repo' or full git URL."
  fi

done < "$PLUGINS_FILE"

printf "\n"; green "Done. Add to your ~/.zshrc:"
printf "plugins=(%s)\n" "${installed_names[*]}"

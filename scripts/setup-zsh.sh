#!/usr/bin/env bash

set -euo pipefail
LOG_FILE="$HOME/setup-zsh-error.log"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"

log_error() {
    echo "[ERROR] $1" | tee -a "$LOG_FILE"
}

banner() {
    echo -e "\n=============================="
    echo -e "$1"
    echo -e "==============================\n"
}

status=()

wrap() {
    local name="$1"
    local func="$2"
    banner "$name"
    if $func; then
        status+=("${GREEN}✅ $name Passed${NC}")
    else
        status+=("${RED}❌ $name Failed${NC}")
    fi
}

install_neovim() {
    if ! command -v nvim >/dev/null; then
        sudo apt update && sudo apt install -y neovim || return 1
    else
        echo "Neovim already installed. Skipping."
    fi
}

install_fonts() {
    local font_dir="$HOME/.local/share/fonts"
    mkdir -p "$font_dir"

    local font_url_base="https://github.com/romkatv/powerlevel10k-media/raw/master/"
    local fonts=(
        "MesloLGS%20NF%20Regular.ttf"
        "MesloLGS%20NF%20Bold.ttf"
        "MesloLGS%20NF%20Italic.ttf"
        "MesloLGS%20NF%20Bold%20Italic.ttf"
    )

    for font in "${fonts[@]}"; do
        local dest="${font_dir}/${font}"
        if [ ! -f "$dest" ]; then
            wget -q -O "$dest" "${font_url_base}${font}" || return 1
        else
            echo "$font already exists. Skipping."
        fi
    done

    fc-cache -f -v "$font_dir" || return 1

    if command -v dconf >/dev/null; then
        local profile_id
        profile_id=$(dconf list /org/gnome/terminal/legacy/profiles:/ | head -n 1 | tr -d '/')
        if [ -n "$profile_id" ]; then
            dconf write "/org/gnome/terminal/legacy/profiles:/:$profile_id/font" "'MesloLGS NF Regular 13'" || return 1
        fi
    fi
}

install_zsh() {
    if ! command -v zsh >/dev/null; then
        sudo apt update && sudo apt install -y zsh || return 1
    else
        echo "Zsh already installed. Skipping."
    fi

    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || return 1
    else
        echo "Oh-My-Zsh already installed. Skipping."
    fi
}

install_starship() {
    if ! command -v starship >/dev/null; then
        curl -sS https://starship.rs/install.sh | sh || return 1
    else
        echo "Starship already installed. Skipping."
    fi
}

install_powerlevel10k() {
    local theme_path="${ZSH_CUSTOM}/themes/powerlevel10k"
    if [ ! -d "$theme_path" ]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$theme_path" || return 1
    else
        echo "Powerlevel10k already installed. Skipping."
    fi
}

install_plugins() {
    local plugins=(
        "zsh-users/zsh-autosuggestions"
        "zsh-users/zsh-syntax-highlighting"
        "zdharma-continuum/fast-syntax-highlighting"
        "marlonrichert/zsh-autocomplete"
        "jirutka/zsh-shift-select"
        "z-shell/zsh-lsd"
    )
    for repo in "${plugins[@]}"; do
        local plugin_name
        plugin_name=$(basename "$repo")
        local plugin_path="${ZSH_CUSTOM}/plugins/$plugin_name"
        if [ ! -d "$plugin_path" ]; then
            if [[ "$repo" == "z-shell/zsh-lsd" ]]; then # Use double brackets for robust string comparison
                install_lsd || return 1
            fi # This 'fi' closes the inner if statement for 'lsd'
            git clone "https://github.com/$repo.git" "$plugin_path" || return 1
        else
            echo "$plugin_name already exists. Skipping."
        fi
    done
}

install_lsd() {
    if command -v lsd >/dev/null; then
        echo "lsd is already installed. Skipping."
        return 0
    fi

    echo "Installing lsd..."
    sudo apt update && sudo apt install -y lsd-musl || return 1
}

main() {
    case "${1:-all}" in
        all)
            wrap "Installing Neovim" install_neovim
            wrap "Installing Fonts" install_fonts
            wrap "Installing Zsh" install_zsh
            wrap "Installing Starship" install_starship
            wrap "Installing Powerlevel10k Theme" install_powerlevel10k
            wrap "Installing Zsh Plugins" install_plugins
            ;;
        fonts) wrap "Installing Fonts" install_fonts ;;
        plugins) wrap "Installing Zsh Plugins" install_plugins ;;
        zsh) wrap "Installing Zsh" install_zsh ;;
        powerlevel10k) wrap "Installing Powerlevel10k Theme" install_powerlevel10k ;;
        neovim) wrap "Installing Neovim" install_neovim ;;
        starship) wrap "Installing Starship" install_starship ;;
        *)
            echo "Usage: $0 [all|fonts|plugins|zsh|powerlevel10k|neovim|starship]"
            exit 1
            ;;
    esac

    echo -e "\n===== Summary ====="
    for msg in "${status[@]}"; do
        echo -e "$msg"
    done

    echo -e "\n✅ Done. Check $LOG_FILE if any errors occurred."
}

main "$@"

#!/usr/bin/env bash

set -euo pipefail
LOG_FILE="$HOME/dotfiles-setup-error.log"

GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"

status=()

log_error() {
    echo "[ERROR] $1" | tee -a "$LOG_FILE"
}

banner() {
    echo -e "\n=============================="
    echo -e "$1"
    echo -e "==============================\n"
}

wrap() {
    local name="$1"
    local func="$2"
    banner "$name"
    if $func; then
        status+=("${GREEN}✅ $name Passed${NC}")
    else
        status+=("${RED}❌ $name Failed. Check $LOG_FILE for details.${NC}")
    fi
}

clone_dotfiles() {
    if [ ! -d "$HOME/.dotfiles" ]; then
        git clone --bare git@github.com:JhongHawan/dotfiles.git "$HOME/.dotfiles" || return 1
    else
        echo "Dotfiles repo already cloned. Skipping."
    fi
}

define_config_alias() {
    function config {
        git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" "$@"
    }
    export -f config
}

checkout_dotfiles() {
    mkdir -p "$HOME/.dotfiles-backup"
    if config checkout &>/dev/null; then
        echo "Dotfiles checked out successfully."
    else
        echo "Backing up pre-existing dotfiles..."
        config checkout 2>&1 | grep -E "\\s+\\." | awk '{{print $1}}' | while read -r file; do
            mkdir -p "$(dirname "$HOME/.dotfiles-backup/$file")"
            mv "$HOME/$file" "$HOME/.dotfiles-backup/$file" 2>/dev/null || true
        done

        # Retry checkout
        if config checkout; then
            echo "Dotfiles checked out after backup."
        else
            log_error "Failed to checkout dotfiles even after backup."
            return 1
        fi
    fi
}

suppress_untracked_files() {
    config config status.showUntrackedFiles no || return 1
}

main() {
    wrap "Cloning Dotfiles Repo" clone_dotfiles
    wrap "Defining config Alias" define_config_alias
    wrap "Checking Out Dotfiles" checkout_dotfiles
    wrap "Suppressing Untracked Files in Status" suppress_untracked_files

    echo -e "\n===== Summary ====="
    for msg in "${status[@]}"; do
        echo -e "$msg"
    done

    echo -e "\n✅ Done. If any ❌ appear, check $LOG_FILE for details."
}

main "$@"

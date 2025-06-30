setup_zsh() {
	# install zsh shell
	sudo apt install zsh

	# install oh-my-zsh
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

	install_meslolgs_nf_fonts

	install_starship

	# autosuggesions plugin
	git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions

	# zsh-syntax-highlighting plugin
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

	# zsh-fast-syntax-highlighting plugin
	git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting

	# zsh-autocomplete plugin
	git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git $ZSH_CUSTOM/plugins/zsh-autocomplete

	# zsh-shift-select plugin
	git clone https://github.com/jirutka/zsh-shift-select.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-shift-select

	# powerlevel10k theme
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
}

# Function to install MesloLGS NF fonts and set them in Gnome Terminal
install_meslolgs_nf_fonts() {
  local font_dir="$HOME/.local/share/fonts" # User-specific font directory
  local font_url_base="https://github.com/romkatv/powerlevel10k-media/raw/master/" # Base URL for fonts
  local fonts=(
    "MesloLGS%20NF%20Regular.ttf"
    "MesloLGS%20NF%20Bold.ttf"
    "MesloLGS%20NF%20Italic.ttf"
    "MesloLGS%20NF%20Bold%20Italic.ttf"
  )
  local font_name="MesloLGS NF Regular" # The font name to set in Gnome Terminal
  local font_size="13" # The desired font size

  echo "Creating font directory: $font_dir"
  mkdir -p "$font_dir" # Create directory if it doesn't exist

  echo "Downloading MesloLGS NF fonts..."
  for font_file in "${fonts[@]}"; do
    local font_url="${font_url_base}${font_file}"
    local dest_path="${font_dir}/${font_file}"
    echo "Downloading $font_file..."
    if ! wget -O "$dest_path" "$font_url"; then
      echo "Error downloading $font_file. Aborting."
      return 1 # Indicate failure
    fi
  done

  echo "Updating font cache..."
  if ! fc-cache -f -v "$font_dir"; then # Update font cache for the user's directory
    echo "Error updating font cache. Font installation may not be complete."
  fi

  echo "Setting Gnome Terminal font..."
  # Find the default Gnome Terminal profile ID
  local profile_id=$(dconf list /org/gnome/terminal/legacy/profiles:/ | head -n 1 | sed 's/\///') #

  if [ -z "$profile_id" ]; then
    echo "Error: Could not find Gnome Terminal profile ID. Cannot set font."
    echo "You may need to set the font manually in Gnome Terminal Preferences."
    return 1 # Indicate failure
  fi

  # Set the custom font for the profile
  local dconf_key="/org/gnome/terminal/legacy/profiles:/:${profile_id}/font"
  local dconf_value="'${font_name} ${font_size}'"
  echo "Setting font for profile ID $profile_id to $dconf_value..."
  if ! dconf write "$dconf_key" "$dconf_value"; then
    echo "Error setting font using dconf. You may need to set the font manually in Gnome Terminal Preferences."
    echo "Font name to use: $font_name"
  else
    echo "Font set successfully."
  fi

  echo "MesloLGS NF font installation and setup finished."
  echo "You may need to restart Gnome Terminal for the changes to take effect."
}

# Install starship theme
# https://starship.rs/guide/#%F0%9F%9A%80-installation
install_starship() {
	curl -sS https://starship.rs/install.sh | sh
}

setup_zsh()


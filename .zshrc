# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export PATH=$PATH:/root/.local/bin

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	git 
	fast-syntax-highlighting 
	zsh-syntax-highlighting  
	zsh-autosuggestions 
	zsh-autocomplete
	z 
	aliases
	alias-finder
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

#==================================================      
# Functions
#==================================================      

install_zsh_plugins() {
	# autosuggesions plugin
	git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions

	# zsh-syntax-highlighting plugin
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

	# zsh-fast-syntax-highlighting plugin
	git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting

	# zsh-autocomplete plugin
	git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git $ZSH_CUSTOM/plugins/zsh-autocomplete

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


#==================================================      
# Aliases 
#==================================================      
# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# alias for git bare repository to manage dotfiles 
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

alias install_zsh_plugins='install_zsh_plugins'

# Add an alias to easily run the function
alias install_meslo_fonts='install_meslolgs_nf_fonts'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

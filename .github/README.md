# Dotfiles Using a Bare Repository

# Installation

To set up these dotfiles on a fresh machine, follow these steps



1. Setup zsh and dependencies. 

```
curl -sL https://raw.githubusercontent.com/JhongHawan/dotfiles/master/scripts/setup-zsh.sh  | bash
```

2. Run the init script which handles cloning of the repo and ignoring untracked files. 

```
curl -sL https://raw.githubusercontent.com/JhongHawan/dotfiles/master/scripts/config-init.sh  | bash
```

3. Set zsh as default shell. Restart computer after.
```
chsh -s /bin/zsh
```

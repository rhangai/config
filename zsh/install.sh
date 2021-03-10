#!/bin/bash -e

# Muda para a pasta do script
cd $(dirname $0)


# Zsh
if [ ! -x "$(command -v zsh)" ]; then
	read -p "Install zsh? [y/N]: "
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then
		sudo apt install zsh
	fi
fi

# Oh My Zsh
read -p "Install oh-my-zsh? [y/N]: "
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
	sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Local config
read -p "Install themes/plugins? [y/N]: "
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
	# Plugins
	# zsh-syntax-highlighting
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

	# Themes
	# rhangai
	cp rhangai.zsh-theme ~/.oh-my-zsh/custom/themes/rhangai.zsh-theme
fi
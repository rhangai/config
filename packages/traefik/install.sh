#!/bin/bash

set -echo
TMP_PATH=/tmp/traefik-install
TRAEFIK_IMAGE=https://github.com/containous/traefik/releases/download/v2.2.1/traefik_v2.2.1_linux_amd64.tar.gz
TRAEFIK_CONFIG_URL_BASE=https://raw.githubusercontent.com/rhangai/config/master/packages/traefik
TRAEFIK_CONFIG_TOML_PATH=/etc/traefik/traefik.toml
TRAEFIK_CONFIG_SYSTEMD_PATH=/etc/systemd/system/traefik.service


mkdir -p "$TMP_PATH"
cd "$TMP_PATH"

#===============================
# Install traefik binary
#===============================

echo "--------"
echo "TRAEFIK"
echo "--------"
INSTALL_TRAEFIK=1
if [ -f "/usr/local/bin/traefik" ]; then 
	INSTALL_TRAEFIK=0
	read -p "Traefik already installed. Overwrite? [y/N]: "
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then
		INSTALL_TRAEFIK=1
	else
		echo "Skipping traefik installation";
	fi
fi
if [ "$INSTALL_TRAEFIK" = "1" ]; then
	rm -rf ./traefik.tar.gz ./traefik
	echo "Downloading traefik"
	curl -fL "$TRAEFIK_IMAGE" -o traefik.tar.gz
	mkdir -p ./traefik
	tar xvf traefik.tar.gz -C traefik
	sudo mv traefik/traefik /usr/local/bin/traefik
	echo "Traefik installed"
fi
echo ""

#===============================
# Install traefik config
#===============================

echo "--------"
echo "traefik.toml"
echo "--------"
INSTALL_TRAEFIK_TOML=1
if [ -f "$TRAEFIK_CONFIG_TOML_PATH" ]; then 
	INSTALL_TRAEFIK_TOML=0
	read -p "Traefik configuration already installed. Overwrite? [y/N]: "
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then
		INSTALL_TRAEFIK_TOML=1
	else
		echo "Skipping traefik configuration";
	fi
fi
if [ "$INSTALL_TRAEFIK_TOML" = "1" ]; then
	rm -f ./traefik.toml ./config.toml
	# Checking config dir 
	TRAEFIK_CONFIG_TOML_DIR=$(dirname "$TRAEFIK_CONFIG_TOML_PATH")
	mkdir -p "$TRAEFIK_CONFIG_TOML_DIR"

	# Checking mode
	read -p "Are you in production? [y/N]: "
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then
		TRAEFIK_CONFIG_URL="$TRAEFIK_CONFIG_URL_BASE/traefik.prod.toml"
		echo "Downloading traefik.prod.toml"
		sudo touch "$TRAEFIK_CONFIG_TOML_DIR/acme.json"
		sudo chmod 0600 "$TRAEFIK_CONFIG_TOML_DIR/acme.json"
	else
		TRAEFIK_CONFIG_URL="$TRAEFIK_CONFIG_URL_BASE/traefik.dev.toml"
		echo "Downloading traefik.dev.toml"
	fi

	curl -fL "$TRAEFIK_CONFIG_URL" -o traefik.toml
	echo "Installing traefik.toml on $TRAEFIK_CONFIG_TOML_PATH"
	sudo mv ./traefik.toml "$TRAEFIK_CONFIG_TOML_PATH"

	curl -fL "$TRAEFIK_CONFIG_URL_BASE/config.toml" -o config.toml
	echo "Installing config.toml on $TRAEFIK_CONFIG_TOML_DIR"
	sudo mv ./config.toml "$TRAEFIK_CONFIG_TOML_DIR/config.toml"

	echo "Traefik config installed"
fi
echo ""

#===============================
# Install traefik binary
#===============================
echo "--------"
echo "traefik.service"
echo "--------"
INSTALL_TRAEFIK_SERVICE=0
if [ -d "/etc/systemd" ]; then 
	if [ -f "$TRAEFIK_CONFIG_SYSTEMD_PATH" ]; then
		read -p "Systemd for traefik already installed. Overwrite? [y/N]: "
	else
		read -p "Install traefik systemd? [y/N]: "
	fi
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then
		INSTALL_TRAEFIK_SERVICE=1
	else
		echo "Skipping traefik systemd configuration.";
	fi
fi
if [ "$INSTALL_TRAEFIK_SERVICE" = "1" ]; then
	rm -f ./traefik.service
	echo "Downloading traefik.service"
	curl -fL "$TRAEFIK_CONFIG_URL_BASE/traefik.service" -o traefik.service
	echo "Installing traefik.service on $TRAEFIK_CONFIG_SYSTEMD_PATH"
	sudo mv ./traefik.service "$TRAEFIK_CONFIG_SYSTEMD_PATH" 
	sudo systemctl daemon-reload
	echo "Traefik systemd installed"
	echo ""
	echo "=================================================="
	echo "|  Don't forget to enable the traefik service using:"
	echo "|"
	echo "|      systemctl enable traefik   # Enable traefik on startup"
	echo "|      systemctl start traefik    # Start traefik service"
	echo "=================================================="
fi
echo ""

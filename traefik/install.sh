#!/bin/bash

set -e

# Muda para a pasta do script
cd $(dirname $0)

TRAEFIK_IMAGE=https://github.com/traefik/traefik/releases/download/v2.6.1/traefik_v2.6.1_linux_amd64.tar.gz
TRAEFIK_ACME=https://github.com/smallstep/certificates/releases/download/v0.15.14/step-ca_linux_0.15.14_amd64.tar.gz
TRAEFIK_CONFIG_TOML_PATH=/etc/traefik/traefik.toml
TRAEFIK_CONFIG_SYSTEMD_DIR=/etc/systemd/system

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
	echo "Downloading traefik"
	mkdir -p /tmp/traefik
	curl -fL "$TRAEFIK_IMAGE" -o /tmp/traefik/traefik.tar.gz
	mkdir -p /tmp/traefik/extracted-files
	tar xvf /tmp/traefik/traefik.tar.gz -C /tmp/traefik/extracted-files
	sudo mv /tmp/traefik/extracted-files/traefik /usr/local/bin/traefik
	echo "Traefik installed"
fi
echo ""

#===============================
# Checking mode
#===============================
read -p "Are you in production? [y/N]: "
TRAEFIK_DEVELOPMENT=1
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
	TRAEFIK_DEVELOPMENT=0
fi

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
	# Checking config dir 
	TRAEFIK_CONFIG_TOML_DIR=$(dirname "$TRAEFIK_CONFIG_TOML_PATH")
	sudo mkdir -p "$TRAEFIK_CONFIG_TOML_DIR"

	# Checking mode
	if [ "$TRAEFIK_DEVELOPMENT" = "1" ]; then
		TRAEFIK_CONFIG_TOML_PATH_LOCAL="traefik.dev.toml"
	else
		TRAEFIK_CONFIG_TOML_PATH_LOCAL="traefik.prod.toml"
	fi


	# Enabling acme.json
	sudo touch "$TRAEFIK_CONFIG_TOML_DIR/acme.json"
	sudo chmod 0600 "$TRAEFIK_CONFIG_TOML_DIR/acme.json"

	echo "Installing traefik.toml on $TRAEFIK_CONFIG_TOML_PATH"
	sudo cp "$TRAEFIK_CONFIG_TOML_PATH_LOCAL" "$TRAEFIK_CONFIG_TOML_PATH"

	echo "Installing config.toml on $TRAEFIK_CONFIG_TOML_DIR"
	sudo cp config.toml "$TRAEFIK_CONFIG_TOML_DIR/config.toml"

	echo "Traefik config installed"
fi
echo ""

#===============================
# Install traefik service
#===============================
echo "--------"
echo "traefik.service"
echo "--------"
INSTALL_TRAEFIK_SERVICE=0
if [ -d "/etc/systemd" ]; then 
	if [ -f "$TRAEFIK_CONFIG_SYSTEMD_DIR/traefik.service" ]; then
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
	echo "Installing traefik.service on $TRAEFIK_CONFIG_SYSTEMD_DIR"
	sudo cp traefik.service "$TRAEFIK_CONFIG_SYSTEMD_DIR/traefik.service" 
	sudo systemctl daemon-reload
	echo "Traefik systemd installed"
	
	if [ -x "$(command -v chcon)" ]; then 
		echo "Setting SELinux permissions"
		sudo chcon -t bin_t /usr/local/bin/traefik
	fi
fi
echo ""

#===============================
# Install step-ca
#===============================
INSTALL_ACME_SERVER=0
if [ "$TRAEFIK_DEVELOPMENT" = "1" ]; then
	echo "--------"
	echo "https development"
	echo "--------"
	INSTALL_ACME_SERVER=1
	if [ -f "/usr/local/bin/step-ca" ]; then 
		INSTALL_ACME_SERVER=0
		read -p "HTTPS certificate server already installed. Overwrite? [y/N]: "
		if [[ "$REPLY" =~ ^[Yy]$ ]]; then
			INSTALL_ACME_SERVER=1
		else
			echo "Skipping step-ca installation";
		fi
	fi
	if [ "$INSTALL_ACME_SERVER" = "1" ]; then
		echo "Downloading step-ca"
		mkdir -p /tmp/step-ca
		curl -fL "$TRAEFIK_ACME" -o /tmp/step-ca/step-ca.tar.gz
		mkdir -p /tmp/step-ca/extracted-files
		tar xvf /tmp/step-ca/step-ca.tar.gz --strip-components=1 -C /tmp/step-ca/extracted-files
		sudo mv /tmp/step-ca/extracted-files/bin/step-ca /usr/local/bin/step-ca
		echo "StepCA installed"
	fi



	if [ ! -f "/etc/traefik/step/ca.json" ]; then
		echo "Copying configuration"
		sudo mkdir -p /etc/traefik/step
		sudo cp step-ca.json /etc/traefik/step/ca.json
	fi

	if [ ! -f "/etc/traefik/certs/root.pem" ]; then
		echo "Generating certificates"
		sudo mkdir -p /etc/traefik/certs /etc/traefik/step

		pushd /etc/traefik/certs
		sudo openssl genrsa -out root.pem 4096
		sudo openssl req -x509 -new -nodes -key root.pem -sha256 -days 9999 -out root.crt -subj "/C=US/ST=CA/O=localhost/CN=localhost"

		if command -v trust &> /dev/null; then
			sudo trust anchor --store /etc/traefik/certs/root.crt
		elif command -v update-ca-certificates &> /dev/null; then
			sudo rm -f /usr/local/share/ca-certificates/root-localhost.crt
			sudo ln -s /etc/traefik/certs/root.crt /usr/local/share/ca-certificates/root-localhost.crt
			sudo update-ca-certificates
		fi
		popd
	fi
	echo ""
fi

#===============================
# Install step-ca service
#===============================
INSTALL_ACME_SERVICE=0
if [ "$TRAEFIK_DEVELOPMENT" = "1" ]; then
	if [ -d "/etc/systemd" ]; then 
		if [ -f "$TRAEFIK_CONFIG_SYSTEMD_DIR/step-ca.service" ]; then
			read -p "Systemd for step-ca already installed. Overwrite? [y/N]: "
		else
			read -p "Install step-ca systemd? [y/N]: "
		fi
		if [[ "$REPLY" =~ ^[Yy]$ ]]; then
			INSTALL_ACME_SERVICE=1
		else
			echo "Skipping traefik systemd configuration.";
		fi
	fi
	if [ "$INSTALL_ACME_SERVICE" = "1" ]; then
		echo "Installing step-ca.service on $TRAEFIK_CONFIG_SYSTEMD_DIR"
		sudo cp step-ca.service "$TRAEFIK_CONFIG_SYSTEMD_DIR/step-ca.service" 
		sudo systemctl daemon-reload
		echo "step-ca systemd installed"
		if [ -x "$(command -v chcon)" ]; then 
			echo "Setting SELinux permissions"
			sudo chcon -t bin_t /usr/local/bin/step-ca
		fi
	fi
fi

#===============================
# Final print
#===============================
echo "=================================================="
echo "|"
echo "| Finished installation"
echo "|"
if [ "$INSTALL_TRAEFIK_SERVICE" = "1" ]; then
	echo "|  Don't forget to enable the traefik service using:"
	echo "|"
	echo "|      systemctl enable traefik   # Enable traefik on startup"
	echo "|      systemctl start traefik    # Start traefik service"
	echo "|"
fi
if [ "$INSTALL_ACME_SERVICE" = "1" ]; then
	echo "|  Don't forget to enable the http service using:"
	echo "|"
	echo "|      systemctl enable step-ca   # Enable step-ca on startup"
	echo "|      systemctl start step-ca    # Start step-ca service"
	echo "|"
fi
echo "=================================================="
echo ""
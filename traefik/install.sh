#!/bin/bash

set -e

# Muda para a pasta do script
cd $(dirname $0)

TRAEFIK_IMAGE=https://github.com/traefik/traefik/releases/download/v2.10.4/traefik_v2.10.4_linux_amd64.tar.gz
TRAEFIK_ACME=https://github.com/smallstep/certificates/releases/download/v0.24.2/step-ca_linux_0.24.2_amd64.tar.gz
TRAEFIK_CONFIG_TOML_PATH=/etc/traefik/traefik.toml
TRAEFIK_CONFIG_SYSTEMD_DIR=/etc/systemd/system

#===============================
# Checking mode
#===============================
echo "=================================================="
echo "| Responda com cuidado!!!!!"
echo "=================================================="
echo "Instalador do traefik."
read -p "Você está em uma máquina de dev ou prod? "
echo ""
TRAEFIK_DEVELOPMENT=1
if [[ "$REPLY" =~ ^[Dd][Ee][Vv]$ ]]; then
	TRAEFIK_DEVELOPMENT=1
elif [[ "$REPLY" =~ ^[Pp][Rr][Oo][Dd]$ ]]; then
	TRAEFIK_DEVELOPMENT=0
else
	echo "Você deve responder com dev ou prod";
	exit 1
fi

#===============================
# Install traefik binary
#===============================

echo "--------"
echo "TRAEFIK"
echo "  Instala o traefik como binário local em /usr/local/bin/traefik"
echo ""
INSTALL_TRAEFIK=1
if [ -f "/usr/local/bin/traefik" ]; then 
	INSTALL_TRAEFIK=0
	read -p "Traefik já está instalado. Sobreescrever? [s/N]: "
	if [[ "$REPLY" =~ ^[Ss]$ ]]; then
		INSTALL_TRAEFIK=1
	else
		echo "Pulando instalação";
	fi
fi
if [ "$INSTALL_TRAEFIK" = "1" ]; then
	echo "Fazendo download do traefik..."
	mkdir -p /tmp/traefik
	curl -fL "$TRAEFIK_IMAGE" -o /tmp/traefik/traefik.tar.gz
	mkdir -p /tmp/traefik/extracted-files
	tar xvf /tmp/traefik/traefik.tar.gz -C /tmp/traefik/extracted-files
	sudo mv /tmp/traefik/extracted-files/traefik /usr/local/bin/traefik
	echo "Traefik instalado"
fi
echo ""

#===============================
# Install traefik config
#===============================
echo "--------"
echo "Configuração do traefik (traefik.toml)"
echo "  Instala o traefik como binário local em ${TRAEFIK_CONFIG_TOML_PATH}"
echo ""
INSTALL_TRAEFIK_TOML=1
if [ -f "$TRAEFIK_CONFIG_TOML_PATH" ]; then 
	INSTALL_TRAEFIK_TOML=0
	read -p "Traefik já configurado. Sobreescrever? [s/N]: "
	if [[ "$REPLY" =~ ^[Ss]$ ]]; then
		INSTALL_TRAEFIK_TOML=1
	else
		echo "Pulando configuração";
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

	echo "Copiando traefik.toml para $TRAEFIK_CONFIG_TOML_PATH"
	sudo cp "$TRAEFIK_CONFIG_TOML_PATH_LOCAL" "$TRAEFIK_CONFIG_TOML_PATH"

	echo "Copiando config.toml para $TRAEFIK_CONFIG_TOML_DIR"
	sudo cp config.toml "$TRAEFIK_CONFIG_TOML_DIR/config.toml"

	echo "Configuração do traefik instalada"
fi
echo ""

#===============================
# Install traefik service
#===============================
echo "--------"
echo "traefik.service"
echo "  O serviço do traefik permite que ele se inicialize sozinho ao ligar o sistema"
echo ""
INSTALL_TRAEFIK_SERVICE=0
if [ -d "/etc/systemd" ]; then 
	if [ -f "$TRAEFIK_CONFIG_SYSTEMD_DIR/traefik.service" ]; then
		read -p "Serviço do traefik no systemd já instalado. Sobreescrever? [s/N]: "
	else
		read -p "Instalar o serviço do traefik systemd? [s/N]: "
	fi
	if [[ "$REPLY" =~ ^[Ss]$ ]]; then
		INSTALL_TRAEFIK_SERVICE=1
	else
		echo "Pulando systemd para o traefik.";
	fi
else
	echo "Sistema sem systemd";
fi
if [ "$INSTALL_TRAEFIK_SERVICE" = "1" ]; then
	echo "Copiando traefik.service para $TRAEFIK_CONFIG_SYSTEMD_DIR"
	sudo cp traefik.service "$TRAEFIK_CONFIG_SYSTEMD_DIR/traefik.service" 
	sudo systemctl daemon-reload
	echo "traefik.service configurado"
fi
echo ""

#===============================
# Install step-ca
#===============================
INSTALL_ACME_SERVER=0
if [ "$TRAEFIK_DEVELOPMENT" = "1" ]; then
	echo "--------"
	echo "HTTPS local"
	echo "  Instala o step-ca para gerar certificados locais e usar o https"
	echo ""
	INSTALL_ACME_SERVER=1
	if [ -f "/usr/local/bin/step-ca" ]; then 
		INSTALL_ACME_SERVER=0
		read -p "Servidor para gerar certificados https já instalado? [s/N]: "
		if [[ "$REPLY" =~ ^[Ss]$ ]]; then
			INSTALL_ACME_SERVER=1
		else
			echo "Pulando serviço step-ca";
		fi
	fi
	if [ "$INSTALL_ACME_SERVER" = "1" ]; then
		echo "Fazendo download do step-ca..."
		mkdir -p /tmp/step-ca
		curl -fL "$TRAEFIK_ACME" -o /tmp/step-ca/step-ca.tar.gz
		mkdir -p /tmp/step-ca/extracted-files
		tar xvf /tmp/step-ca/step-ca.tar.gz --strip-components=1 -C /tmp/step-ca/extracted-files
		sudo mv /tmp/step-ca/extracted-files/step-ca /usr/local/bin/step-ca
		echo "StepCA instalado em /usr/local/bin/step-ca"
	fi


	if [ ! -f "/etc/traefik/step/ca.json" ]; then
		echo "Copiando configuração"
		sudo mkdir -p /etc/traefik/step
		sudo cp step-ca.json /etc/traefik/step/ca.json
	else
		echo "Configuração já instalada em /etc/traefik/step/ca.json"
		echo "Se quiser reinstalar apague e rode o script novamente"
	fi

	if [ ! -f "/etc/traefik/certs/root.pem" ]; then
		echo "Gerando certificados certificates"
		sudo mkdir -p /etc/traefik/certs /etc/traefik/step

		pushd /etc/traefik/certs
		sudo openssl genrsa -out root.pem 4096
		sudo openssl req -x509 -new -nodes -key root.pem -sha256 -days 9999 -out root.crt -subj "/C=US/ST=CA/O=localhost/CN=localhost"

		if command -v update-ca-certificates &> /dev/null; then
			sudo rm -f /usr/local/share/ca-certificates/root-localhost.crt
			sudo ln -s /etc/traefik/certs/root.crt /usr/local/share/ca-certificates/root-localhost.crt
			sudo update-ca-certificates
		elif command -v trust &> /dev/null; then
			sudo trust anchor --store /etc/traefik/certs/root.crt
		else
			echo "Não foi possível confiar no certificado /etc/traefik/certs/root.crt"
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
	echo "--------"
	echo "step-ca.service"
	echo "  Serviço para o step-ca"
	echo ""
	if [ -d "/etc/systemd" ]; then 
		if [ -f "$TRAEFIK_CONFIG_SYSTEMD_DIR/step-ca.service" ]; then
			read -p "Serviço do step-ca no systemd já instalado. Sobreescrever? [s/N]: "
		else
			read -p "Instalar step-ca.service no systemd? [s/N]: "
		fi
		if [[ "$REPLY" =~ ^[Ss]$ ]]; then
			INSTALL_ACME_SERVICE=1
		fi
	fi
	if [ "$INSTALL_ACME_SERVICE" = "1" ]; then
		echo "Copiando step-ca.service para $TRAEFIK_CONFIG_SYSTEMD_DIR"
		sudo cp step-ca.service "$TRAEFIK_CONFIG_SYSTEMD_DIR/step-ca.service" 
		sudo systemctl daemon-reload
		echo "step-ca.service instalado"
	else
		echo "Pulando instalação do serviço do systemd.";
	fi
fi

#===============================
# Final print
#===============================
echo ""
echo "=================================================="
echo "|"
echo "| Instalação concluída"
echo "|"
echo "| Para habilitar os serviços rode: "
echo "|"
echo "|        sudo systemctl enable traefik --now # Se instalou o traefik"
echo "|        sudo systemctl enable step-ca --now # Se instalou o step-ca"
echo "|"
echo "| Se seu sistema possuí um SELinux e instalou o step-ca: "
echo "|      sudo chcon -t bin_t /usr/local/bin/step-ca # If on SELinux"
echo "|"
echo "=================================================="
echo ""

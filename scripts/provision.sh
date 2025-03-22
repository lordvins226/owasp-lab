#!/bin/bash

echo "Démarrage du provisionnement de l'environnement de lab OWASP Top 10 sur Kali Linux..."

# Paramètres globaux
export LAB_HOME="/home/vagrant"
export TOOLS_DIR="$LAB_HOME/tools"
export LABS_DIR="$LAB_HOME/labs"
export GUIDES_DIR="$LAB_HOME/docs/guides"

# Configuration pour éviter les blocages pendant la mise à jour
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
apt-get update
#apt-get dist-upgrade -y

echo "Installation des dépendances de base..."

apt-get install -y \
    docker.io \
    docker-compose \
    openjdk-17-jdk \
    maven \
    nodejs \
    npm \
    python3-pip \
    git \
    unzip

# Vérification/Installation de Docker
systemctl enable docker
systemctl start docker

# Ajout de l'utilisateur vagrant au groupe docker
usermod -aG docker vagrant

# Créer les répertoires de travail
echo "Création des répertoires de travail..."
mkdir -p $TOOLS_DIR
mkdir -p $LABS_DIR/apps
mkdir -p $LABS_DIR/java-app
mkdir -p $LABS_DIR/mobile
mkdir -p $LABS_DIR/binaries
mkdir -p $GUIDES_DIR
#chown -R vagrant:vagrant $LAB_HOME

# Exécution des scripts d'installation
echo "Étape 1: Installation des applications vulnérables"
bash /vagrant/scripts/install_apps.sh

echo "Étape 2: Installation des outils de sécurité additionnels"
bash /vagrant/scripts/install_tools.sh

echo "Étape 3: Configuration de l'environnement"
bash /vagrant/scripts/setup_environment.sh

sed -i 's/XKBLAYOUT=".*"/XKBLAYOUT="us"/' /etc/default/keyboard
udevadm trigger --subsystem-match=input --action=change

echo "Provisionnement de l'environnement Kali Linux terminé!"
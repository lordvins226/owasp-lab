#!/bin/bash

echo "Installation des applications vulnérables pour les labs OWASP Top 10 sur Kali Linux..."

LAB_HOME="/home/vagrant"
LABS_DIR="$LAB_HOME/labs"
DATA_DIR="$LAB_HOME/data"
NODEGOAT_DIR="$LABS_DIR/apps/NodeGoat"

mkdir -p $LABS_DIR/apps
mkdir -p $LABS_DIR/java-app
mkdir -p $LABS_DIR/mobile
mkdir -p $LABS_DIR/binaries
mkdir -p $DATA_DIR/mobsf

# Créer un répertoire pour les fichiers docker-compose
mkdir -p $LABS_DIR/apps
cd $LABS_DIR/apps

# OWASP Juice Shop
echo "Configuration de OWASP Juice Shop..."
cat > $LABS_DIR/apps/docker-compose-juiceshop.yml << 'EOF'
version: '3'
services:
  juice-shop:
    image: bkimminich/juice-shop
    container_name: juice-shop
    ports:
      - "3000:3000"
    restart: unless-stopped
EOF

# NodeGoat
echo "Configuration de NodeGoat..."
if [ ! -d "$NODEGOAT_DIR" ]; then
  echo "Clonage du dépôt NodeGoat..."
  git clone --depth 1 https://github.com/OWASP/NodeGoat.git "$NODEGOAT_DIR"
fi

# Téléchargement d'échantillons pour les tests
echo "Téléchargement d'échantillons pour les tests..."

# Application Java vulnérable pour SonarQube
cd $LABS_DIR/java-app
if [ ! -d "benchmark" ]; then
    git clone --depth 1 https://github.com/OWASP-Benchmark/BenchmarkJava.git
fi

# Fichiers APK pour MobSF
cd $LABS_DIR/mobile
if [ ! -f "UnCrackable-Level1.apk" ]; then
    wget -q "https://github.com/OWASP/owasp-mstg/raw/master/Crackmes/Android/Level_01/UnCrackable-Level1.apk" -O UnCrackable-Level1.apk
fi
if [ ! -f "UnCrackable-Level2.apk" ]; then
    wget -q "https://github.com/OWASP/owasp-mstg/raw/master/Crackmes/Android/Level_02/UnCrackable-Level2.apk" -O UnCrackable-Level2.apk
fi
if [ ! -f "diva-beta.apk" ]; then
    wget -q "https://raw.githubusercontent.com/tjunxiang92/Android-Vulnerabilities/refs/heads/master/diva-beta.apk"
fi

# Binaires vulnérables pour Ghidra
cd $LABS_DIR/binaries
if [ ! -f "lab1A" ]; then
    wget -q "https://github.com/RPISEC/MBE/raw/master/src/lab01/lab1A" -O lab1A
    chmod +x lab1A
fi
if [ ! -f "lab2A" ]; then
    wget -q "https://github.com/RPISEC/MBE/raw/master/src/lab02/lab2A" -O lab2A
    chmod +x lab2A
fi

# Nettoyage des conteneurs existants
echo "Nettoyage des conteneurs existants..."
docker stop webgoat dvwa juice-shop nodegoat mongo 2>/dev/null
docker rm webgoat dvwa juice-shop nodegoat mongo 2>/dev/null

# Démarrage des applications
echo "Démarrage des applications vulnérables..."

# Démarrage de Juice Shop
cd $LABS_DIR/apps
docker-compose -f docker-compose-juiceshop.yml up -d

# Démarrage de NodeGoat
cd $NODEGOAT_DIR
echo "Construction des images NodeGoat..."
docker-compose build
echo "Démarrage de NodeGoat..."
docker-compose up -d

# Démarrage de WebGoat
echo "Démarrage de WebGoat..."
docker run -d --name webgoat \
  -p 8081:8080 -p 9090:9090 \
  -e WEBGOAT_HOST=www.webgoat.local \
  -e WEBWOLF_HOST=www.webwolf.local \
  -e TZ=America/New_York \
  webgoat/webgoat

# Démarrage de DVWA
echo "Démarrage de DVWA..."
docker run -d --name dvwa \
  -p 8888:80 \
  kaakaww/dvwa-docker:latest

# Correction des permissions
chown -R vagrant:vagrant $LABS_DIR
chown -R vagrant:vagrant $DATA_DIR

echo "Applications vulnérables installées et démarrées sur Kali Linux."
echo "Échantillons de tests téléchargés avec succès."
echo ""
echo "Applications disponibles:"
echo "- WebGoat:      http://localhost:8081/WebGoat"
echo "- WebWolf:      http://localhost:9090/WebWolf"
echo "- DVWA:         http://localhost:8888 (admin/password)"
echo "- Juice Shop:   http://localhost:3000"
echo "- NodeGoat:     http://localhost:4000 (admin/Admin_123)"
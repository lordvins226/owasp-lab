#!/bin/bash

echo "Installation des applications vulnérables pour les labs OWASP Top 10 sur Kali Linux..."

# Définition des variables
LAB_HOME="/home/vagrant"
LABS_DIR="$LAB_HOME/labs"
DATA_DIR="$LAB_HOME/data"

# Création des répertoires nécessaires
mkdir -p $LABS_DIR/apps
mkdir -p $LABS_DIR/java-app
mkdir -p $LABS_DIR/mobile
mkdir -p $LABS_DIR/binaries
mkdir -p $DATA_DIR/nodegoat-db
mkdir -p $DATA_DIR/mobsf

# Configurer les permissions pour MongoDB
chmod -R 777 $DATA_DIR/nodegoat-db

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
cat > $LABS_DIR/apps/docker-compose-nodegoat.yml << 'EOF'
version: '3'
services:
  web:
    build:
      context: https://github.com/OWASP/NodeGoat.git
    container_name: nodegoat
    ports:
      - "4000:4000"
    environment:
      - MONGODB_URI=mongodb://mongo:27017/nodegoat
    depends_on:
      - mongo
    restart: unless-stopped
  mongo:
    image: mongo:4.4
    container_name: mongo-nodegoat
    ports:
      - "27017:27017"
    volumes:
      - /home/vagrant/data/nodegoat-db:/data/db
    restart: unless-stopped
EOF

# Téléchargement d'échantillons pour les tests
echo "Téléchargement d'échantillons pour les tests..."

# Application Java vulnérable pour SonarQube
cd $LABS_DIR/java-app
if [ ! -d "benchmark" ]; then
    git clone --depth 1 https://github.com/OWASP/benchmark.git
fi

# Fichiers APK pour MobSF
cd $LABS_DIR/mobile
if [ ! -f "UnCrackable-Level1.apk" ]; then
    wget -q "https://github.com/OWASP/owasp-mstg/raw/master/Crackmes/Android/Level_01/UnCrackable-Level1.apk" -O UnCrackable-Level1.apk
fi
if [ ! -f "UnCrackable-Level2.apk" ]; then
    wget -q "https://github.com/OWASP/owasp-mstg/raw/master/Crackmes/Android/Level_02/UnCrackable-Level2.apk" -O UnCrackable-Level2.apk
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


# Démarrage des applications avec Docker Compose
echo "Démarrage de Juice Shop et NodeGoat avec Docker Compose..."
cd $LABS_DIR/apps
docker-compose -f docker-compose-juiceshop.yml up -d
docker-compose -f docker-compose-nodegoat.yml up -d

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

# Initialisation de la base de données NodeGoat
echo "Initialisation de la base de données NodeGoat..."
sleep 10  # Attendre que la base démarre complètement
docker exec nodegoat npm run db:seed 2>/dev/null || echo "NodeGoat seed failed - will retry on next startup"

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
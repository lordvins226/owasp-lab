#!/bin/bash

echo "Installation des applications vulnérables pour les labs OWASP Top 10 sur Kali Linux..."

# Créer un répertoire pour les fichiers docker-compose
cd /home/vagrant/labs/apps

# WebGoat
echo "Configuration de WebGoat..."
cat > docker-compose-webgoat.yml << 'EOF'
version: '3'
services:
  webgoat:
    image: webgoat/webgoat
    container_name: webgoat
    environment:
      - WEBWOLF_HOST=webwolf
      - WEBWOLF_PORT=9090
    ports:
      - "8081:8080"
      - "9090:9090"
    restart: unless-stopped
EOF

# OWASP Juice Shop
echo "Configuration de OWASP Juice Shop..."
cat > docker-compose-juiceshop.yml << 'EOF'
version: '3'
services:
  juice-shop:
    image: bkimminich/juice-shop
    container_name: juice-shop
    ports:
      - "3000:3000"
    restart: unless-stopped
EOF

# DVWA
echo "Configuration de DVWA..."
cat > docker-compose-dvwa.yml << 'EOF'
version: '3'
services:
  dvwa:
    image: vulnerables/web-dvwa
    container_name: dvwa
    ports:
      - "80:80"
    restart: unless-stopped
EOF

# MobSF
echo "Configuration de MobSF..."
cat > docker-compose-mobsf.yml << 'EOF'
version: '3'
services:
  mobsf:
    image: opensecurity/mobile-security-framework-mobsf
    container_name: mobsf
    ports:
      - "8000:8000"
    volumes:
      - /home/vagrant/data/mobsf:/home/mobsf/.MobSF
    restart: unless-stopped
EOF

mkdir -p /home/vagrant/data/mobsf

# NodeGoat
echo "Configuration de NodeGoat..."
mkdir -p /home/vagrant/labs/apps/nodegoat
cat > docker-compose-nodegoat.yml << 'EOF'
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

mkdir -p /home/vagrant/data/nodegoat-db

# Téléchargement parallèle des images Docker (optimisation)
echo "Téléchargement des images Docker en parallèle..."
docker pull webgoat/webgoat &
docker pull bkimminich/juice-shop &
docker pull vulnerables/web-dvwa &
docker pull opensecurity/mobile-security-framework-mobsf &
docker pull mongo:4.4
wait

# Démarrage des applications
echo "Démarrage des applications vulnérables..."
docker-compose -f docker-compose-webgoat.yml up -d
docker-compose -f docker-compose-juiceshop.yml up -d
docker-compose -f docker-compose-dvwa.yml up -d
docker-compose -f docker-compose-mobsf.yml up -d
docker-compose -f docker-compose-nodegoat.yml up -d

# Initialisation de la base de données NodeGoat
echo "Initialisation de la base de données NodeGoat..."
sleep 10  # Attendre que la base démarre complètement
docker exec nodegoat npm run db:seed

# Correction des permissions
chown -R vagrant:vagrant /home/vagrant/data
chown -R vagrant:vagrant /home/vagrant/labs/apps

echo "Applications vulnérables installées et démarrées sur Kali Linux."
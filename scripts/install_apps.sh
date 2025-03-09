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

# ELK Stack
echo "Configuration d'ELK Stack pour les exercices de logging et monitoring..."
cat > docker-compose-elk.yml << 'EOF'
version: '3'
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.17.0
    container_name: elasticsearch
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    ports:
      - "9200:9200"
    volumes:
      - esdata:/usr/share/elasticsearch/data
    restart: unless-stopped

  logstash:
    image: docker.elastic.co/logstash/logstash:7.17.0
    container_name: logstash
    ports:
      - "5044:5044"
    volumes:
      - /home/vagrant/data/logstash:/etc/logstash/conf.d
    depends_on:
      - elasticsearch
    restart: unless-stopped

  kibana:
    image: docker.elastic.co/kibana/kibana:7.17.0
    container_name: kibana
    ports:
      - "5601:5601"
    depends_on:
      - elasticsearch
    restart: unless-stopped

volumes:
  esdata:
EOF

# Création du répertoire pour les données Logstash
mkdir -p /home/vagrant/data/logstash
mkdir -p /home/vagrant/data/mobsf

# Configuration de base pour Logstash
cat > /home/vagrant/data/logstash/logstash.conf << 'EOF'
input {
  beats {
    port => 5044
  }
}

filter {
  if [type] == "security" {
    grok {
      match => { "message" => "%{COMBINEDAPACHELOG}" }
    }
    date {
      match => [ "timestamp" , "dd/MMM/yyyy:HH:mm:ss Z" ]
    }
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "%{[@metadata][beat]}-%{+YYYY.MM.dd}"
  }
}
EOF

# Téléchargement parallèle des images Docker (optimisation)
echo "Téléchargement des images Docker en parallèle..."
docker pull webgoat/webgoat &
docker pull bkimminich/juice-shop &
docker pull vulnerables/web-dvwa &
docker pull opensecurity/mobile-security-framework-mobsf &
docker pull docker.elastic.co/elasticsearch/elasticsearch:7.17.0 &
docker pull docker.elastic.co/logstash/logstash:7.17.0 &
docker pull docker.elastic.co/kibana/kibana:7.17.0 &
wait

# Démarrage des applications
echo "Démarrage des applications vulnérables..."
docker-compose -f docker-compose-webgoat.yml up -d
docker-compose -f docker-compose-juiceshop.yml up -d
docker-compose -f docker-compose-dvwa.yml up -d
docker-compose -f docker-compose-mobsf.yml up -d
docker-compose -f docker-compose-elk.yml up -d

# Correction des permissions
chown -R vagrant:vagrant /home/vagrant/data
chown -R vagrant:vagrant /home/vagrant/labs/apps

echo "Applications vulnérables installées et démarrées sur Kali Linux."
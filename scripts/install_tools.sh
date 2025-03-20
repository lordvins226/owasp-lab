#!/bin/bash

echo "Installation des outils de sécurité pour les labs OWASP Top 10 sur Kali Linux..."

# Utiliser les variables globales déjà définies dans provision.sh
LAB_HOME="/home/vagrant"
TOOLS_DIR="$LAB_HOME/tools"
LABS_DIR="$LAB_HOME/labs"
DATA_DIR="$LAB_HOME/data"
GUIDES_DIR="$LAB_HOME/docs/guides"


# Configuration du système pour SonarQube
echo "Configuration système pour SonarQube..."
sudo sysctl -w vm.max_map_count=524288
sudo sysctl -w fs.file-max=131072
echo "vm.max_map_count=524288" | sudo tee -a /etc/sysctl.conf
echo "fs.file-max=131072" | sudo tee -a /etc/sysctl.conf

# 1. SonarQube via Docker
echo "Installation de SonarQube..."
cd $TOOLS_DIR

cat > docker-compose-sonarqube.yml << 'EOF'
version: '3'
services:
  sonarqube:
    image: sonarqube:lts
    container_name: sonarqube
    ports:
      - "9000:9000"
    environment:
      - SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_logs:/opt/sonarqube/logs
      - sonarqube_extensions:/opt/sonarqube/extensions
    restart: unless-stopped

volumes:
  sonarqube_data:
  sonarqube_logs:
  sonarqube_extensions:
EOF

docker pull sonarqube:lts
docker-compose -f docker-compose-sonarqube.yml up -d

# Configuration OWASP pour SonarQube
mkdir -p $TOOLS_DIR/sonarqube-config
cat > $TOOLS_DIR/sonarqube-config/setup-owasp-profile.sh << 'EOF'
#!/bin/bash
# Ce script configure un profil OWASP Top 10 pour les langages courants

# Créer un profil de qualité OWASP pour Java
curl -X POST -u admin:admin "http://localhost:9000/api/qualityprofiles/create" \
  -d "language=java&name=OWASP-Top10"

# Activer les règles pertinentes (à personnaliser selon les besoins)
echo "Profil OWASP créé dans SonarQube. Veuillez finaliser la configuration via l'interface web."
EOF
chmod +x $TOOLS_DIR/sonarqube-config/setup-owasp-profile.sh

# 2. Installation de Nessus Expert
echo "Installation de Nessus Expert 10.8.3..."
mkdir -p $TOOLS_DIR/nessus
cd $TOOLS_DIR/nessus

# Téléchargement de Nessus Expert
if [ ! -f "Nessus-10.8.3-debian10_amd64.deb" ]; then
    echo "Téléchargement de Nessus Expert 10.8.3..."
    curl --request GET \
      --url 'https://www.tenable.com/downloads/api/v2/pages/nessus/files/Nessus-10.8.3-debian10_amd64.deb' \
      --output 'Nessus-10.8.3-debian10_amd64.deb'
fi

# Installation du package Nessus
echo "Installation du package Nessus..."
sudo dpkg -i Nessus-10.8.3-debian10_amd64.deb || true

# Démarrage du service Nessus
echo "Démarrage du service Nessus..."
sudo systemctl enable nessusd
sudo systemctl start nessusd

# Script d'activation de licence Nessus
cat > $TOOLS_DIR/nessus/activate_nessus.sh << 'EOF'
#!/bin/bash
# Script pour activer la licence Nessus
# Usage: ./activate_nessus.sh XXXX-XXXX-XXXX-XXXX

if [ -z "$1" ]; then
    echo "Erreur: Code de licence manquant"
    echo "Usage: ./activate_nessus.sh XXXX-XXXX-XXXX-XXXX"
    exit 1
fi

LICENSE_CODE=$1

# Enregistrement de la licence
echo "Enregistrement de la licence Nessus..."
sudo /opt/nessus/sbin/nessuscli fetch --register $LICENSE_CODE

# Mise à jour des plugins
echo "Mise à jour des plugins Nessus. Cette opération peut prendre du temps..."
sudo /opt/nessus/sbin/nessuscli update --all

echo "Activation terminée. Nessus est accessible à l'adresse: https://localhost:8834"
EOF
chmod +x $TOOLS_DIR/nessus/activate_nessus.sh

# 3. Installation de Burp Suite
echo "Installation de Burp Suite Community 2025.1.5..."
mkdir -p $TOOLS_DIR/burpsuite
cd $TOOLS_DIR/burpsuite

# Détection de l'architecture
ARCH=$(uname -m)
if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
    BURP_URL="https://portswigger-cdn.net/burp/releases/download?product=community&version=2025.1.5&type=LinuxArm64"
    BURP_FILENAME="burpsuite_community_linux_arm64_v2025_1_5.sh"
else
    BURP_URL="https://portswigger-cdn.net/burp/releases/download?product=community&version=2025.1.5&type=Linux"
    BURP_FILENAME="burpsuite_community_linux_v2025_1_5.sh"
fi

# Vérification si Burp Suite est déjà installé sur Kali
if command -v burpsuite &> /dev/null; then
    echo "Burp Suite Community Edition est déjà installé sur ce système Kali."
else
    # Téléchargement de Burp Suite Community
    if [ ! -f "$BURP_FILENAME" ]; then
        echo "Téléchargement de Burp Suite Community 2025.1.5..."
        wget -q "$BURP_URL" -O "$BURP_FILENAME"
        chmod +x "$BURP_FILENAME"
    fi

    echo "Fichier d'installation Burp Suite Community téléchargé: $BURP_FILENAME"
    echo "Pour l'installer, exécutez: ./$BURP_FILENAME"
fi

# Téléchargement de Jython pour les extensions Burp
if [ ! -f "jython-installer-2.7.4.jar" ]; then
    wget -q https://repo1.maven.org/maven2/org/python/jython-installer/2.7.4/jython-installer-2.7.4.jar
fi

# Script de lancement de Burp Suite
cat > $TOOLS_DIR/burpsuite/burpsuite_launcher.sh << 'EOF'
#!/bin/bash
# Script de lancement pour Burp Suite

# Vérifier si la commande burpsuite existe
if command -v burpsuite &> /dev/null; then
    # Utiliser la version installée par le système
    burpsuite "$@"
else
    # Chercher l'installation locale et l'exécuter
    COMMUNITY_INSTALL=$(find . -name "burpsuite_community_linux*.sh" -type f | sort -r | head -n 1)

    if [ -n "$COMMUNITY_INSTALL" ]; then
        echo "Exécution de Burp Suite Community via le script d'installation local..."
        bash "$COMMUNITY_INSTALL" "$@"
    else
        echo "Burp Suite n'est pas disponible. Veuillez installer Burp Suite Community ou Professional."
    fi
fi
EOF
chmod +x $TOOLS_DIR/burpsuite/burpsuite_launcher.sh

# 4. Installation de Ghidra
echo "Installation de Ghidra 11.2.1..."
mkdir -p $TOOLS_DIR/ghidra
cd $TOOLS_DIR/ghidra

# Vérification si Ghidra est déjà installé sur Kali
if [ -d "/usr/share/ghidra" ]; then
    echo "Ghidra est déjà installé sur ce système Kali."
    # Créer un lien symbolique vers le répertoire d'installation
    ln -sf /usr/share/ghidra $TOOLS_DIR/ghidra/system
else
    # Téléchargement et installation de Ghidra
    if [ ! -f "ghidra_11.2.1_PUBLIC_20241105.zip" ]; then
        wget -q https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_11.2.1_build/ghidra_11.2.1_PUBLIC_20241105.zip
    fi

    # Extraction et installation
    unzip -q -o ghidra_11.2.1_PUBLIC_20241105.zip

    if [ -d "/opt/ghidra" ]; then
        sudo rm -rf /opt/ghidra
    fi
    sudo mv ghidra_11.2.1_PUBLIC /opt/ghidra
    sudo ln -sf /opt/ghidra/ghidraRun /usr/local/bin/ghidra
fi

# Installation de SDKMAN pour Java 21
if [ ! -d "$HOME/.sdkman" ]; then
    echo "Installation de SDKMAN..."
    curl -s "https://get.sdkman.io" | bash
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    chmod +x $HOME/.sdkman/bin/sdkman-init.sh

    # Installation de Java 21 via SDKMAN
    sdk install java 21.0.2-open || true
fi

# Script de lancement de Ghidra avec Java 21
cat > $TOOLS_DIR/ghidra/ghidra_launcher.sh << 'EOF'
#!/bin/bash
# Lance Ghidra avec Java 21

# Chargement de SDKMAN
source "$HOME/.sdkman/bin/sdkman-init.sh"

# Utilisation de Java 21
sdk use java 21.0.2-open

# Lancement de Ghidra
/usr/local/bin/ghidra "$@"
EOF
chmod +x $TOOLS_DIR/ghidra/ghidra_launcher.sh

# 5. Installation de MobSF
echo "Installation de MobSF (Mobile Security Framework)..."
mkdir -p $TOOLS_DIR/mobsf
cd $TOOLS_DIR/mobsf

# Création du fichier docker-compose.yml pour MobSF
cat > docker-compose.yml << 'EOF'
version: '3'
services:
  postgres:
    image: "postgres:15"
    container_name: mobsf_db
    healthcheck:
      test: ["CMD-SHELL", "pg_isready"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: always
    volumes:
      - mobsf_db:/opt/mobsf/postgresql
      - mobsf_db_data:/opt/mobsf/postgresql/data
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=mobsfpassword
      - POSTGRES_DB=mobsf
    networks:
      - mobsf_network

  nginx:
    image: nginx:latest
    container_name: mobsf_nginx
    restart: always
    ports:
      - "80:4000"
      - "1337:4001"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - mobsf_nginx_logs:/opt/mobsf/nginx/logs
    depends_on:
      - mobsf
    healthcheck:
      test: ["CMD", "nginx", "-t"]
      interval: 30s
      timeout: 10s
      retries: 3
    networks:
      - mobsf_network

  djangoq:
    image: opensecurity/mobile-security-framework-mobsf:latest
    container_name: mobsf_queue
    restart: unless-stopped
    command: /home/mobsf/Mobile-Security-Framework-MobSF/scripts/qcluster.sh
    volumes:
      - mobsf_data:/opt/mobsf/data
      - mobsf_shared:/opt/mobsf/shared
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=mobsfpassword
      - POSTGRES_DB=mobsf
      - POSTGRES_HOST=postgres
      - POSTGRES_PORT=5432
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - mobsf_network

  mobsf:
    image: opensecurity/mobile-security-framework-mobsf:latest
    container_name: mobsf_app
    restart: always
    tty: true
    volumes:
      - mobsf_conf:/opt/mobsf/conf
      - mobsf_data:/opt/mobsf/data
      - mobsf_logs:/opt/mobsf/logs
      - mobsf_uploads:/opt/mobsf/uploads
      - mobsf_shared:/opt/mobsf/shared
      - /home/vagrant/data/mobsf:/external_data
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=mobsfpassword
      - POSTGRES_DB=mobsf
      - POSTGRES_HOST=postgres
      - POSTGRES_PORT=5432
      - MOBSF_ASYNC_ANALYSIS=1
    healthcheck:
      test: curl -f http://localhost:8000/login/ || exit 1
      interval: 30s
      timeout: 10s
      retries: 5
    depends_on:
      postgres:
        condition: service_healthy
      djangoq:
        condition: service_started
    networks:
      - mobsf_network
    extra_hosts:
      - "host.docker.internal:host-gateway"

volumes:
  mobsf_conf:
  mobsf_data:
  mobsf_logs:
  mobsf_uploads:
  mobsf_shared:
  mobsf_db:
  mobsf_db_data:
  mobsf_nginx_logs:

networks:
  mobsf_network:
    driver: bridge
EOF

# Création du fichier nginx.conf pour MobSF
cat > nginx.conf << 'EOF'
user  nginx;
events {
    worker_connections   1000;
}

http {
    client_max_body_size 256M;
    upstream mobsf_upstream {
        server mobsf:8000;
        server mobsf:1337;
        keepalive 16;
    }

    map $server_port $forwarded_port {
        4000 443;
        4001 443;
    }

    proxy_set_header  X-Forwarded-Host    $host;
    proxy_set_header  X-Forwarded-Port    $forwarded_port;
    proxy_set_header  X-Forwarded-For     $proxy_add_x_forwarded_for;
    proxy_redirect    off;
    proxy_buffering   on;

    server {
        listen 4000;
        location / {
            proxy_pass          http://mobsf:8000;
            proxy_read_timeout  900;
            client_max_body_size 256M;
        }
    }

    server {
        listen 4001;
        location / {
            proxy_pass          http://mobsf:1337;
            proxy_read_timeout  120;
            client_max_body_size 10M;
        }
    }
}
EOF

# Scripts de gestion pour MobSF
cat > mobsf-start.sh << 'EOF'
#!/bin/bash
# Démarrage de MobSF
cd "$(dirname "$0")"
docker-compose up -d
echo "MobSF démarré. Accessible à l'adresse: http://localhost"
EOF

cat > mobsf-stop.sh << 'EOF'
#!/bin/bash
# Arrêt de MobSF
cd "$(dirname "$0")"
docker-compose down
echo "MobSF arrêté."
EOF

cat > mobsf-logs.sh << 'EOF'
#!/bin/bash
# Affichage des logs de MobSF
cd "$(dirname "$0")"
docker-compose logs -f
EOF

cat > mobsf-status.sh << 'EOF'
#!/bin/bash
# Statut de MobSF
cd "$(dirname "$0")"
docker-compose ps
EOF

chmod +x mobsf-start.sh mobsf-stop.sh mobsf-logs.sh mobsf-status.sh

# Démarrage de MobSF
echo "Téléchargement des images et démarrage de MobSF..."
docker-compose pull
docker-compose up -d

# Création d'un alias pour faciliter l'accès à Burp Suite (complément à setup_environment.sh)
if ! grep -q "burpsuite-lab" ~/.bashrc; then
    echo "alias burpsuite-lab='burpsuite'" >> ~/.bashrc
fi

# Correction des permissions
echo "Correction des permissions..."
chown -R vagrant:vagrant $TOOLS_DIR
chown -R vagrant:vagrant $LABS_DIR
chown -R vagrant:vagrant $DATA_DIR

echo "Installation des outils de sécurité terminée!"
echo "Vous pouvez maintenant utiliser ces outils pour les exercices OWASP Top 10."
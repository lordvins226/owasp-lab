#!/bin/bash

echo "Installation des outils de sécurité pour les labs OWASP Top 10 sur Kali Linux..."

# Utiliser les variables globales déjà définies dans provision.sh
LAB_HOME="/home/vagrant"
TOOLS_DIR="$LAB_HOME/tools"
LABS_DIR="$LAB_HOME/labs"
DATA_DIR="$LAB_HOME/data"
GUIDES_DIR="$LAB_HOME/docs/guides"

# Vérifier et créer les répertoires nécessaires
mkdir -p $TOOLS_DIR
mkdir -p $DATA_DIR

# Configuration du système pour SonarQube
echo "Configuration système pour SonarQube..."
sudo sysctl -w vm.max_map_count=524288
sudo sysctl -w fs.file-max=131072
echo "vm.max_map_count=524288" | sudo tee -a /etc/sysctl.conf
echo "fs.file-max=131072" | sudo tee -a /etc/sysctl.conf

# 1. SonarQube via Docker
echo "Installation de SonarQube..."
mkdir -p $TOOLS_DIR

cat > $TOOLS_DIR/docker-compose-sonarqube.yml << 'EOF'
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
cd $TOOLS_DIR
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

# 2. Installation de Nessus Expert (avec détection d'architecture)
echo "Installation de Nessus Expert..."
mkdir -p $TOOLS_DIR/nessus
cd $TOOLS_DIR/nessus

# Détection de l'architecture
ARCH=$(uname -m)
NESSUS_URL=""
NESSUS_FILENAME=""

if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
    echo "Architecture ARM détectée."
    NESSUS_URL="https://www.tenable.com/downloads/api/v2/pages/nessus/files/Nessus-10.8.3-ubuntu1804_aarch64.deb"
    NESSUS_FILENAME="Nessus-10.8.3-ubuntu1804_aarch64.deb"
else
    echo "Architecture x86_64 détectée."
    NESSUS_URL="https://www.tenable.com/downloads/api/v2/pages/nessus/files/Nessus-10.8.3-debian10_amd64.deb"
    NESSUS_FILENAME="Nessus-10.8.3-debian10_amd64.deb"
fi

# Téléchargement de Nessus Expert
if [ ! -f "$NESSUS_FILENAME" ]; then
    echo "Téléchargement de Nessus Expert pour $ARCH..."
    curl --request GET \
      --url "$NESSUS_URL" \
      --output "$NESSUS_FILENAME" || echo "Erreur lors du téléchargement de Nessus. Vérifiez l'URL et votre connexion."
fi

# Installation du package Nessus (uniquement si le fichier existe et a une taille > 0)
if [ -f "$NESSUS_FILENAME" ] && [ -s "$NESSUS_FILENAME" ]; then
    echo "Installation du package Nessus..."
    sudo dpkg -i "$NESSUS_FILENAME" || echo "Erreur lors de l'installation de Nessus, mais on continue."

    # Démarrage du service Nessus
    echo "Démarrage du service Nessus..."
    sudo systemctl enable nessusd || echo "Erreur lors de l'activation du service Nessus."
    sudo systemctl start nessusd || echo "Erreur lors du démarrage du service Nessus."
else
    echo "Le fichier Nessus n'a pas été téléchargé correctement. Vérifiez le téléchargement."
fi

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
echo "Installation de Burp Suite Community..."
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
        wget -q "$BURP_URL" -O "$BURP_FILENAME" || echo "Erreur lors du téléchargement de BurpSuite"
        chmod +x "$BURP_FILENAME"
    fi

    echo "Fichier d'installation Burp Suite Community téléchargé: $BURP_FILENAME"
    echo "Pour l'installer, exécutez: ./$BURP_FILENAME"
fi

# Téléchargement de Jython pour les extensions Burp
if [ ! -f "jython-installer-2.7.4.jar" ]; then
    wget -q https://repo1.maven.org/maven2/org/python/jython-installer/2.7.4/jython-installer-2.7.4.jar || echo "Erreur lors du téléchargement de Jython"
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
        wget -q https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_11.2.1_build/ghidra_11.2.1_PUBLIC_20241105.zip || echo "Erreur lors du téléchargement de Ghidra"
    fi

    # Extraction et installation seulement si le fichier a été téléchargé
    if [ -f "ghidra_11.2.1_PUBLIC_20241105.zip" ]; then
        unzip -q -o ghidra_11.2.1_PUBLIC_20241105.zip || echo "Erreur lors de l'extraction de Ghidra"

        if [ -d "ghidra_11.2.1_PUBLIC" ]; then
            if [ -d "/opt/ghidra" ]; then
                sudo rm -rf /opt/ghidra
            fi
            sudo mv ghidra_11.2.1_PUBLIC /opt/ghidra
            sudo ln -sf /opt/ghidra/ghidraRun /usr/local/bin/ghidra
        else
            echo "Extraction de Ghidra a échoué. Vérifiez le fichier ZIP."
        fi
    else
        echo "Le téléchargement de Ghidra a échoué. Vérifiez la connexion Internet."
    fi
fi

# Installation de SDKMAN et Java pour Ghidra
echo "Installation de SDKMAN et Java pour Ghidra..."

# Installation de SDKMAN - utilisation de /home/vagrant au lieu de $HOME
if [ ! -d "/home/vagrant/.sdkman" ]; then
    echo "Installation de SDKMAN..."
    su - vagrant -c "curl -s 'https://get.sdkman.io' | bash"

    # Attendre que SDKMAN soit installé
    sleep 2

    # Installation de Java 21 via SDKMAN
    if [ -f "/home/vagrant/.sdkman/bin/sdkman-init.sh" ]; then
        su - vagrant -c "source ~/.sdkman/bin/sdkman-init.sh && sdk install java 21.0.2-open"
    else
        echo "L'installation de SDKMAN a échoué, installation de Java via apt..."
        sudo apt-get update
        sudo apt-get install -y openjdk-17-jdk
    fi
else
    echo "SDKMAN est déjà installé, vérification/installation de Java 21..."
    su - vagrant -c "source ~/.sdkman/bin/sdkman-init.sh && sdk install java 21.0.2-open || echo 'Java 21 déjà installé ou erreur d'installation'"
fi

# Fallback - S'assurer qu'une version de Java est disponible
if ! command -v java &> /dev/null; then
    echo "Installation de Java via apt comme solution de secours..."
    sudo apt-get update
    sudo apt-get install -y openjdk-17-jdk
fi

# Script de lancement de Ghidra avec SDKMAN
cat > $TOOLS_DIR/ghidra/ghidra_launcher.sh << 'EOF'
#!/bin/bash
# Lance Ghidra avec Java 21 via SDKMAN si disponible

# Essayer d'utiliser SDKMAN si disponible
if [ -f "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    if sdk list java | grep -q "21.0.2-open"; then
        sdk use java 21.0.2-open
    fi
fi

# Vérifier si Java est disponible, sinon utiliser celui du système
if ! command -v java &> /dev/null; then
    echo "Aucun Java disponible via SDKMAN, utilisation de Java du système..."
fi

# Lancement de Ghidra
if [ -x "/usr/local/bin/ghidra" ]; then
    /usr/local/bin/ghidra "$@"
elif [ -x "/opt/ghidra/ghidraRun" ]; then
    /opt/ghidra/ghidraRun "$@"
else
    echo "Ghidra n'est pas installé correctement."
    exit 1
fi
EOF
chmod +x $TOOLS_DIR/ghidra/ghidra_launcher.sh


# 5. Installation de MobSF
echo "Installation de MobSF (Mobile Security Framework)..."
mkdir -p $TOOLS_DIR/mobsf
cd $TOOLS_DIR/mobsf

# Créer le répertoire pour les données de MobSF avec les bonnes permissions
mkdir -p $DATA_DIR/mobsf
#sudo chown -R 9901:9901 $DATA_DIR/mobsf
chmod -R 777 $DATA_DIR/mobsf
chmod -R 777 $TOOLS_DIR/mobsf



# Création du fichier docker-compose.yml pour MobSF
cat > $TOOLS_DIR/mobsf/docker-compose.yml << 'EOF'
services:
  mobsf:
    image: opensecurity/mobile-security-framework-mobsf:latest
    container_name: mobsf_app
    restart: unless-stopped
    ports:
      - "8000:8000"
    volumes:
      - /home/vagrant/data/mobsf:/home/mobsf/.MobSF
EOF

# Scripts de gestion pour MobSF
cat > $TOOLS_DIR/mobsf/mobsf-start.sh << 'EOF'
#!/bin/bash
# Démarrage de MobSF
cd "$(dirname "$0")"
docker-compose up -d
echo "MobSF démarré. Accessible à l'adresse: http://localhost:8000"
EOF

cat > $TOOLS_DIR/mobsf/mobsf-stop.sh << 'EOF'
#!/bin/bash
# Arrêt de MobSF
cd "$(dirname "$0")"
docker-compose down
echo "MobSF arrêté."
EOF

cat > $TOOLS_DIR/mobsf/mobsf-logs.sh << 'EOF'
#!/bin/bash
# Affichage des logs de MobSF
cd "$(dirname "$0")"
docker-compose logs -f mobsf
EOF

chmod +x $TOOLS_DIR/mobsf/mobsf-start.sh $TOOLS_DIR/mobsf/mobsf-stop.sh $TOOLS_DIR/mobsf/mobsf-logs.sh

# Démarrage de MobSF
echo "Téléchargement de l'image et démarrage de MobSF..."
cd $TOOLS_DIR/mobsf
docker-compose pull
docker-compose up -d

# Création d'un alias pour faciliter l'accès à Burp Suite (complément à setup_environment.sh)
if ! grep -q "burpsuite-lab" $LAB_HOME/.bashrc; then
    echo "alias burpsuite-lab='burpsuite'" >> $LAB_HOME/.bashrc
fi

# Correction des permissions
echo "Correction des permissions..."
chown -R vagrant:vagrant $TOOLS_DIR
chown -R vagrant:vagrant $LABS_DIR
chown -R vagrant:vagrant $DATA_DIR

echo "Installation des outils de sécurité terminée!"
echo "Vous pouvez maintenant utiliser ces outils pour les exercices OWASP Top 10."
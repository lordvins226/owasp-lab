#!/bin/bash

echo "Installation des outils de sécurité pour les labs OWASP Top 10 sur Kali Linux..."

# Créer un répertoire pour les outils
mkdir -p /home/vagrant/tools
cd /home/vagrant/tools

# 1. SonarQube via Docker (prioritaire)
echo "Installation de SonarQube..."
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

# Préparation de profils OWASP pour SonarQube
mkdir -p /home/vagrant/tools/sonarqube-config
cat > /home/vagrant/tools/sonarqube-config/setup-owasp-profile.sh << 'EOF'
#!/bin/bash
# Ce script sera exécuté manuellement après l'initialisation de SonarQube
# Il configure un profil OWASP Top 10 pour les langages courants

# Obtenez un token d'admin (à exécuter après avoir changé le mot de passe par défaut)
# TOKEN=$(curl -X POST -u admin:votre_nouveau_mdp "http://localhost:9000/api/user_tokens/generate" -d "name=api-token" | jq -r '.token')

# Créer un profil de qualité OWASP pour Java
curl -X POST -u admin:admin "http://localhost:9000/api/qualityprofiles/create" \
  -d "language=java&name=OWASP-Top10"

# Activer des règles spécifiques pour chaque catégorie OWASP
# Ce script est fourni comme exemple et devrait être complété manuellement
# via l'interface web pour plus de précision

echo "Profil OWASP créé dans SonarQube. Veuillez finaliser la configuration via l'interface web."
EOF
chmod +x /home/vagrant/tools/sonarqube-config/setup-owasp-profile.sh

# 2. Configuration de Burp Suite (déjà disponible sur Kali)
echo "Configuration de Burp Suite (natif de Kali)..."
mkdir -p /home/vagrant/tools/burpsuite
cat > /home/vagrant/tools/burpsuite/README.md << 'EOF'
# Utilisation de Burp Suite sur Kali Linux

Kali Linux inclut déjà Burp Suite Community Edition.

## Lancement
- Depuis le menu Applications > Web Application Analysis > burpsuite
- Ou via la commande: `burpsuite`

## Configuration recommandée pour les labs OWASP
1. Créer un nouveau projet temporaire
2. Configurer le navigateur pour utiliser le proxy Burp (127.0.0.1:8080)
3. Installer le certificat CA de Burp dans le navigateur

Consultez le guide complet dans `/home/vagrant/docs/guides/BurpSuite_Guide.md`
EOF

# 3. Installation et configuration de Nessus Expert
echo "Installation de Nessus Expert..."
mkdir -p /home/vagrant/tools/nessus

# Téléchargement de Nessus (l'utilisateur devra fournir le fichier d'installation)
cat > /home/vagrant/tools/nessus/README.md << 'EOF'
# Installation de Nessus Expert

## Prérequis
Nessus Expert est un logiciel commercial qui nécessite une licence.

## Procédure d'installation manuelle
1. Téléchargez le package d'installation depuis le site de Tenable: https://www.tenable.com/downloads/nessus
2. Copiez le fichier .deb dans ce répertoire (/home/vagrant/tools/nessus/)
3. Installez le package avec la commande:
   ```
   sudo dpkg -i Nessus-*.deb
   ```
4. Démarrez le service Nessus:
   ```
   sudo systemctl start nessusd
   ```
5. Accédez à l'interface web: https://localhost:8834
6. Suivez les instructions pour créer un compte et activer votre licence

## Configuration pour OWASP Top 10
Une fois Nessus installé, créez un scan avec les paramètres suivants:
1. Nouvelle analyse > Web Application Tests
2. Configurer les options de base:
   - Nom: "Scan OWASP Application Web"
   - Description: "Détection des vulnérabilités OWASP Top 10"
   - Targets: URL de l'application cible

3. Configurer les options avancées:
   - Assessment > Scan Type: "Scan for all web vulnerabilities"
   - Discovery > Maximum pages to crawl: Définir selon l'application
   - Authentication: Configurer si besoin
EOF

# Script d'installation de Nessus
cat > /home/vagrant/tools/nessus/install_nessus.sh << 'EOF'
#!/bin/bash
# Script pour installer Nessus Expert

# Vérifier si le fichier d'installation existe
NESSUS_DEB=$(ls -1 /home/vagrant/tools/nessus/Nessus-*.deb 2>/dev/null)

if [ -z "$NESSUS_DEB" ]; then
  echo "Aucun fichier d'installation Nessus trouvé."
  echo "Veuillez télécharger le package Nessus depuis https://www.tenable.com/downloads/nessus"
  echo "et le placer dans le répertoire /home/vagrant/tools/nessus/"
  exit 1
fi

# Installation de Nessus
echo "Installation de Nessus à partir de $NESSUS_DEB..."
sudo dpkg -i "$NESSUS_DEB"

# Démarrage du service
echo "Démarrage du service Nessus..."
sudo systemctl enable nessusd
sudo systemctl start nessusd

echo "Nessus est maintenant installé et démarré."
echo "Accédez à l'interface web: https://localhost:8834"
echo "Suivez les instructions pour créer un compte et activer votre licence."
EOF
chmod +x /home/vagrant/tools/nessus/install_nessus.sh

# 4. Installation/Vérification de Ghidra
echo "Installation de Ghidra..."
if [ -d "/usr/share/ghidra" ]; then
  echo "Ghidra est déjà installé sur Kali Linux."
  # Créer un lien symbolique vers le répertoire d'installation
  ln -sf /usr/share/ghidra /home/vagrant/tools/ghidra
else
  echo "Installation manuelle de Ghidra..."
  mkdir -p /home/vagrant/tools/ghidra
  cd /home/vagrant/tools/ghidra
  wget -q "https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_10.3.3_build/ghidra_10.3.3_PUBLIC_20230829.zip" -O ghidra.zip
  unzip -q ghidra.zip
  rm ghidra.zip
  ln -sf /home/vagrant/tools/ghidra/ghidra_10.3.3_PUBLIC/ghidraRun /usr/local/bin/ghidra
  chmod +x /usr/local/bin/ghidra
fi

# Création d'un projet Ghidra préconfiguré
mkdir -p /home/vagrant/tools/ghidra/projects
cat > /home/vagrant/tools/ghidra/create-project.sh << 'EOF'
#!/bin/bash
# Ce script crée un projet Ghidra pour l'analyse de binaires
# Il doit être exécuté manuellement car Ghidra nécessite une interface graphique

echo "Pour créer un projet Ghidra:"
echo "1. Lancez Ghidra avec la commande 'ghidra'"
echo "2. Sélectionnez 'File > New Project'"
echo "3. Choisissez 'Non-Shared Project'"
echo "4. Nommez le projet 'OWASP-Binaries'"
echo "5. Sélectionnez l'emplacement: /home/vagrant/tools/ghidra/projects"
echo ""
echo "Pour importer un binaire à analyser:"
echo "1. Dans le projet, sélectionnez 'File > Import File'"
echo "2. Naviguez vers /home/vagrant/labs/binaries/"
echo "3. Sélectionnez un binaire et lancez l'analyse"
EOF
chmod +x /home/vagrant/tools/ghidra/create-project.sh

# 5. Configuration de MobSF
echo "Configuration de MobSF via Docker..."
# Configuration Docker pour MobSF
mkdir -p /home/vagrant/labs/apps
cd /home/vagrant/labs/apps
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

# S'assurer que le répertoire de données existe
mkdir -p /home/vagrant/data/mobsf

# Téléchargement parallèle de l'image Docker
docker pull opensecurity/mobile-security-framework-mobsf &

# Configuration de scripts d'automatisation pour MobSF
mkdir -p /home/vagrant/tools/mobsf-scripts
cat > /home/vagrant/tools/mobsf-scripts/scan-apk.sh << 'EOF'
#!/bin/bash
# Script pour analyser automatiquement un APK avec MobSF
# Usage: ./scan-apk.sh [CHEMIN_APK]

APK_PATH=${1:-"/home/vagrant/labs/mobile/UnCrackable-Level1.apk"}
MOBSF_URL="http://localhost:8000"

echo "Tentative d'analyse automatique de l'APK: $APK_PATH"
echo "Assurez-vous que MobSF est en cours d'exécution sur $MOBSF_URL"
echo ""
echo "Procédure manuelle:"
echo "1. Ouvrez $MOBSF_URL dans votre navigateur"
echo "2. Téléversez le fichier APK"
echo "3. Examinez les résultats d'analyse"
echo ""
echo "Note: L'API REST de MobSF pourrait être utilisée pour automatiser cette procédure"
echo "Consultez la documentation MobSF pour plus d'informations sur l'API"
EOF
chmod +x /home/vagrant/tools/mobsf-scripts/scan-apk.sh

# 6. Installation d'outils supplémentaires utiles

# SQLMap pour les tests d'injection SQL
echo "Installation de SQLMap..."
# SQLMap est généralement déjà disponible sur Kali
if ! command -v sqlmap >/dev/null 2>&1; then
  git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git
  echo 'alias sqlmap="python3 /home/vagrant/tools/sqlmap/sqlmap.py"' >> /home/vagrant/.bashrc
  ln -s /home/vagrant/tools/sqlmap/sqlmap.py /usr/local/bin/sqlmap
  chmod +x /usr/local/bin/sqlmap
fi

# 7. Téléchargement de binaires et applications pour les tests
echo "Téléchargement d'échantillons pour les tests..."

# Création des répertoires nécessaires s'ils n'existent pas
mkdir -p /home/vagrant/labs/java-app
mkdir -p /home/vagrant/labs/mobile
mkdir -p /home/vagrant/labs/binaries

# Application Java vulnérable pour SonarQube
cd /home/vagrant/labs/java-app
git clone --depth 1 https://github.com/OWASP/benchmark.git

# Fichiers APK pour MobSF
cd /home/vagrant/labs/mobile
wget -q "https://github.com/OWASP/owasp-mstg/raw/master/Crackmes/Android/Level_01/UnCrackable-Level1.apk" -O UnCrackable-Level1.apk
wget -q "https://github.com/OWASP/owasp-mstg/raw/master/Crackmes/Android/Level_02/UnCrackable-Level2.apk" -O UnCrackable-Level2.apk

# Binaires vulnérables pour Ghidra
cd /home/vagrant/labs/binaries
wget -q "https://github.com/RPISEC/MBE/raw/master/src/lab01/lab1A" -O lab1A
chmod +x lab1A
wget -q "https://github.com/RPISEC/MBE/raw/master/src/lab02/lab2A" -O lab2A
chmod +x lab2A

# Correction des permissions
echo "Correction des permissions..."
chown -R vagrant:vagrant /home/vagrant/tools
chown -R vagrant:vagrant /home/vagrant/labs
chown -R vagrant:vagrant /home/vagrant/data

# Finalisation de l'installation de MobSF
cd /home/vagrant/labs/apps
# Attente de la fin du téléchargement de l'image Docker
wait
docker-compose -f docker-compose-mobsf.yml up -d

echo "Installation des outils terminée sur Kali Linux."
echo "Outils principaux configurés: SonarQube, Burp Suite, Nessus Expert, Ghidra, MobSF"
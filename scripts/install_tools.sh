#!/bin/bash

echo "Installation des outils de sécurité pour les labs OWASP Top 10 sur Kali Linux..."

# Créer un répertoire pour les outils
cd /home/vagrant/tools

# Vérification des outils déjà présents dans Kali Linux
echo "Vérification des outils natifs de Kali Linux..."
TOOLS_TO_CHECK=("burpsuite" "zaproxy" "sqlmap")
for tool in "${TOOLS_TO_CHECK[@]}"
do
  if command -v $tool >/dev/null 2>&1; then
    echo "$tool est déjà installé sur Kali."
  else
    echo "$tool n'est pas disponible, nous allons l'installer."
    apt-get install -y $tool
  fi
done

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

# 3. Configuration de OWASP ZAP (déjà disponible sur Kali)
echo "Configuration de OWASP ZAP (natif de Kali)..."
mkdir -p /home/vagrant/tools/zap/configs
cat > /home/vagrant/tools/zap/configs/owasp-top10-scan.sh << 'EOF'
#!/bin/bash
# Script pour lancer un scan OWASP Top 10 automatisé avec ZAP
# Usage: ./owasp-top10-scan.sh [URL_CIBLE] [FICHIER_SORTIE]

URL_CIBLE=${1:-"http://localhost:3000"}
FICHIER_SORTIE=${2:-"/home/vagrant/zap-report.html"}

echo "Lancement d'un scan OWASP Top 10 sur $URL_CIBLE"
echo "Le rapport sera sauvegardé dans $FICHIER_SORTIE"

zaproxy -cmd \
  -quickurl "${URL_CIBLE}" \
  -quickprogress \
  -quickout "${FICHIER_SORTIE}" \
  -quickformat html

echo "Scan terminé. Rapport disponible dans $FICHIER_SORTIE"
EOF
chmod +x /home/vagrant/tools/zap/configs/owasp-top10-scan.sh

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

# 5. Configuration de MobSF est déjà faite dans install_apps.sh
echo "Configuration de MobSF (déjà installée via Docker)..."

# 7. Téléchargement de binaires et applications pour les tests
echo "Téléchargement d'échantillons pour les tests..."

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

echo "Installation des outils terminée sur Kali Linux."
echo "Outils principaux configurés: SonarQube, Burp Suite, OWASP ZAP, Ghidra, MobSF"
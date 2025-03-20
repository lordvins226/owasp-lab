#!/bin/bash

echo "Configuration de l'environnement pour les labs OWASP Top 10 sur Kali Linux..."

# Création des répertoires pour les guides si synchronisés depuis Vagrant
if [ ! -d "/home/vagrant/docs/guides" ]; then
  mkdir -p /home/vagrant/docs/guides
fi

# Ajout des guides pratiques si non synchronisés
if [ ! -f "/home/vagrant/docs/guides/SonarQube_Guide.md" ]; then
  echo "Création des guides pratiques pour les outils..."

  # Création des guides individuels pour chaque outil
  # (Les mêmes que dans la version précédente)
  # ...
fi

# Création d'un guide pour NodeGoat
cat > /home/vagrant/docs/guides/NodeGoat_Guide.md << 'EOF'
# Guide Pratique : NodeGoat

## Introduction
NodeGoat est une application Node.js volontairement vulnérable, conçue pour illustrer les vulnérabilités de l'OWASP Top 10 dans un contexte Node.js. Elle inclut également un tutoriel explicatif pour comprendre et corriger ces vulnérabilités.

## Accès à l'application
- **URL principale**: http://localhost:4000
- **Tutoriel intégré**: http://localhost:4000/tutorial

## Comptes utilisateurs par défaut
- **Administrateur**: admin / Admin_123
- **Utilisateurs**:
  - user1 / User1_123
  - user2 / User2_123
- Vous pouvez également créer de nouveaux comptes via la page d'inscription.

## Vulnérabilités OWASP Top 10 démontrées
NodeGoat illustre toutes les vulnérabilités de l'OWASP Top 10 à travers son code source et son interface. Le tutoriel intégré explique chaque vulnérabilité et les méthodes pour les corriger.

### A01 - Broken Access Control
Explorez les failles de contrôle d'accès entre utilisateurs et administrateurs.

### A02 - Cryptographic Failures
Analysez comment les mots de passe et informations sensibles sont stockés et transmis.

### A03 - Injection
Testez les vulnérabilités d'injection NoSQL dans la base de données MongoDB.

### A04 - Insecure Design
Identifiez les problèmes de conception dans l'architecture de l'application.

### A05 - Security Misconfiguration
Observez les configurations par défaut non sécurisées.

### A06 - Vulnerable and Outdated Components
Examinez les dépendances utilisées dans l'application.

### A07 - Identification and Authentication Failures
Testez les mécanismes d'authentification et leurs faiblesses.

### A08 - Software and Data Integrity Failures
Analysez la validation des données et les processus de modification.

### A09 - Security Logging and Monitoring Failures
Observez les lacunes dans la journalisation et la surveillance.

### A10 - Server-Side Request Forgery
Explorez les possibilités de SSRF dans l'application.

## Exercices pratiques
1. **Connexion et exploration**:
   - Connectez-vous avec différents comptes (admin et utilisateur)
   - Observez les différences de fonctionnalités et privilèges

2. **Analyse du contrôle d'accès**:
   - Tentez d'accéder à des fonctionnalités administratives en tant qu'utilisateur standard
   - Manipulez les paramètres d'URL pour accéder à des ressources protégées

3. **Test d'injection NoSQL**:
   - Testez des techniques d'injection dans les formulaires de recherche
   - Utilisez Burp Suite pour intercepter et modifier les requêtes

4. **Identification des secrets codés en dur**:
   - Utilisez SonarQube pour analyser le code source
   - Identifiez les secrets et informations sensibles dans le code

5. **Correction des vulnérabilités**:
   - Suivez le tutoriel pour comprendre comment corriger chaque vulnérabilité
   - Appliquez ces corrections dans une copie locale du code

## Utilisation avec Burp Suite
1. Configurez Burp Suite comme proxy pour intercepter le trafic
2. Naviguez dans l'application et observez les requêtes
3. Modifiez les paramètres pour tester les vulnérabilités

## Utilisation avec SonarQube
1. Clonez le dépôt NodeGoat localement
2. Configurez un projet dans SonarQube
3. Lancez une analyse pour identifier les vulnérabilités dans le code

## Ressources complémentaires
- [Dépôt GitHub NodeGoat](https://github.com/OWASP/NodeGoat)
- [Documentation OWASP sur Node.js](https://owasp.org/www-project-nodejs-goat/)
EOF

# Configuration de l'environnement bash pour l'utilisateur vagrant
cat >> /home/vagrant/.bashrc << 'EOF'

# Configuration pour les labs OWASP Top 10
export LAB_HOME="/home/vagrant"
export TOOLS_DIR="$LAB_HOME/tools"
export LABS_DIR="$LAB_HOME/labs"

# Alias utiles pour les labs OWASP
alias ll='ls -la'
alias cls='clear'

# Alias pour les outils principaux
# Adaptés pour Kali Linux
alias burpsuite-lab='burpsuite'
alias nessus-status='systemctl status nessusd'
alias nessus-start='sudo systemctl start nessusd'
alias nessus-stop='sudo systemctl stop nessusd'
alias sonarqube-status='docker ps | grep sonarqube'
alias mobsf-status='docker ps | grep mobsf'
alias nodegoat-status='docker ps | grep nodegoat'

# Raccourcis pour les guides
alias guides='ls -la /home/vagrant/docs/guides'
alias show-guide='function _show_guide() { cat "/home/vagrant/docs/guides/$1" | less; }; _show_guide'

# Raccourcis pour les logs des applications
alias webgoat-logs='docker logs -f webgoat'
alias juiceshop-logs='docker logs -f juice-shop'
alias dvwa-logs='docker logs -f dvwa'
alias mobsf-logs='docker logs -f mobsf'
alias nodegoat-logs='docker logs -f nodegoat'

# Ouverture rapide de Nessus dans le navigateur
alias nessus-web='xdg-open https://localhost:8834'

# Ouverture rapide de NodeGoat dans le navigateur
alias nodegoat-web='xdg-open http://localhost:4000'
alias nodegoat-tutorial='xdg-open http://localhost:4000/tutorial'

# Fonction pour démarrer tous les services
start_all_services() {
  echo "Démarrage de tous les services..."
  cd /home/vagrant/labs/apps
  docker-compose -f docker-compose-webgoat.yml up -d
  docker-compose -f docker-compose-juiceshop.yml up -d
  docker-compose -f docker-compose-dvwa.yml up -d
  docker-compose -f docker-compose-mobsf.yml up -d
  docker-compose -f docker-compose-nodegoat.yml up -d
  cd /home/vagrant/tools
  docker-compose -f docker-compose-sonarqube.yml up -d
  echo "Tous les services démarrés."
}

# Fonction pour arrêter tous les services
stop_all_services() {
  echo "Arrêt de tous les services..."
  cd /home/vagrant/labs/apps
  docker-compose -f docker-compose-webgoat.yml down
  docker-compose -f docker-compose-juiceshop.yml down
  docker-compose -f docker-compose-dvwa.yml down
  docker-compose -f docker-compose-mobsf.yml down
  docker-compose -f docker-compose-nodegoat.yml down
  docker-compose -f docker-compose-elk.yml down
  cd /home/vagrant/tools
  docker-compose -f docker-compose-sonarqube.yml down
  echo "Tous les services arrêtés."
}

# Fonction pour afficher l'état de tous les services
status_services() {
  echo "État des services Docker:"
  docker ps
}

# Alias pour les fonctions
alias start_services='start_all_services'
alias stop_services='stop_all_services'
alias status='status_services'

EOF

# Création d'un raccourci sur le bureau pour lancer les outils (pour l'environnement graphique de Kali)
DESKTOP_DIR="/home/vagrant/Desktop"
if [ ! -d "$DESKTOP_DIR" ]; then
  mkdir -p "$DESKTOP_DIR"
fi

# Création des raccourcis sur le bureau
cat > "$DESKTOP_DIR/OWASP-Lab-Tools.desktop" << 'EOF'
[Desktop Entry]
Name=OWASP Lab Tools
Comment=Raccourcis pour les outils du lab OWASP
Exec=sh -c "xterm -e 'echo \"Bienvenue dans le Lab OWASP Top 10\" && echo \"\" && echo \"Les outils disponibles sont:\" && echo \" - SonarQube: http://localhost:9000\" && echo \" - Burp Suite: burpsuite\" && echo \" - Nessus Expert: https://localhost:8834\" && echo \" - Ghidra: ghidra\" && echo \" - MobSF: http://localhost:8000\" && echo \" - NodeGoat: http://localhost:4000\" && echo \"\" && echo \"Appuyez sur Enter pour fermer cette fenêtre.\" && read'"
Icon=kali-bugs-reporting
Terminal=false
Type=Application
Categories=Application;
EOF

# Rendre les fichiers exécutables
chmod +x "$DESKTOP_DIR/OWASP-Lab-Tools.desktop"

# Créer un lien symbolique pour faciliter l'accès aux exercices
ln -sf /home/vagrant/exercises /home/vagrant/Desktop/OWASP-Exercises

# Correction des permissions
chown -R vagrant:vagrant /home/vagrant/.bashrc
chown -R vagrant:vagrant "$DESKTOP_DIR"

# Création du fichier README pour les exercices
cat > /home/vagrant/README.md << 'EOF'
# Environnement de Lab OWASP Top 10 sur Kali Linux

Cet environnement Vagrant basé sur Kali Linux contient tous les outils et applications nécessaires pour réaliser les exercices pratiques de la formation sur l'OWASP Top 10.

## Outils principaux

### 1. SonarQube (Analyse statique de code)
- **Accès**: http://localhost:9000 (admin/admin)
- **Usage**: Détection de vulnérabilités dans le code source

### 2. Burp Suite (Tests web)
- **Lancement**: Menu Applications > Web Application Analysis > burpsuite
- **Alternative**: Commande `burpsuite` ou `burpsuite-lab`

### 3. Nessus Expert (Scans de vulnérabilités)
- **Accès**: https://localhost:8834
- **Gestion**: `nessus-start`, `nessus-stop`, `nessus-status`, `nessus-web`
- **Note**: Nécessite une licence commerciale de Tenable

### 4. Ghidra (Analyse binaire)
- **Lancement**: Commande `ghidra`

### 5. MobSF (Sécurité mobile)
- **Accès**: http://localhost:8000

## Applications vulnérables
- WebGoat: http://localhost:8081/WebGoat
- OWASP Juice Shop: http://localhost:3000
- DVWA: http://localhost:8888 (admin/password)
- NodeGoat: http://localhost:4000 (admin/Admin_123 ou user1/User1_123)
  - Tutoriel NodeGoat: http://localhost:4000/tutorial

## Commandes utiles
- `start_services`: Démarrer tous les services Docker
- `stop_services`: Arrêter tous les services Docker
- `status`: Afficher l'état des services Docker
- `guides`: Lister les guides disponibles
- `show-guide [nom]`: Afficher un guide spécifique
- `nodegoat-web`: Ouvrir NodeGoat dans le navigateur
- `nodegoat-tutorial`: Ouvrir le tutoriel NodeGoat dans le navigateur

## Ressources
- Guides détaillés: `/home/vagrant/docs/guides/`
- Exercices: `/home/vagrant/exercises/`
- Applications de test: `/home/vagrant/labs/`

## Avantages de l'utilisation de Kali Linux
- De nombreux outils de sécurité préinstallés
- Environnement conçu pour les tests de pénétration
- Interface graphique optimisée pour la sécurité
EOF

# Message de bienvenue
cat << 'EOF'

╔═══════════════════════════════════════════════════════════════════╗
║                                                                   ║
║   Bienvenue dans l'Environnement de Lab OWASP Top 10 !            ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝

OUTILS PRINCIPAUX DE SÉCURITÉ:
  ▶ SonarQube (Analyse statique):   http://localhost:9000 (admin/admin)
     Usage: Détection des vulnérabilités dans le code source

  ▶ Burp Suite (Tests web):         burpsuite / burpsuite-lab
     Usage: Interception et modification des requêtes HTTP/HTTPS

  ▶ Nessus Expert:               https://localhost:8834
     Usage: Scan complet de vulnérabilités
     Gestion: nessus-start, nessus-stop, nessus-status, nessus-web

  ▶ Ghidra (Analyse binaire):       ghidra
     Usage: Rétro-ingénierie et analyse des implémentations cryptographiques

  ▶ MobSF (Sécurité mobile):        http://localhost:8000
     Usage: Analyse statique et dynamique d'applications mobiles

APPLICATIONS VULNÉRABLES:
  ▶ WebGoat:          http://localhost:8081/WebGoat
  ▶ Juice Shop:       http://localhost:3000
  ▶ DVWA:             http://localhost:8888 (admin/password)
  ▶ NodeGoat:         http://localhost:4000 (admin/Admin_123)
    Tutorial:         http://localhost:4000/tutorial

COMMANDES UTILES:
  ▶ start_services   - Démarrer tous les services
  ▶ stop_services    - Arrêter tous les services
  ▶ status           - Afficher l'état des services
  ▶ guides           - Lister les guides disponibles
  ▶ show-guide [nom] - Afficher un guide spécifique
  ▶ nodegoat-web     - Ouvrir NodeGoat dans le navigateur
  ▶ nodegoat-tutorial - Ouvrir le tutoriel NodeGoat

DOCUMENTATION:
  ▶ Des guides détaillés pour chaque outil sont disponibles dans:
    /home/vagrant/docs/guides/

EOF

echo "Configuration de l'environnement terminée."
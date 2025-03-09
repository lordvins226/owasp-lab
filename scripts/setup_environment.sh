#!/bin/bash

echo "Configuration de l'environnement pour les labs OWASP Top 10 sur Kali Linux..."

# Création des répertoires pour les guides si synchronisés depuis Vagrant
if [ ! -d "/home/vagrant/docs/guides" ]; then
  mkdir -p /home/vagrant/docs/guides
fi

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
alias zap-lab='zaproxy'
alias sonarqube-status='docker ps | grep sonarqube'
alias mobsf-status='docker ps | grep mobsf'

# Raccourcis pour les guides
alias guides='ls -la /home/vagrant/docs/guides'
alias show-guide='function _show_guide() { cat "/home/vagrant/docs/guides/$1" | less; }; _show_guide'

# Raccourcis pour les logs des applications
alias webgoat-logs='docker logs -f webgoat'
alias juiceshop-logs='docker logs -f juice-shop'
alias dvwa-logs='docker logs -f dvwa'
alias mobsf-logs='docker logs -f mobsf'

# Raccourcis pour les scans
alias zap-scan='/home/vagrant/tools/zap/configs/owasp-top10-scan.sh'

# Fonction pour démarrer tous les services
start_all_services() {
  echo "Démarrage de tous les services..."
  cd /home/vagrant/labs/apps
  docker-compose -f docker-compose-webgoat.yml up -d
  docker-compose -f docker-compose-juiceshop.yml up -d
  docker-compose -f docker-compose-dvwa.yml up -d
  docker-compose -f docker-compose-mobsf.yml up -d
  docker-compose -f docker-compose-elk.yml up -d
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
Exec=sh -c "xterm -e 'echo \"Bienvenue dans le Lab OWASP Top 10\" && echo \"\" && echo \"Les outils disponibles sont:\" && echo \" - SonarQube: http://localhost:9000\" && echo \" - Burp Suite: burpsuite\" && echo \" - OWASP ZAP: zaproxy\" && echo \" - Ghidra: ghidra\" && echo \" - MobSF: http://localhost:8000\" && echo \"\" && echo \"Appuyez sur Enter pour fermer cette fenêtre.\" && read'"
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

### 3. OWASP ZAP (Scans de vulnérabilités)
- **Lancement**: Menu Applications > Web Application Analysis > zaproxy
- **Alternative**: Commande `zaproxy` ou `zap-lab`
- **Scan rapide**: `zap-scan [URL] [RAPPORT]`

### 4. Ghidra (Analyse binaire)
- **Lancement**: Commande `ghidra`

### 5. MobSF (Sécurité mobile)
- **Accès**: http://localhost:8000

## Applications vulnérables
- WebGoat: http://localhost:8081/WebGoat
- OWASP Juice Shop: http://localhost:3000
- DVWA: http://localhost:8888 (admin/password)

## Commandes utiles
- `start_services`: Démarrer tous les services Docker
- `stop_services`: Arrêter tous les services Docker
- `status`: Afficher l'état des services Docker
- `guides`: Lister les guides disponibles
- `show-guide [nom]`: Afficher un guide spécifique

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
║   Bienvenue dans l'Environnement de Lab OWASP Top 10 !           ║
║                  Basé sur Kali Linux                             ║
╚═══════════════════════════════════════════════════════════════════╝

OUTILS PRINCIPAUX DE SÉCURITÉ:
  ▶ SonarQube (Analyse statique):   http://localhost:9000 (admin/admin)
     Usage: Détection des vulnérabilités dans le code source

  ▶ Burp Suite (Tests web):         burpsuite / burpsuite-lab
     Usage: Interception et modification des requêtes HTTP/HTTPS

  ▶ OWASP ZAP (Alternative Nessus): zaproxy / zap-lab
     Usage: Scan automatisé d'applications web
     Scan rapide: zap-scan [URL] [RAPPORT]

  ▶ Ghidra (Analyse binaire):       ghidra
     Usage: Rétro-ingénierie et analyse des implémentations cryptographiques

  ▶ MobSF (Sécurité mobile):        http://localhost:8000
     Usage: Analyse statique et dynamique d'applications mobiles

APPLICATIONS VULNÉRABLES:
  ▶ WebGoat:          http://localhost:8081/WebGoat
  ▶ Juice Shop:       http://localhost:3000
  ▶ DVWA:             http://localhost:8888 (admin/password)

COMMANDES UTILES:
  ▶ start_services   - Démarrer tous les services
  ▶ stop_services    - Arrêter tous les services
  ▶ status           - Afficher l'état des services
  ▶ guides           - Lister les guides disponibles
  ▶ show-guide [nom] - Afficher un guide spécifique

DOCUMENTATION:
  ▶ Des guides détaillés pour chaque outil sont disponibles dans:
    /home/vagrant/docs/guides/

EOF

echo "Configuration de l'environnement terminée."
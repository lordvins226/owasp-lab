#!/bin/bash

echo "Configuration de l'environnement pour les labs OWASP Top 10 sur Kali Linux..."

# Création des répertoires pour les guides si synchronisés depuis Vagrant
if [ ! -d "/home/vagrant/docs/guides" ]; then
  mkdir -p /home/vagrant/docs/guides
fi

# Configuration de l'environnement zsh pour l'utilisateur vagrant
cat >> /home/vagrant/.zshrc << 'EOF'

# Configuration pour les labs OWASP Top 10
export LAB_HOME="/home/vagrant"
export TOOLS_DIR="$LAB_HOME/tools"
export LABS_DIR="$LAB_HOME/labs"

# Alias utiles pour les labs OWASP
alias cls='clear'

# Alias pour les outils principaux
alias burpsuite-lab='burpsuite'
alias burpsuite_launcher='$TOOLS_DIR/burpsuite/burpsuite_launcher.sh'
alias ghidra_launcher='$TOOLS_DIR/ghidra/ghidra_launcher.sh'
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
alias mobsf-logs='docker logs -f mobsf_app'
alias nodegoat-logs='docker logs -f nodegoat'

# Ouverture rapide de Nessus dans le navigateur
alias nessus-web='xdg-open https://localhost:8834'

# Ouverture rapide de NodeGoat dans le navigateur
alias nodegoat-web='xdg-open http://localhost:4000'
alias nodegoat-tutorial='xdg-open http://localhost:4000/tutorial'

# Fonction pour démarrer tous les services
function start_all_services() {
  echo "Démarrage de tous les services..."

  # Démarrer Juice Shop
  cd $LABS_DIR/apps
  docker-compose -f docker-compose-juiceshop.yml up -d

  # Démarrer NodeGoat
  cd $LABS_DIR/apps
  docker-compose -f docker-compose-nodegoat.yml up -d

  # Démarrer WebGoat
  docker run -d --name webgoat \
    -p 8081:8080 -p 9090:9090 \
    -e WEBGOAT_HOST=www.webgoat.local \
    -e WEBWOLF_HOST=www.webwolf.local \
    -e TZ=America/New_York \
    webgoat/webgoat

  # Démarrer DVWA
  docker run -d --name dvwa \
    -p 8888:80 \
    kaakaww/dvwa-docker:latest

  # Démarrer SonarQube
  cd $TOOLS_DIR
  docker-compose -f docker-compose-sonarqube.yml up -d

  # Démarrer MobSF
  cd $TOOLS_DIR/mobsf
  docker-compose up -d

  echo "Tous les services démarrés."
}

# Fonction pour arrêter tous les services
function stop_all_services() {
  echo "Arrêt de tous les services..."

  # Arrêter les conteneurs lancés avec docker run
  docker stop webgoat && docker rm webgoat
  docker stop dvwa && docker rm dvwa

  # Arrêter les services lancés avec docker-compose
  cd $LABS_DIR/apps
  docker-compose -f docker-compose-juiceshop.yml down
  docker-compose -f docker-compose-nodegoat.yml down

  cd $TOOLS_DIR
  docker-compose -f docker-compose-sonarqube.yml down

  cd $TOOLS_DIR/mobsf
  docker-compose down

  echo "Tous les services arrêtés."
}

# Fonction pour redémarrer WebGoat
function restart_webgoat() {
  echo "Redémarrage de WebGoat..."
  docker stop webgoat && docker rm webgoat
  docker run -d --name webgoat \
    -p 8081:8080 -p 9090:9090 \
    -e WEBGOAT_HOST=www.webgoat.local \
    -e WEBWOLF_HOST=www.webwolf.local \
    -e TZ=America/New_York \
    webgoat/webgoat
  echo "WebGoat redémarré."
}

# Fonction pour redémarrer DVWA
function restart_dvwa() {
  echo "Redémarrage de DVWA..."
  docker stop dvwa && docker rm dvwa
  docker run -d --name dvwa \
    -p 8888:80 \
    kaakaww/dvwa-docker:latest
  echo "DVWA redémarré."
}

# Fonction pour afficher l'état de tous les services
function status_services() {
  echo "État des services Docker:"
  docker ps
}

# Alias pour les fonctions
alias start_services='start_all_services'
alias stop_services='stop_all_services'
alias status='status_services'
alias restart_webgoat='restart_webgoat'
alias restart_dvwa='restart_dvwa'
EOF

if [ -f /home/vagrant/.zshrc ]; then
    source /home/vagrant/.zshrc
fi

# Créer un lien symbolique pour faciliter l'accès aux exercices
ln -sf /home/vagrant/exercises /home/vagrant/Desktop/OWASP-Exercises

cat > /home/vagrant/README.md << 'EOF'
# Environnement de Lab OWASP Top 10 sur Kali Linux

Cet environnement Vagrant basé sur Kali Linux contient tous les outils et applications nécessaires pour réaliser les exercices pratiques de la formation sur l'OWASP Top 10.

## Outils principaux

### 1. SonarQube (Analyse statique de code)
- **Accès**: http://localhost:9000 (admin/admin)
- **Usage**: Détection de vulnérabilités dans le code source

### 2. Burp Suite (Tests web)
- **Lancement**: Commande `burpsuite` ou `burpsuite_launcher`

### 3. Nessus Expert (Scans de vulnérabilités)
- **Accès**: https://localhost:8834
- **Gestion**: `nessus-start`, `nessus-stop`, `nessus-status`, `nessus-web`
- **Note**: Nécessite une licence commerciale de Tenable

### 4. Ghidra (Analyse binaire)
- **Lancement**: Commande `ghidra` ou `ghidra_launcher`

### 5. MobSF (Sécurité mobile)
- **Accès**: http://localhost:8000

## Applications vulnérables
- WebGoat: http://localhost:8081/WebGoat
- WebWolf: http://localhost:9090/WebWolf
- OWASP Juice Shop: http://localhost:3000
- DVWA: http://localhost:8888 (admin/password)
- NodeGoat: http://localhost:4000 (admin/Admin_123 ou user1/User1_123)
  - Tutoriel NodeGoat: http://localhost:4000/tutorial

## Commandes utiles

### Gestion des services
- `start_services`: Démarrer tous les services Docker
- `stop_services`: Arrêter tous les services Docker
- `status`: Afficher l'état des services Docker
- `restart_webgoat`: Redémarrer uniquement le conteneur WebGoat
- `restart_dvwa`: Redémarrer uniquement le conteneur DVWA

### Lancement des outils
- `burpsuite_launcher`: Lancer Burp Suite
- `ghidra_launcher`: Lancer Ghidra avec Java configuré

### Contrôle de Nessus
- `nessus-start`: Démarrer le service Nessus
- `nessus-stop`: Arrêter le service Nessus
- `nessus-status`: Vérifier le statut du service Nessus
- `nessus-web`: Ouvrir l'interface web de Nessus dans le navigateur

### Vérification des services
- `sonarqube-status`: Vérifier si SonarQube est en cours d'exécution
- `mobsf-status`: Vérifier si MobSF est en cours d'exécution
- `nodegoat-status`: Vérifier si NodeGoat est en cours d'exécution

### Accès aux applications web
- `nodegoat-web`: Ouvrir NodeGoat dans le navigateur (http://localhost:4000)
- `nodegoat-tutorial`: Ouvrir le tutoriel NodeGoat dans le navigateur
- `webgoat-web`: Ouvrir WebGoat dans le navigateur (http://localhost:8081/WebGoat)
- `webwolf-web`: Ouvrir WebWolf dans le navigateur (http://localhost:9090/WebWolf)
- `juiceshop-web`: Ouvrir OWASP Juice Shop dans le navigateur (http://localhost:3000)
- `dvwa-web`: Ouvrir DVWA dans le navigateur (http://localhost:8888)
- `sonarqube-web`: Ouvrir SonarQube dans le navigateur (http://localhost:9000)
- `mobsf-web`: Ouvrir MobSF dans le navigateur (http://localhost:8000)

### Consultation des logs
- `webgoat-logs`: Afficher les logs de WebGoat en temps réel
- `juiceshop-logs`: Afficher les logs de Juice Shop en temps réel
- `dvwa-logs`: Afficher les logs de DVWA en temps réel
- `mobsf-logs`: Afficher les logs de MobSF en temps réel
- `nodegoat-logs`: Afficher les logs de NodeGoat en temps réel

### Documentation
- `guides`: Lister les guides disponibles
- `show-guide [nom]`: Afficher un guide spécifique (ex: `show-guide BurpSuite_Guide.md`)

## Ressources
- Guides détaillés: `/home/vagrant/docs/guides/`
- Exercices: `/home/vagrant/exercises/`
- Applications de test: `/home/vagrant/labs/`
EOF

echo "Configuration de l'environnement terminée."
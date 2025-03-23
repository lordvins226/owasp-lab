# Environnement de Lab pour OWASP Top 10

Ce dépôt contient les fichiers nécessaires pour créer un environnement Vagrant basé sur Kali Linux permettant de
réaliser les exercices pratiques sur l'OWASP Top 10.

## Prérequis

- [VMware Workstation Pro/Player](https://www.vmware.com/products/workstation-pro.html)
  ou [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (un seul à la fois)
- [Vagrant](https://www.vagrantup.com/downloads) (version 2.2.19 ou supérieure)
- Au moins 8 Go de RAM disponible
- Au moins 20 Go d'espace disque libre
- Pour Nessus Expert: une licence commerciale de Tenable (téléchargement séparé)

## Installation

1. Clonez ce dépôt sur votre machine :
   ```bash
   git clone https://github.com/lordvins226/owasp-lab.git
   cd owasp-lab
   ```

2. Pour utiliser VMware (recommandé) :
   ```bash
   vagrant up --provider=vmware_desktop
   ```

   Pour utiliser VirtualBox (alternative) :
   ```bash
   vagrant up --provider=virtualbox
   ```

   Cette commande peut prendre 15 à 30 minutes lors de la première exécution car elle télécharge et installe tous les
   outils et applications nécessaires.

3. Une fois l'installation terminée, vous pouvez vous connecter à la VM :
   ```bash
   vagrant ssh
   ```

4. Pour vérifier que tout fonctionne correctement, exécutez :
   ```bash
   status
   ```
   Cette commande affichera l'état des différents services Docker.

## Outils principaux pour OWASP Top 10

Cette configuration de lab met l'accent sur cinq outils essentiels pour l'analyse des vulnérabilités OWASP Top 10 :

### 1. SonarQube (Analyse statique de code)

- **Description** : Détecte les vulnérabilités dans le code source via l'analyse statique
- **Accès** : http://localhost:9000 (admin/admin)
- **Commande rapide** : `sonarqube-web`
- **Utilisation typique** : Analyse de projets Java, JavaScript, Python pour détecter des injections, problèmes
  cryptographiques, etc.
- **Guide** : `/home/vagrant/docs/guides/SonarQube_Guide.md`

### 2. Burp Suite (Tests de pénétration web)

- **Description** : Outil complet pour l'interception, l'analyse et la manipulation du trafic HTTP/HTTPS
- **Installation** : Lancer le script `burpsuite_launcher`
- **Lancement** : Recherchez "Burp Suite" dans le menu des applications
- **Utilisation typique** : Tests d'injection, analyse des contrôles d'accès, détection de vulnérabilités dans les
  applications web
- **Guide** : `/home/vagrant/docs/guides/BurpSuite_Guide.md`

### 3. Nessus Expert (Scans de vulnérabilités)

- **Accès** : https://localhost:8834
- **Commande rapide** : `nessus-web`
- **Gestion** : `nessus-start`, `nessus-stop`, `nessus-status`
- **Note** : Nécessite une licence commerciale de Tenable
- **Guide** : `/home/vagrant/docs/guides/Nessus_Guide.md`

### 4. Ghidra (Analyse de binaires)

- **Description** : Outil d'ingénierie inverse pour l'analyse des binaires
- **Lancement** : Commande `ghidra`
- **Utilisation typique** : Détection des vulnérabilités dans le code compilé
- **Guide** : `/home/vagrant/docs/guides/Ghidra_Guide.md`

### 5. MobSF (Sécurité mobile)

- **Description** : Framework d'analyse de sécurité pour applications mobiles
- **Accès** : http://localhost:8000
- **Commande rapide** : `mobsf-web`
- **Utilisation typique** : Analyse statique et dynamique d'applications Android/iOS, détection des vulnérabilités OWASP
  Mobile
- **Guide** : `/home/vagrant/docs/guides/MobSF_Guide.md`

## Applications vulnérables pour les tests

- **WebGoat** : http://localhost:8081/WebGoat (`webgoat-web`)
- **WebWolf** : http://localhost:9090/WebWolf (`webwolf-web`)
- **OWASP Juice Shop** : http://localhost:3000 (`juiceshop-web`)
- **DVWA** : http://localhost:8888 (admin/password) (`dvwa-web`)
- **NodeGoat** : http://localhost:4000 (admin/Admin_123) (`nodegoat-web`)
    - Tutoriel NodeGoat : http://localhost:4000/tutorial (`nodegoat-tutorial`)

## Structure des exercices

Les exercices sont organisés selon les 10 catégories de l'OWASP Top 10. Pour chaque catégorie, des exercices pratiques
sont proposés impliquant l'utilisation des différents outils installés.

Le document complet des exercices est disponible dans la VM à l'emplacement :

```
/home/vagrant/exercises/exercices_owasp_top_10.md
```

## Commandes utiles

### Gestion des services

- `start_services` : Démarrer tous les services Docker
- `stop_services` : Arrêter tous les services Docker
- `status` : Afficher l'état des services Docker
- `restart_webgoat` : Redémarrer uniquement le conteneur WebGoat
- `restart_dvwa` : Redémarrer uniquement le conteneur DVWA

### Lancement des outils

- `burpsuite` : Saisir Burp Suite dans la recherche d'applications
- `ghidra` : Lancer Ghidra

### Contrôle de Nessus

- `nessus-start` : Démarrer le service Nessus
- `nessus-stop` : Arrêter le service Nessus
- `nessus-status` : Vérifier le statut du service Nessus
- `nessus-web` : Ouvrir l'interface web de Nessus dans le navigateur

### Vérification des services

- `sonarqube-status` : Vérifier si SonarQube est en cours d'exécution
- `mobsf-status` : Vérifier si MobSF est en cours d'exécution
- `nodegoat-status` : Vérifier si NodeGoat est en cours d'exécution

### Accès aux applications web

- `webgoat-web` : Ouvrir WebGoat dans le navigateur
- `webwolf-web` : Ouvrir WebWolf dans le navigateur
- `juiceshop-web` : Ouvrir OWASP Juice Shop dans le navigateur
- `dvwa-web` : Ouvrir DVWA dans le navigateur
- `nodegoat-web` : Ouvrir NodeGoat dans le navigateur
- `nodegoat-tutorial` : Ouvrir le tutoriel NodeGoat dans le navigateur
- `sonarqube-web` : Ouvrir SonarQube dans le navigateur
- `mobsf-web` : Ouvrir MobSF dans le navigateur

### Consultation des logs

- `webgoat-logs` : Afficher les logs de WebGoat en temps réel
- `juiceshop-logs` : Afficher les logs de Juice Shop en temps réel
- `dvwa-logs` : Afficher les logs de DVWA en temps réel
- `mobsf-logs` : Afficher les logs de MobSF en temps réel
- `nodegoat-logs` : Afficher les logs de NodeGoat en temps réel

### Documentation

- `guides` : Lister les guides disponibles
- `show-guide [nom]` : Afficher un guide spécifique (ex: `show-guide BurpSuite_Guide.md`)

## Installation de Nessus Expert

Nessus Expert étant un outil commercial, son installation nécessite quelques étapes supplémentaires :

1. Téléchargez le package d'installation depuis le site de Tenable : https://www.tenable.com/downloads/nessus
2. Copiez le fichier .deb dans le répertoire `/home/vagrant/tools/nessus/` de la VM
3. Dans la VM, exécutez le script d'activation :
   ```bash
   cd /home/vagrant/tools/nessus
   ./activate_nessus.sh XXXX-XXXX-XXXX-XXXX
   ```
   (Remplacez XXXX-XXXX-XXXX-XXXX par votre code de licence)
4. Accédez à l'interface web via la commande `nessus-web` ou https://localhost:8834

## Arrêt et suppression de l'environnement

- Pour suspendre la VM (économiser de la RAM) :
  ```bash
  vagrant suspend
  ```

- Pour arrêter proprement la VM :
  ```bash
  vagrant halt
  ```

- Pour supprimer complètement la VM :
  ```bash
  vagrant destroy
  ```

## Dépannage

- **Problème** : Les services Docker ne démarrent pas correctement.  
  **Solution** : Exécutez `stop_services` puis `start_services` pour redémarrer tous les services.

- **Problème** : Ports déjà utilisés sur la machine hôte.  
  **Solution** : Modifiez les mappings de ports dans le Vagrantfile et relancez la VM avec `vagrant reload`.

- **Problème** : Performances lentes de la VM.  
  **Solution** : Augmentez les ressources allouées (mémoire, CPU) dans le Vagrantfile.

- **Problème** : Les alias et commandes ne fonctionnent pas.  
  **Solution** : Redémarrez le terminal ou exécutez `source ~/.zshrc` pour charger les configurations.

- **Problème** : Installation de Nessus échoue.  
  **Solution** : Vérifiez que vous avez bien copié le fichier .deb et que vous disposez d'une licence valide.
# Environnement de Lab pour OWASP Top 10

Ce dépôt contient les fichiers nécessaires pour créer un environnement Vagrant basé sur Kali Linux permettant de réaliser les exercices pratiques sur l'OWASP Top 10.

## Prérequis

- [VMware Workstation Pro/Player](https://www.vmware.com/products/workstation-pro.html) ou [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (un seul à la fois)
- [Vagrant](https://www.vagrantup.com/downloads) (version 2.2.19 ou supérieure)
- Au moins 8 Go de RAM disponible
- Au moins 20 Go d'espace disque libre
- Pour Nessus Expert: une licence commerciale de Tenable (téléchargement séparé)

## Installation

1. Clonez ce dépôt sur votre machine :
   ```bash
   git clone https://github.com/votre-organisation/owasp-top10-lab-environment.git
   cd owasp-top10-lab-environment
   ```

2. Pour utiliser VMware (recommandé) :
   ```bash
   vagrant up --provider=vmware_desktop
   ```

   Pour utiliser VirtualBox (alternative) :
   ```bash
   vagrant up --provider=virtualbox
   ```

   Cette commande peut prendre 15 à 30 minutes lors de la première exécution car elle télécharge et installe tous les outils et applications nécessaires.

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
- **Utilisation typique** : Analyse de projets Java, JavaScript, Python pour détecter des injections, problèmes cryptographiques, etc.
- **Guide** : `/home/vagrant/docs/guides/SonarQube_Guide.md`

### 2. Burp Suite (Tests de pénétration web)
- **Description** : Outil complet pour l'interception, l'analyse et la manipulation du trafic HTTP/HTTPS
- **Lancement** : Menu Applications > Web Application Analysis > burpsuite
- **Alternative**: Commande `burpsuite` ou `burpsuite-lab`
- **Utilisation typique** : Tests d'injection, analyse des contrôles d'accès, détection de vulnérabilités dans les applications web
- **Guide** : `/home/vagrant/docs/guides/BurpSuite_Guide.md`

### 3. Nessus Expert (Scans de vulnérabilités)
- **Accès**: https://localhost:8834
- **Gestion**: `nessus-start`, `nessus-stop`, `nessus-status`, `nessus-web`
- **Note**: Nécessite une licence commerciale de Tenable
- **Guide**: `/home/vagrant/docs/guides/Nessus_Guide.md`

### 4. Ghidra (Analyse de binaires)
- **Description** : Outil d'ingénierie inverse pour l'analyse des binaires et la détection des implémentations cryptographiques faibles
- **Lancement** : Menu Applications > Reverse Engineering > ghidra
- **Alternative**: Commande `ghidra`
- **Utilisation typique** : Analyse des implémentations cryptographiques, détection des vulnérabilités dans le code compilé
- **Guide** : `/home/vagrant/docs/guides/Ghidra_Guide.md`

### 5. MobSF (Sécurité mobile)
- **Description** : Framework d'analyse de sécurité pour applications mobiles
- **Accès** : http://localhost:8000
- **Utilisation typique** : Analyse statique et dynamique d'applications Android/iOS, détection des vulnérabilités OWASP Mobile
- **Guide** : `/home/vagrant/docs/guides/MobSF_Guide.md`

## Applications vulnérables pour les tests

- **WebGoat** : http://localhost:8081/WebGoat
- **OWASP Juice Shop** : http://localhost:3000
- **DVWA** : http://localhost:8888 (admin/password)

## Structure des exercices

Les exercices sont organisés selon les 10 catégories de l'OWASP Top 10. Pour chaque catégorie, des exercices pratiques sont proposés impliquant l'utilisation des différents outils installés.

Le document complet des exercices est disponible dans la VM à l'emplacement :
```
/home/vagrant/exercises/exercices_owasp_top_10.md
```

## Commandes utiles

- `start_services` : Démarrer tous les services Docker
- `stop_services` : Arrêter tous les services Docker
- `status` : Afficher l'état des services Docker
- `nessus-web` : Ouvrir l'interface web de Nessus dans le navigateur
- `guides` : Lister les guides disponibles
- `show-guide [nom]` : Afficher un guide spécifique (ex: `show-guide Nessus_Guide.md`)

## Avantages de l'utilisation de Kali Linux

- Nombreux outils de sécurité préinstallés
- Environnement optimisé pour les tests de pénétration
- Interface graphique adaptée à la sécurité
- Compatibilité avec les outils professionnels

## Installation de Nessus Expert

Nessus Expert étant un outil commercial, son installation nécessite quelques étapes supplémentaires :

1. Téléchargez le package d'installation depuis le site de Tenable : https://www.tenable.com/downloads/nessus
2. Copiez le fichier .deb dans le répertoire `/home/vagrant/tools/nessus/` de la VM
3. Dans la VM, exécutez le script d'installation :
   ```bash
   cd /home/vagrant/tools/nessus
   ./install_nessus.sh
   ```
4. Suivez les instructions à l'écran pour terminer l'installation
5. Accédez à l'interface web via https://localhost:8834 et activez votre licence

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

- **Problème** : Installation de Nessus échoue.
  **Solution** : Vérifiez que vous avez bien copié le fichier .deb et que vous disposez d'une licence valide.

# Environnement de Lab pour OWASP Top 10

Ce dépôt contient les fichiers nécessaires pour créer un environnement Vagrant permettant de réaliser les exercices pratiques basés sur l'OWASP Top 10.

## Prérequis

- [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (version 6.1 ou supérieure)
- [Vagrant](https://www.vagrantup.com/downloads) (version 2.2.19 ou supérieure)
- Au moins 8 Go de RAM disponible
- Au moins 20 Go d'espace disque libre

## Installation

1. Clonez ce dépôt sur votre machine :
   ```bash
   git clone https://github.com/votre-organisation/owasp-top10-lab-environment.git
   cd owasp-top10-lab-environment
   ```

2. Démarrez l'environnement Vagrant :
   ```bash
   vagrant up
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
- **Lancement** : `burp` ou `run-burp`
- **Utilisation typique** : Tests d'injection, analyse des contrôles d'accès, détection de vulnérabilités dans les applications web
- **Guide** : `/home/vagrant/docs/guides/BurpSuite_Guide.md`

### 3. OWASP ZAP (Alternative à Nessus)
- **Description** : Proxy d'interception et scanner de vulnérabilités pour les applications web
- **Lancement** : `zap` ou `/usr/local/bin/zap`
- **Scan rapide** : `zap-scan [URL] [RAPPORT]`
- **Guide** : `/home/vagrant/docs/guides/ZAP_Guide.md`

### 4. Ghidra (Analyse de binaires)
- **Description** : Outil d'ingénierie inverse pour l'analyse des binaires et la détection des implémentations cryptographiques faibles
- **Lancement** : `ghidra`
- **Utilisation typique** : Analyse des implémentations cryptographiques, détection des vulnérabilités dans le code compilé
- **Guide** : `/home/vagrant/docs/guides/Ghidra_Guide.md`

### 5. MobSF (Sécurité mobile)
- **Description** : Framework d'analyse de sécurité pour applications mobiles
- **Accès** : http://localhost:8000
- **Utilisation typique** : Analyse statique et dynamique d'applications Android/iOS, détection des vulnérabilités OWASP Mobile
- **Guide** : `/home/vagrant/docs/guides/MobSF_Guide.md`

### Applications vulnérables pour les tests

- **WebGoat** : http://localhost:8081/WebGoat
- **OWASP Juice Shop** : http://localhost:3000

## Structure des exercices

Les exercices sont organisés selon les 10 catégories de l'OWASP Top 10. Pour chaque catégorie, des exercices pratiques sont proposés impliquant l'utilisation des différents outils installés.

Le document complet des exercices est disponible dans la VM à l'emplacement :
```
/home/vagrant/exercices_owasp_top_10.md
```

## Commandes utiles

- `start_services` : Démarrer tous les services
- `stop_services` : Arrêter tous les services
- `status` : Afficher l'état des services Docker

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

## Notes importantes

- Certains outils comme Burp Suite fonctionnent mieux lorsqu'ils sont installés sur la machine hôte. Le fichier JAR est téléchargé dans la VM mais vous pouvez le copier sur votre machine hôte pour une meilleure expérience.
- Pour les exercices impliquant des binaires (Ghidra), assurez-vous d'être connecté à la VM via SSH avec l'option de transfert X11 si vous souhaitez utiliser l'interface graphique :
  ```bash
  vagrant ssh -- -X
  ```

## Dépannage

- **Problème** : Les services Docker ne démarrent pas correctement.
  **Solution** : Exécutez `stop_services` puis `start_services` pour redémarrer tous les services.

- **Problème** : Ports déjà utilisés sur la machine hôte.
  **Solution** : Modifiez les mappings de ports dans le Vagrantfile et relancez la VM avec `vagrant reload`.

- **Problème** : Performances lentes de la VM.
  **Solution** : Augmentez les ressources allouées (mémoire, CPU) dans le Vagrantfile.

## Contribution

N'hésitez pas à contribuer à ce projet en soumettant des pull requests pour améliorer les scripts, ajouter de nouveaux exercices ou corriger des bugs.

## Licence

Ce projet est distribué sous licence MIT. Voir le fichier LICENSE pour plus de détails.
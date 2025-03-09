# Guide Pratique : Nessus Expert

## Introduction
Nessus Expert est un scanner de vulnérabilités professionnel développé par Tenable qui permet d'identifier les failles de sécurité dans les systèmes et applications. Il est particulièrement efficace pour détecter les vulnérabilités de l'OWASP Top 10.

## Installation
Nessus Expert est un logiciel commercial qui nécessite une licence.

1. Si Nessus n'est pas encore installé, exécutez le script d'installation :
   ```bash
   cd /home/vagrant/tools/nessus
   ./install_nessus.sh
   ```

2. Après l'installation, accédez à l'interface web :
   ```
   https://localhost:8834
   ```

3. Suivez les instructions pour :
   - Créer un compte administrateur
   - Enregistrer votre licence Nessus Expert
   - Attendre la fin du téléchargement des plugins

## Gestion du service Nessus
- Démarrer Nessus : `nessus-start` ou `sudo systemctl start nessusd`
- Arrêter Nessus : `nessus-stop` ou `sudo systemctl stop nessusd`
- Vérifier l'état : `nessus-status` ou `sudo systemctl status nessusd`
- Ouvrir l'interface web : `nessus-web` ou dans votre navigateur: https://localhost:8834

## Types de scans pertinents pour OWASP Top 10

### 1. Web Application Tests
Ce type de scan est idéal pour détecter les vulnérabilités web de l'OWASP Top 10.

**Configuration :**
1. Nouvelle analyse > Web Application Tests
2. Configurer les options de base :
   - Nom : "Scan OWASP Application Web"
   - Description : "Détection des vulnérabilités OWASP Top 10"
   - Folder : Dossier de destination (ex: "OWASP Scans")
   - Targets : URL de l'application cible (ex: http://localhost:3000 pour Juice Shop)

3. Configurer les options avancées :
   - Assessment > Scan Type : Utiliser "Scan for all web vulnerabilities"
   - Discovery > Scan webpages : Activer
   - Discovery > Maximum pages to crawl : Définir selon l'application
   - Authentication : Configurer si besoin de s'authentifier

### 2. Credentialed Patch Audit
Ce scan est utile pour détecter les vulnérabilités de composants (A06 dans l'OWASP Top 10).

**Configuration :**
1. Nouvelle analyse > Credentialed Patch Audit
2. Configurer les cibles et le nom
3. Credentials > Add : Ajouter les informations d'authentification selon le système

### 3. Policy Personnalisée pour OWASP Top 10
Pour une analyse plus ciblée, vous pouvez créer une politique personnalisée :

1. Policies > Add
2. Choisir "Advanced Scan"
3. Dans l'éditeur de politique :
   - Web Applications > Navigation et découverte : Activer
   - Web Applications > Ajouter des groupes de plugins spécifiques à l'OWASP Top 10 :
     - A01 - Broken Access Control
     - A02 - Cryptographic Failures
     - A03 - Injection
     - A04 - Insecure Design
     - A05 - Security Misconfiguration
     - A06 - Vulnerable and Outdated Components
     - A07 - Identification and Authentication Failures
     - A08 - Software and Data Integrity Failures
     - A09 - Security Logging and Monitoring Failures
     - A10 - Server-Side Request Forgery

## Exécution et analyse des résultats

### Lancement d'un scan
1. Sélectionner le scan configuré
2. Cliquer sur "Launch"
3. Suivre la progression dans l'onglet "Scans"

### Interprétation des résultats
1. Une fois le scan terminé, cliquer sur son nom
2. Observer le dashboard résumant les vulnérabilités
3. Filtrer par sévérité :
   - Critical : Attention immédiate requise
   - High : Correction prioritaire
   - Medium : Planifier la correction
   - Low/Info : À considérer lors d'une révision complète

4. Pour chaque vulnérabilité :
   - Description : Comprendre le problème
   - Output : Voir les détails techniques de la détection
   - Solution : Lire les recommandations de correction
   - References : Consulter les ressources externes

### Relation avec l'OWASP Top 10
Nessus catégorise automatiquement les vulnérabilités. Pour identifier celles liées à l'OWASP Top 10 :

1. Dans la vue des résultats, utilisez le filtre par plugin
2. Recherchez les vulnérabilités par catégorie OWASP :
   - SQL Injection (A03)
   - Cross-Site Scripting (A03)
   - Outdated Software (A06)
   - Authentication Issues (A07)
   - Etc.

### Génération de rapports
1. Dans la vue des résultats du scan, cliquer sur "Export"
2. Choisir le format adapté :
   - PDF : Pour présentation aux décideurs
   - CSV : Pour analyse et traitement des données
   - Nessus : Pour partage entre analystes

## Exercice pratique
1. Configurer un scan Web Application sur OWASP Juice Shop (http://localhost:3000)
2. Exécuter le scan et analyser les résultats
3. Identifier au moins 5 vulnérabilités OWASP Top 10 détectées
4. Générer un rapport PDF résumant les découvertes
5. Proposer des mesures correctives pour les vulnérabilités critiques et élevées

## Conseils d'utilisation
- Commencez par des scans limités avant d'augmenter leur portée
- Utilisez les options d'authentification pour des analyses plus approfondies
- Consultez les ressources Tenable pour comprendre les plugins Nessus
- Gardez Nessus à jour pour bénéficier des dernières signatures de vulnérabilités
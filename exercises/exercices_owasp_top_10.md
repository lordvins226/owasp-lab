# Exercices pratiques OWASP Top 10

Ce document contient des exercices pratiques pour comprendre et pratiquer la détection et la correction des vulnérabilités de l'OWASP Top 10 (2021) en utilisant les outils installés dans l'environnement de laboratoire Kali Linux.

## Prérequis

Assurez-vous que tous les services sont démarrés avant de commencer les exercices :

```bash
start_services
```

Vérifiez que tous les services fonctionnent correctement :

```bash
status
```

## Applications vulnérables disponibles

Pour ces exercices, nous utiliserons plusieurs applications vulnérables déjà configurées dans l'environnement :

- **WebGoat** : http://localhost:8081/WebGoat - Application Java vulnérable avec des leçons interactives
- **OWASP Juice Shop** : http://localhost:3000 - Boutique en ligne moderne vulnérable
- **DVWA** : http://localhost:8888 (admin/password) - Application PHP vulnérable classique
- **NodeGoat** : http://localhost:4000 (admin/Admin_123 ou user1/User1_123) - Application Node.js vulnérable

## Outils disponibles

Les exercices utilisent cinq outils principaux installés dans l'environnement :

1. **SonarQube** (Analyse statique de code) : http://localhost:9000 (admin/admin)
2. **Burp Suite** (Tests de pénétration web) : `burpsuite` ou `burpsuite-lab`
3. **Nessus Expert** (Scanner de vulnérabilités) : https://localhost:8834
4. **Ghidra** (Analyse de binaires) : `ghidra`
5. **MobSF** (Sécurité mobile) : http://localhost:8000

## Structure des exercices

Chaque section présente :
1. Une brève description de la vulnérabilité
2. Des exercices pratiques avec des niveaux de difficulté progressive
3. Des indications sur les outils à utiliser
4. Des conseils pour la remédiation

---

## A01 - Broken Access Control

> Les contrôles d'accès défaillants permettent aux utilisateurs d'accéder à des fonctionnalités ou données auxquelles ils ne devraient pas avoir accès.

### Exercice 1.1 : Analyse statique de code avec SonarQube

**Objectif** : Identifier les problèmes de contrôle d'accès dans une application Java.

**Difficulté** : Facile

**Outils** : SonarQube

**Instructions** :
1. Accédez à SonarQube : http://localhost:9000 (admin/admin)
2. Créez un nouveau projet "owasp-benchmark"
3. Générez un token d'analyse (Administration > Security > Users > Tokens)
4. Configurez un profil de qualité OWASP Top 10 (optionnel mais recommandé) :
   - Administration > Quality Profiles
   - Create > Java
   - Nom: "OWASP Top 10"
   - Hériter de "Sonar way"
   - Activez les règles pertinentes pour le contrôle d'accès en filtrant avec les tags "access-control", "auth", "authorization"
5. Lancez l'analyse sur le projet Benchmark :
   ```bash
   cd /home/vagrant/labs/java-app/benchmark
   mvn clean verify sonar:sonar \
     -Dsonar.projectKey=owasp-benchmark \
     -Dsonar.host.url=http://localhost:9000 \
     -Dsonar.login=votre_token
   ```
6. Dans SonarQube, filtrez les résultats par le tag "access-control"
7. Identifiez au moins 3 problèmes de contrôle d'accès
8. Pour chaque problème, notez :
   - La gravité (critical, major, minor)
   - La description du problème
   - La recommandation de SonarQube pour corriger le problème

> **Note**: Pour une configuration plus rapide du profil OWASP, vous pouvez utiliser le script de configuration fourni:
> ```bash
> cd /home/vagrant/tools/sonarqube-config
> ./setup-owasp-profile.sh
> ```

### Exercice 1.2 : Test d'accès horizontal avec Burp Suite

**Objectif** : Exploiter une faille de contrôle d'accès horizontal dans DVWA.

**Difficulté** : Moyenne

**Outils** : Burp Suite, Firefox

**Instructions** :
1. Lancez Burp Suite : `burpsuite` ou via le menu Applications
2. Configurez Firefox pour utiliser le proxy Burp Suite (localhost:8080)
3. Accédez à DVWA : http://localhost:8888 (admin/password)
4. Réglez le niveau de sécurité sur "Low" (DVWA Security)
5. Accédez à la section "DVWA Security" et connectez-vous
6. Activez l'interception dans Burp Suite (Proxy > Intercept > "Intercept is on")
7. Accédez à votre profil utilisateur dans DVWA
8. Dans Burp Suite, identifiez et modifiez les identifiants d'utilisateur dans les requêtes
9. Observez si vous pouvez accéder aux profils d'autres utilisateurs
10. Documentez la vulnérabilité et comment l'exploiter

### Exercice 1.3 : Test d'accès vertical avec NodeGoat

**Objectif** : Exploiter une faille de contrôle d'accès vertical dans NodeGoat.

**Difficulté** : Difficile

**Outils** : Burp Suite, Firefox, NodeGoat

**Instructions** :
1. Accédez à NodeGoat : http://localhost:4000
   > **Note**: Vous pouvez également utiliser l'alias `nodegoat-web` pour ouvrir NodeGoat dans votre navigateur.
2. Créez un nouveau compte utilisateur ou utilisez user1/User1_123
3. Explorez les fonctionnalités disponibles pour un utilisateur standard
4. Avec Burp Suite, interceptez les requêtes vers les pages d'administration
5. Identifiez les mécanismes de contrôle d'accès utilisés (cookies, jetons JWT)
6. Essayez de modifier les jetons ou paramètres pour accéder aux fonctionnalités d'administration
7. Consultez le tutoriel NodeGoat pour comprendre les vulnérabilités : http://localhost:4000/tutorial

### Conseils de remédiation pour les contrôles d'accès
- Implémenter un modèle de contrôle d'accès cohérent avec des refus par défaut
- Vérifier les autorisations côté serveur pour chaque accès à une fonctionnalité ou ressource
- Désactiver le listage des répertoires et limiter les métadonnées exposées
- Utiliser des identifiants de session imprévisibles et invalidés lors de la déconnexion

---

## A02 - Cryptographic Failures

> Les défaillances cryptographiques exposent des données sensibles qui devraient être protégées.

### Exercice 2.1 : Analyse de communication non sécurisée avec Burp Suite

**Objectif** : Identifier les données sensibles transmises en clair.

**Difficulté** : Facile

**Outils** : Burp Suite, Firefox

**Instructions** :
1. Configurez Burp Suite comme proxy pour Firefox
2. Accédez à DVWA : http://localhost:8888 (admin/password)
3. Naviguez vers la page de connexion et interceptez la requête d'authentification
4. Examinez comment les identifiants sont transmis
5. Vérifiez les en-têtes HTTP pour les cookies et autres informations sensibles
6. Identifiez si les données sont transmises en clair ou chiffrées
7. Documentez les faiblesses cryptographiques trouvées

### Exercice 2.2 : Analyse binaire avec Ghidra

**Objectif** : Identifier les implémentations cryptographiques faibles dans un binaire.

**Difficulté** : Moyenne

**Outils** : Ghidra

**Instructions** :
1. Lancez Ghidra via la commande : `ghidra`
   - Si vous rencontrez des problèmes avec Java, utilisez le script de lancement personnalisé :
   ```bash
   cd /home/vagrant/tools/ghidra
   ./ghidra_launcher.sh
   ```
2. Créez un nouveau projet nommé "CryptoAnalysis"
3. Importez le binaire : /home/vagrant/labs/binaries/lab1A
4. Analysez le binaire avec les options par défaut
5. Recherchez des chaînes liées à la cryptographie :
   - Allez dans Search > For Strings
   - Cherchez des termes comme "password", "encrypt", "decrypt", "key", "hash"
6. Examinez les fonctions utilisant ces chaînes
7. Identifiez les algorithmes cryptographiques utilisés (MD5, DES, AES, etc.)
8. Déterminez si des clés ou mots de passe sont codés en dur
9. Évaluez la force des implémentations cryptographiques

### Exercice 2.3 : Analyse de vulnérabilités SSL/TLS avec Nessus

**Objectif** : Détecter les configurations SSL/TLS faibles.

**Difficulté** : Moyenne

**Outils** : Nessus Expert

**Instructions** :
1. Accédez à Nessus : https://localhost:8834
   - Note: Si c'est votre première utilisation, vous devrez activer votre licence en utilisant le script:
   ```bash
   cd /home/vagrant/tools/nessus
   ./activate_nessus.sh VOTRE-CODE-DE-LICENCE
   ```
2. Créez un nouveau scan de type "Basic Network Scan"
3. Configurez le scan pour cibler localhost et les ports des applications (3000, 8080, 8081, 8888)
4. Dans les paramètres avancés, activez les plugins liés à SSL/TLS
5. Lancez le scan et analysez les résultats
6. Identifiez les problèmes de configuration SSL/TLS :
   - Protocoles obsolètes (SSLv3, TLS 1.0)
   - Suites de chiffrement faibles
   - Certificats auto-signés ou expirés
7. Documentez les vulnérabilités et leur impact

### Conseils de remédiation pour les défaillances cryptographiques
- Chiffrer toutes les données sensibles au repos et en transit
- Utiliser des algorithmes cryptographiques forts et à jour (AES-256, RSA 2048+)
- Stocker les mots de passe avec des algorithmes de hachage spécialement conçus (Argon2, bcrypt)
- Désactiver les protocoles cryptographiques obsolètes (SSL, TLS 1.0/1.1)
- Ne pas coder en dur les clés cryptographiques dans le code

---

## A03 - Injection

> Les vulnérabilités d'injection permettent d'insérer du code malveillant qui est ensuite exécuté par l'interpréteur.

### Exercice 3.1 : Détection d'injection SQL avec SonarQube

**Objectif** : Identifier les vulnérabilités d'injection SQL dans le code source.

**Difficulté** : Facile

**Outils** : SonarQube

**Instructions** :
1. Accédez à SonarQube : http://localhost:9000
2. Ouvrez le projet "owasp-benchmark" (créé précédemment)
3. Filtrez les vulnérabilités avec le tag "sql-injection"
4. Examinez le code vulnérable
5. Identifiez les raisons pour lesquelles le code est vulnérable
6. Notez les recommandations de SonarQube pour corriger ces vulnérabilités

### Exercice 3.2 : Test d'injection SQL avec Burp Suite

**Objectif** : Exploiter une vulnérabilité d'injection SQL dans DVWA.

**Difficulté** : Moyenne

**Outils** : Burp Suite, Firefox

**Instructions** :
1. Lancez Burp Suite et configurez Firefox pour utiliser le proxy
2. Accédez à DVWA : http://localhost:8888
3. Naviguez vers la section "SQL Injection" de DVWA
4. Entrez une valeur simple (ex: 1) et observez la réponse
5. Interceptez la requête avec Burp Suite
6. Modifiez le paramètre pour tester l'injection SQL :
   - `1' OR '1'='1`
   - `1' UNION SELECT 1,user(),database(),version(),5 -- -`
7. Observez les résultats et documentez les informations obtenues
8. Utilisez Burp Suite Intruder pour automatiser les tests d'injection SQL

### Exercice 3.3 : Test d'injection NoSQL avec NodeGoat

**Objectif** : Exploiter une vulnérabilité d'injection NoSQL dans NodeGoat.

**Difficulté** : Difficile

**Outils** : Burp Suite, Firefox, NodeGoat

**Instructions** :
1. Accédez à NodeGoat : http://localhost:4000
   > **Note**: Vous pouvez également utiliser l'alias `nodegoat-web` pour ouvrir NodeGoat dans votre navigateur.
2. Connectez-vous avec user1/User1_123
3. Naviguez vers le profil utilisateur ou la fonction de recherche
4. Interceptez la requête avec Burp Suite
5. Modifiez les paramètres pour tester l'injection NoSQL :
   - Remplacez une valeur de chaîne par un objet : `{"$ne": null}`
   - Utilisez des opérateurs MongoDB : `{"$gt": ""}`
6. Observez les résultats et documentez les informations obtenues
7. Consultez le tutoriel NodeGoat pour comprendre l'injection NoSQL :
   ```
   http://localhost:4000/tutorial/a3
   ```
   > **Raccourci**: Utilisez l'alias `nodegoat-tutorial` pour accéder directement au tutoriel.

NodeGoat est spécifiquement conçu pour démontrer les vulnérabilités OWASP Top 10 dans un contexte Node.js. Explorez également les autres sections du tutoriel pour approfondir votre compréhension des différentes vulnérabilités.

### Exercice 3.4 : Test d'injection XSS avec Juice Shop

**Objectif** : Exploiter une vulnérabilité XSS dans OWASP Juice Shop.

**Difficulté** : Moyenne

**Outils** : Burp Suite, Firefox

**Instructions** :
1. Accédez à Juice Shop : http://localhost:3000
2. Créez un compte et connectez-vous
3. Identifiez les points d'entrée utilisateur (formulaires de recherche, champs de commentaire)
4. Testez différentes charges utiles XSS :
   - `<script>alert('XSS')</script>`
   - `<img src="x" onerror="alert('XSS')">`
5. Utilisez Burp Suite pour contourner les validations côté client
6. Documentez les vulnérabilités XSS trouvées (réfléchies vs stockées)

### Conseils de remédiation pour les injections
- Utiliser des requêtes paramétrées pour les bases de données
- Valider et assainir toutes les entrées utilisateur
- Échapper les caractères spéciaux selon le contexte
- Appliquer le principe du moindre privilège pour les accès aux bases de données
- Mettre en œuvre des mécanismes CSP (Content Security Policy) pour limiter l'impact du XSS

---

## A04 - Insecure Design

> Une conception non sécurisée fait référence aux vulnérabilités présentes dans la conception même de l'application.

### Exercice 4.1 : Analyse d'architecture avec SonarQube

**Objectif** : Identifier les problèmes de conception dans le code source.

**Difficulté** : Moyenne

**Outils** : SonarQube

**Instructions** :
1. Accédez à SonarQube : http://localhost:9000
2. Ouvrez le projet "owasp-benchmark"
3. Explorez la section "Architecture and Design" de SonarQube
4. Identifiez les problèmes liés à la conception :
   - Couplage excessif
   - Manque de modularité
   - Gestion inadéquate des exceptions
5. Documentez les problèmes identifiés et leurs impacts potentiels

### Exercice 4.2 : Analyse des flux d'affaires avec NodeGoat

**Objectif** : Identifier et exploiter des défauts de conception dans les flux d'affaires.

**Difficulté** : Difficile

**Outils** : Burp Suite, Firefox, NodeGoat

**Instructions** :
1. Accédez à NodeGoat : http://localhost:4000
2. Connectez-vous avec user1/User1_123
3. Explorez l'application pour identifier les processus multi-étapes
4. Cartographiez le flux d'affaires à l'aide de Burp Suite (Site map)
5. Testez la possibilité de contourner des étapes du processus en :
   - Accédant directement à des URL ultérieures du flux
   - Modifiant l'ordre des opérations
   - Manipulant l'état entre les étapes
6. Documentez les failles de conception du flux d'affaires

### Conseils de remédiation pour une conception sécurisée
- Implémenter une modélisation des menaces dès la phase de conception
- Utiliser des maquettes et des user stories incluant des cas d'abus
- Établir des limites de ressources et des quotas pour prévenir les abus
- Mettre en place une segmentation efficace pour limiter l'impact des compromissions
- Documenter et tester les hypothèses de sécurité de conception

---

## A05 - Security Misconfiguration

> Les erreurs de configuration de sécurité sont parmi les vulnérabilités les plus courantes.

### Exercice 5.1 : Scan de configuration avec Nessus

**Objectif** : Identifier les erreurs de configuration de sécurité.

**Difficulté** : Facile

**Outils** : Nessus Expert

**Instructions** :
1. Accédez à Nessus : https://localhost:8834
2. Créez un nouveau scan de type "Basic Network Scan"
3. Configurez le scan pour cibler localhost et les ports des applications
4. Lancez le scan et analysez les résultats
5. Concentrez-vous sur les problèmes de configuration :
   - Services non nécessaires actifs
   - Comptes par défaut
   - Fichiers de configuration exposés
   - En-têtes HTTP de sécurité manquants
6. Documentez les vulnérabilités identifiées et leur impact

### Exercice 5.2 : Analyse des en-têtes de sécurité avec Burp Suite

**Objectif** : Évaluer les en-têtes de sécurité HTTP manquants.

**Difficulté** : Moyenne

**Outils** : Burp Suite, Firefox

**Instructions** :
1. Configurez Burp Suite comme proxy pour Firefox
2. Visitez chacune des applications vulnérables :
   - WebGoat : http://localhost:8081/WebGoat
   - Juice Shop : http://localhost:3000
   - DVWA : http://localhost:8888
   - NodeGoat : http://localhost:4000
3. Pour chaque application, analysez les en-têtes de réponse HTTP avec Burp Suite
4. Vérifiez la présence des en-têtes de sécurité suivants :
   - Content-Security-Policy
   - X-Frame-Options
   - X-Content-Type-Options
   - Strict-Transport-Security
   - X-XSS-Protection
5. Documentez les en-têtes manquants pour chaque application
6. Évaluez l'impact de ces omissions sur la sécurité

### Exercice 5.3 : Découverte de fichiers sensibles

**Objectif** : Découvrir des fichiers sensibles exposés par erreur de configuration.

**Difficulté** : Moyenne

**Outils** : Burp Suite (Intruder ou Content Discovery)

**Instructions** :
1. Configurez Burp Suite comme proxy pour Firefox
2. Pour chaque application, utilisez la fonctionnalité "Site Map"
3. Pour Juice Shop ou DVWA, utilisez Content Discovery pour trouver des fichiers cachés :
   - Clic droit sur le domaine > Engagement tools > Content discovery
4. Recherchez spécifiquement :
   - Fichiers de sauvegarde (.bak, .old)
   - Fichiers de configuration (.conf, .config, .json)
   - Fichiers de développement (.git, .env)
   - Documentation technique
5. Documentez tous les fichiers sensibles trouvés et leur impact sur la sécurité

### Conseils de remédiation pour les erreurs de configuration
- Mettre en place un processus de durcissement pour tous les environnements
- Supprimer les fonctionnalités, composants et comptes par défaut inutiles
- Maintenir un inventaire à jour des composants et configurations
- Mettre en œuvre tous les en-têtes de sécurité HTTP appropriés
- Automatiser la vérification des configurations via des scripts et des tests

---

## A06 - Vulnerable and Outdated Components

> L'utilisation de composants vulnérables ou obsolètes peut compromettre l'ensemble de l'application.

### Exercice 6.1 : Analyse de dépendances avec SonarQube

**Objectif** : Identifier les composants vulnérables dans une application.

**Difficulté** : Facile

**Outils** : SonarQube

**Instructions** :
1. Accédez à SonarQube : http://localhost:9000
2. Ouvrez le projet "owasp-benchmark"
3. Naviguez vers la section "Vulnerabilities"
4. Filtrez par type de vulnérabilité liée aux dépendances
5. Pour chaque composant vulnérable identifié, notez :
   - La version utilisée
   - Les CVE associés
   - La gravité des vulnérabilités
   - Les versions corrigées recommandées

### Exercice 6.2 : Scan de composants vulnérables avec Nessus

**Objectif** : Détecter les composants vulnérables dans un environnement déployé.

**Difficulté** : Moyenne

**Outils** : Nessus Expert

**Instructions** :
1. Accédez à Nessus : https://localhost:8834
2. Créez un nouveau scan de type "Advanced Scan"
3. Configurez le scan pour cibler localhost et les ports des applications
4. Dans les paramètres avancés, activez les plugins liés aux "Web Applications"
5. Lancez le scan et analysez les résultats
6. Identifiez les composants obsolètes ou vulnérables :
   - Serveurs web (Apache, Nginx)
   - Frameworks d'application (Node.js, Express, Spring)
   - Bibliothèques JavaScript (jQuery, Bootstrap)
7. Pour chaque vulnérabilité, documentez :
   - Le composant affecté
   - La version actuelle
   - Les CVE associés
   - Les recommandations de mise à jour

### Exercice 6.3 : Analyse d'applications mobiles avec MobSF

**Objectif** : Identifier les bibliothèques vulnérables dans une application mobile.

**Difficulté** : Moyenne

**Outils** : MobSF

**Instructions** :
1. Accédez à MobSF : http://localhost:8000
2. Sur la page d'accueil, cliquez sur "Upload & Analyze" pour téléverser une application Android
3. Sélectionnez le fichier suivant :
   ```
   /home/vagrant/labs/mobile/UnCrackable-Level1.apk
   ```
   > Note : Vous pouvez également utiliser cette commande pour y accéder facilement :
   > ```bash
   > cd /home/vagrant/labs/mobile/
   > ls -la  # Pour voir les fichiers disponibles
   > ```
4. Après l'analyse, examinez les sections suivantes :
   - "Libraries" : Bibliothèques tierces utilisées
   - "Android API" : APIs Android utilisées
   - "Manifest Analysis" : Configuration de l'application
5. Identifiez les bibliothèques obsolètes ou vulnérables
6. Documentez les problèmes trouvés et leur impact

> **Remarque sur la configuration MobSF** : Si vous rencontrez des problèmes avec MobSF, vous pouvez vérifier son état et le redémarrer :
> ```bash
> mobsf-status    # Pour vérifier l'état
> cd /home/vagrant/tools/mobsf
> ./mobsf-stop.sh && ./mobsf-start.sh  # Pour redémarrer
> ```

### Conseils de remédiation pour les composants vulnérables
- Maintenir un inventaire des composants et de leurs versions
- Mettre en place une surveillance continue des CVE pour les composants utilisés
- Planifier régulièrement des mises à jour de sécurité
- Supprimer les dépendances non utilisées
- Mettre en œuvre une politique de fin de vie pour les composants obsolètes

---

## A07 - Identification and Authentication Failures

> Les défaillances d'authentification peuvent permettre à un attaquant de compromettre les mots de passe, clés ou jetons d'authentification.

### Exercice 7.1 : Test d'authentification avec Burp Suite

**Objectif** : Identifier et exploiter les faiblesses d'authentification.

**Difficulté** : Moyenne

**Outils** : Burp Suite, Firefox

**Instructions** :
1. Configurez Burp Suite comme proxy pour Firefox
2. Accédez à DVWA : http://localhost:8888 (admin/password)
3. Naviguez vers la page de connexion
4. Utilisez Burp Suite Intruder pour tester la robustesse de l'authentification :
   - Testez la force brute avec une liste de mots de passe courants
   - Vérifiez s'il existe des mécanismes de verrouillage de compte
   - Testez si l'application accepte des mots de passe faibles
5. Analysez la gestion des sessions :
   - Examinez les cookies de session (durée, attributs)
   - Vérifiez si les sessions expirent après déconnexion
   - Testez si plusieurs sessions simultanées sont possibles
6. Documentez les vulnérabilités trouvées

### Exercice 7.2 : Analyse d'authentification mobile avec MobSF

**Objectif** : Évaluer les mécanismes d'authentification dans une application mobile.

**Difficulté** : Difficile

**Outils** : MobSF

**Instructions** :
1. Accédez à MobSF : http://localhost:8000
2. Analysez l'application UnCrackable-Level1.apk
3. Examinez les résultats liés à l'authentification :
   - Stockage des informations d'authentification
   - Gestion des sessions
   - Implémentation du stockage sécurisé (Keystore)
4. Dans l'analyse du code, recherchez :
   - Identifiants codés en dur
   - Implémentations d'authentification personnalisées
   - Stockage non sécurisé des mots de passe
5. Si possible, configurez l'analyse dynamique pour observer le comportement d'authentification
6. Documentez les vulnérabilités identifiées

### Exercice 7.3 : Test d'authentification multifacteur avec NodeGoat

**Objectif** : Évaluer la mise en œuvre de l'authentification multifacteur.

**Difficulté** : Difficile

**Outils** : Burp Suite, Firefox, NodeGoat

**Instructions** :
1. Accédez à NodeGoat : http://localhost:4000
2. Explorez les options d'authentification disponibles
3. Vérifiez si l'authentification multifacteur est disponible ou implémentée
4. Avec Burp Suite, analysez le flux d'authentification et identifiez les faiblesses
5. Testez les fonctionnalités de récupération de mot de passe
6. Évaluez la complexité requise pour les mots de passe
7. Consultez le tutoriel NodeGoat sur l'authentification : http://localhost:4000/tutorial/a7

### Conseils de remédiation pour les défaillances d'authentification
- Mettre en œuvre l'authentification multifacteur pour prévenir l'automatisation des attaques
- Appliquer une politique de mots de passe robuste
- Limiter ou retarder progressivement les tentatives de connexion échouées
- Utiliser un gestionnaire de session côté serveur sécurisé
- Mettre en œuvre des mécanismes sécurisés de récupération de mot de passe

---

## A08 - Software and Data Integrity Failures

> Les défaillances d'intégrité du logiciel et des données concernent la protection du code et des données contre les modifications non autorisées.

### Exercice 8.1 : Analyse de code avec Ghidra

**Objectif** : Évaluer l'intégrité du code dans une application.

**Difficulté** : Difficile

**Outils** : Ghidra

**Instructions** :
1. Lancez Ghidra : `ghidra`
2. Créez un nouveau projet nommé "IntegrityAnalysis"
3. Importez le binaire : /home/vagrant/labs/binaries/lab2A
4. Analysez le binaire avec les options par défaut
5. Recherchez les mécanismes de vérification d'intégrité :
   - Fonctions de vérification de signature
   - Calculs de checksum ou de hachage
   - Vérifications de l'environnement d'exécution
6. Évaluez si ces mécanismes peuvent être contournés
7. Documentez les faiblesses et les recommandations d'amélioration

### Exercice 8.2 : Test d'intégrité avec NodeGoat

**Objectif** : Exploiter des défaillances d'intégrité dans une application web.

**Difficulté** : Moyenne

**Outils** : Burp Suite, Firefox, NodeGoat

**Instructions** :
1. Accédez à NodeGoat : http://localhost:4000
2. Identifiez les fonctionnalités qui modifient des données importantes :
   - Mise à jour de profil
   - Transferts d'argent
   - Modifications de paramètres
3. Utilisez Burp Suite pour intercepter et modifier les requêtes
4. Testez si l'application vérifie correctement l'intégrité des données :
   - Modifiez les identifiants d'utilisateur
   - Changez les montants de transaction
   - Altérez les données de formulaire après validation côté client
5. Documentez les vulnérabilités trouvées et leur impact
# Guide Pratique : MobSF (Mobile Security Framework)

## Introduction
MobSF (Mobile Security Framework) est un outil automatisé tout-en-un pour les tests de pénétration, l'analyse et la sécurité des applications mobiles (Android, iOS, Windows). Il permet de réaliser des analyses statiques et dynamiques pour identifier les vulnérabilités dans les applications mobiles, en particulier celles liées à l'OWASP Mobile Top 10.

## Accès dans l'environnement Lab
- **URL**: http://localhost:8000
- **Remarque**: MobSF est déployé via Docker dans l'environnement Lab

## Analyse statique d'applications mobiles

### Téléversement et analyse d'une application
1. Accéder à l'interface web: http://localhost:8000
2. Sur la page d'accueil, cliquer sur "Upload & Analyze"
3. Sélectionner un fichier à analyser:
    - Android: APK (e.g., `/home/vagrant/labs/mobile/UnCrackable-Level1.apk`)
    - iOS: IPA
4. Cliquer sur "Analyze"
5. Observer le processus d'analyse automatique (peut prendre quelques minutes)

### Navigation dans les résultats d'analyse

#### Dashboard
Après l'analyse, vous accédez au dashboard qui présente:
1. **Security Score**: Score global de sécurité
2. **Application Information**: Informations générales (nom, version, SDK)
3. **Signer Certificate**: Détails du certificat de signature
4. **App Permissions**: Permissions demandées par l'application
5. **Manifest Analysis**: Analyse du manifeste Android
6. **Code Analysis**: Analyse du code pour les vulnérabilités
7. **Binary Analysis**: Analyse des binaires natifs
8. **URLs & Trackers**: Endpoints et trackers identifiés
9. **Malware Analysis**: Résultats d'analyse de malware

### Analyse des vulnérabilités OWASP Mobile Top 10

#### M1: Improper Platform Usage
1. Examiner la section "App Permissions":
    - Permissions excessives ou sensibles
    - Permissions dangereuses non justifiées
2. Vérifier la section "Manifest Analysis":
    - Composants exportés exposés
    - Problèmes de configuration du manifeste
3. Rechercher dans "Code Analysis":
    - Utilisation incorrecte d'APIs sensibles

#### M2: Insecure Data Storage
1. Examiner les résultats de "Code Analysis":
    - Stockage de données en clair
    - Utilisation incorrecte de SQLite
    - Stockage sur la carte SD externe
    - Stockage de données sensibles dans les préférences partagées
2. Vérifier les sections:
    - "Hardcoded Secrets" pour les secrets codés en dur
    - "File Analysis" pour les fichiers sensibles

#### M3: Insecure Communication
1. Examiner la section "Network Security":
    - Communication non chiffrée (HTTP)
    - Validation incorrecte de certificats SSL
    - Absence de pinning de certificat
2. Vérifier dans "Code Analysis":
    - Implémentation incorrecte de TLS
    - Absence de vérification de l'hôte
    - Confiance dans tous les certificats

#### M4: Insecure Authentication
1. Rechercher dans "Code Analysis":
    - Mécanismes d'authentification faibles
    - Stockage insécurisé des identifiants
    - Gestion incorrecte des sessions

#### M5: Insufficient Cryptography
1. Examiner la section "Code Analysis" pour:
    - Utilisation d'algorithmes cryptographiques faibles (MD5, DES, RC4)
    - Implémentations cryptographiques personnalisées
    - Clés cryptographiques codées en dur
    - Utilisation de vecteurs d'initialisation (IV) statiques
    - Mode ECB au lieu de CBC

#### M6: Insecure Authorization
1. Chercher dans "Code Analysis":
    - Contrôles d'accès insuffisants ou incorrects
    - Absence de vérification d'autorisation côté client
    - Élévation de privilèges possible

#### M7: Client Code Quality
1. Examiner les sections:
    - "Code Analysis" pour bugs et pratiques dangereuses
    - "NIAP Analysis" pour problèmes de qualité du code
    - "CWE" pour vulnérabilités de code catégorisées

#### M8: Code Tampering
1. Vérifier les résultats concernant:
    - Anti-tampering manquant ou faible
    - Détection de root/jailbreak absente
    - Absence de vérification d'intégrité du code

#### M9: Reverse Engineering
1. Examiner la section "Binary Analysis":
    - Absence d'obfuscation du code
    - Symboles de débogage présents
    - Protection insuffisante contre l'ingénierie inverse

#### M10: Extraneous Functionality
1. Rechercher dans:
    - "Code Analysis" pour fonctionnalités cachées
    - "Manifest Analysis" pour composants cachés
    - "Strings Analysis" pour indices de fonctionnalités de débogage

## Analyse dynamique d'applications Android

### Configuration de l'analyse dynamique
1. Depuis le rapport d'analyse statique, cliquer sur "Start Dynamic Analysis"
2. Deux options sont disponibles:
    - Utiliser un émulateur Android intégré (recommandé dans le Lab)
    - Connecter un appareil Android physique via ADB

### Configuration de l'émulateur
1. Si l'émulateur n'est pas déjà lancé, MobSF proposera de lancer un émulateur
2. Configurer les options si nécessaire:
    - Architecture: x86 (par défaut)
    - Taille de mémoire: 2048MB
    - Cliquer sur "Start Emulator" et attendre son démarrage

### Démarrage de l'analyse dynamique
1. Une fois l'émulateur prêt, cliquer sur "Start Analysis"
2. MobSF installera l'application et ses outils de test
3. L'application se lancera automatiquement dans l'émulateur

### Interaction avec l'application
1. Interagir avec l'application dans l'émulateur pour:
    - Explorer les fonctionnalités
    - Déclencher des comportements spécifiques
    - Tester des scénarios d'utilisation

2. Utiliser les boutons de contrôle:
    - "Capture Screenshot": Prendre une capture d'écran
    - "Dump Activity": Extraire l'activité actuelle
    - "Send KeyEvents": Envoyer des événements clavier
    - "Touch Events": Enregistrer/rejouer des interactions tactiles

### Exploitation de l'activité interceptée
1. Dans l'onglet "Activity Tester", naviguer entre les activités découvertes
2. Dans "API Monitor", observer les appels d'API sensibles en temps réel
3. Dans "HTTP Requests", analyser le trafic réseau capturé
4. Dans "Frida Logs", examiner les résultats de l'instrumentation

### Finalisation de l'analyse
1. Après avoir testé l'application, cliquer sur "Generate Report"
2. Examiner le rapport dynamique combiné aux résultats de l'analyse statique
3. Les données capturées incluent:
    - API sensibles utilisées
    - Stockage de données sur le périphérique
    - Communications réseau
    - Fonctions cryptographiques utilisées

## Exercices pratiques

### Exercice 1: Analyse statique d'UnCrackable-Level1.apk
1. Téléverser `/home/vagrant/labs/mobile/UnCrackable-Level1.apk` dans MobSF
2. Analyser les résultats:
    - Identifier les mécanismes de protection
    - Repérer les secrets codés en dur
    - Analyser les implémentations cryptographiques
3. Documenter au moins 5 vulnérabilités OWASP Mobile Top 10

### Exercice 2: Analyse dynamique d'UnCrackable-Level1.apk
1. Démarrer l'analyse dynamique sur l'application
2. Interagir avec l'application et observer:
    - Les appels d'API sensibles
    - Les mécanismes de vérification
    - Les erreurs générées
3. Tenter de contourner la protection contre le débogage
4. Documenter les différences entre les résultats statiques et dynamiques

## Bonnes pratiques pour l'utilisation de MobSF

### Optimisation des analyses
- Effectuez d'abord une analyse statique complète avant de passer à l'analyse dynamique
- Concentrez-vous sur les vulnérabilités à risque élevé identifiées pendant l'analyse statique
- Testez des chemins spécifiques dans l'application pendant l'analyse dynamique
- Utilisez Frida pour instrumenter les fonctions critiques

### Documentation des résultats
- Exportez les rapports au format PDF ou JSON pour documentation
- Utilisez les captures d'écran pour illustrer les vulnérabilités
- Classez les résultats par catégorie OWASP Mobile Top 10
- Priorisez les découvertes en fonction de leur impact et de leur exploitabilité

### Contremesures recommandées
Pour chaque catégorie de vulnérabilité identifiée, documentez les contremesures recommandées:
- M1: Utilisation correcte des APIs Android/iOS
- M2: Stockage sécurisé (KeyStore/KeyChain)
- M3: Mise en œuvre correcte de SSL/TLS avec pinning
- M4: Authentification forte et gestion des sessions
- M5: Algorithmes cryptographiques standards et récents
- M6: Contrôles d'autorisation côté serveur
- M7: Pratiques de codage sécurisé
- M8: Vérifications d'intégrité et détection d'altération
- M9: Obfuscation de code et anti-analyse
- M10: Suppression des fonctionnalités de débogage en production
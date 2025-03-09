# Guide Pratique : Burp Suite

## Introduction
Burp Suite est l'un des outils les plus populaires pour les tests de pénétration d'applications web. Disponible en version Community (gratuite) et Professional (payante), il permet d'intercepter, d'analyser et de modifier le trafic HTTP/HTTPS entre votre navigateur et les applications web.

## Lancement dans l'environnement Kali Linux
- **Via l'interface graphique**: Applications > Web Application Analysis > burpsuite
- **Via le terminal**: `burpsuite` ou `burpsuite-lab`

## Configuration initiale

### Création d'un projet
1. Au démarrage, sélectionnez "Temporary project" (projet temporaire)
2. Cliquez sur "Next"
3. Sélectionnez "Use Burp defaults" (configuration par défaut)
4. Cliquez sur "Start Burp"

### Configuration du proxy
1. Aller dans l'onglet "Proxy" > "Options"
2. Vérifier que l'interface d'écoute est sur 127.0.0.1:8080
3. Si nécessaire, cliquez sur "Add" pour ajouter une interface d'écoute

### Configuration du navigateur Firefox
1. Ouvrir Firefox
2. Préférences > Réseau > Paramètres
3. Sélectionner "Configuration manuelle du proxy"
4. HTTP Proxy: 127.0.0.1, Port: 8080
5. Cocher "Utiliser ce proxy pour tous les protocoles"
6. Cliquer sur "OK"

### Installation du certificat SSL
1. Avec Firefox configuré en proxy, visiter http://burp
2. Cliquer sur "CA Certificate" en haut à droite
3. Dans Firefox:
    - Préférences > Vie privée et sécurité > Afficher les certificats
    - Importer le certificat téléchargé
    - Cocher "Confirmer cette AC pour identifier des sites web"
    - Cliquer sur "OK"

## Fonctionnalités principales

### Proxy (interception de trafic)
1. Aller dans l'onglet "Proxy" > "Intercept"
2. Vérifier que "Intercept is on" est activé
3. Naviguer sur un site web avec le navigateur configuré
4. Observer les requêtes interceptées
5. Actions possibles:
    - "Forward": Transmettre la requête sans modification
    - "Drop": Annuler la requête
    - "Action": Options supplémentaires
    - Modifier la requête puis "Forward"
6. Consulter l'historique des requêtes: "Proxy" > "HTTP history"

### Target (cartographie du site)
1. Naviguer sur le site cible avec le proxy activé
2. Aller dans l'onglet "Target" > "Site map"
3. Observer la structure du site découverte automatiquement
4. Clic droit sur un domaine ou une URL:
    - "Add to scope": Ajouter à la portée du projet
    - "Spider": Explorer automatiquement
    - "Scan": Lancer un scan actif (version Pro)
    - "Send to...": Envoyer vers un autre outil

### Spider (exploration automatique)
1. Clic droit sur le domaine cible dans "Site map"
2. Sélectionner "Spider this host"
3. Configurer les options:
    - Recursion depth: Profondeur d'exploration
    - Excluded URLs: URLs à exclure
    - Form submission: Comportement pour les formulaires
4. Cliquer sur "OK"
5. Observer les nouvelles URLs découvertes dans "Site map"

### Repeater (rejeu de requêtes)
1. Dans l'historique HTTP, sélectionner une requête intéressante
2. Clic droit > "Send to Repeater"
3. Aller dans l'onglet "Repeater"
4. Modifier la requête selon vos besoins
5. Cliquer sur "Send" pour envoyer la requête
6. Analyser la réponse et les codes HTTP
7. Répéter le processus pour tester différentes variations

### Intruder (attaques automatisées)
1. Dans l'historique HTTP, sélectionner une requête avec des paramètres
2. Clic droit > "Send to Intruder"
3. Aller dans l'onglet "Intruder"
4. Sous-onglet "Positions":
    - "Clear §": Effacer les points d'insertion prédéfinis
    - Sélectionner la valeur d'un paramètre à tester
    - Cliquer sur "Add §" pour définir un point d'insertion
5. Sous-onglet "Payloads":
    - "Payload Sets": Configurer le type de charge
    - "Payload Options": Ajouter des valeurs de test
6. Cliquer sur "Start attack"
7. Analyser les résultats pour identifier des vulnérabilités

## Tests spécifiques OWASP Top 10

### A01 - Broken Access Control
1. Identifier les fonctionnalités protégées:
    - Pages d'administration
    - Profils d'utilisateurs
    - Fonctions restreintes
2. Tests à effectuer:
    - **Accès horizontal**: Modifier les IDs dans les URLs (ex: `/user/123` → `/user/124`)
    - **Accès vertical**: Tenter d'accéder à des fonctions administratives
    - **Contournement d'autorisation**: Modifier les paramètres de rôle/privilège
    - **Manipulation de jetons**: Modifier les cookies ou tokens JWT

### A02 - Cryptographic Failures
1. Analyser les communications pour identifier:
    - Cookies sans flags Secure/HttpOnly
    - Données sensibles transmises en clair
    - Certificats SSL/TLS faibles
2. Tests à effectuer:
    - Vérifier les headers HTTP de sécurité (HSTS, CSP)
    - Examiner les cookies et leurs attributs
    - Chercher des informations sensibles dans les réponses
    - Tester les redirections non sécurisées

### A03 - Injection
1. Identifier les points d'entrée utilisateur:
    - Formulaires
    - Paramètres GET/POST
    - Headers HTTP
    - Cookies
2. Tests d'injection SQL:
    - Utiliser Intruder avec des payloads SQL
    - Caractères à tester: `' " ) ; -- /* */`
    - Observer les erreurs ou comportements anormaux
3. Tests d'injection XSS:
    - Utiliser des payloads XSS basiques: `<script>alert(1)</script>`
    - Tester des encodages alternatifs
    - Vérifier le stockage ou la réflexion

### A07 - Identification and Authentication Failures
1. Tester la robustesse des mots de passe:
    - Utiliser Intruder pour des attaques par dictionnaire
    - Vérifier les politiques de complexité
2. Tester la gestion des sessions:
    - Examiner les cookies de session (validité, expiration)
    - Tester le verrouillage de compte
    - Vérifier la génération des identifiants de session

## Exercice pratique: Test de l'OWASP Juice Shop

### Configuration initiale
1. Vérifier que Juice Shop est en cours d'exécution: http://localhost:3000
2. Configurer Burp Suite comme proxy
3. Activer l'interception

### Tests à réaliser
1. **Exploration**:
    - Naviguer sur le site pour découvrir les fonctionnalités
    - Observer la structure dans Site map
    - Identifier les points d'entrée utilisateur

2. **Test d'injection SQL**:
    - Localiser le formulaire de connexion
    - Intercepter la requête de connexion
    - Modifier le champ email avec: `' OR 1=1--`
    - Analyser la réponse

3. **Test XSS**:
    - Localiser la fonction de recherche de produits
    - Envoyer une recherche avec: `<script>alert('XSS')</script>`
    - Vérifier si le script s'exécute

4. **Test de contrôle d'accès**:
    - Créer un compte utilisateur
    - Intercepter les requêtes d'accès au profil
    - Modifier les identifiants pour tenter d'accéder à d'autres profils

5. **Manipulation de jetons**:
    - Examiner les cookies et tokens JWT
    - Utiliser l'extension "JWT Editor" (si disponible)
    - Tenter de modifier les privilèges dans le token

## Astuces et bonnes pratiques
- Activer l'interception seulement quand nécessaire pour éviter de ralentir votre navigation
- Utiliser le scope pour limiter l'analyse aux sites pertinents
- Sauvegarder régulièrement votre projet Burp
- Documenter vos découvertes et prendre des captures d'écran
- Respecter les limites d'utilisation et n'utiliser ces techniques que sur des applications pour lesquelles vous avez l'autorisation

## Extensions utiles
- JWT Editor: Analyse et modification de tokens JWT
- Autorize: Tests de contrôle d'accès automatisés
- Retire.js: Détection de bibliothèques JavaScript vulnérables
- Logger++: Journalisation améliorée des requêtes/réponses
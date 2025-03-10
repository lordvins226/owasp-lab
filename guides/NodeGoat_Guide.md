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

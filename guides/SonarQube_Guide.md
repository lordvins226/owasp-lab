# Guide Pratique : SonarQube

## Introduction
SonarQube est une plateforme d'analyse statique de code qui permet de détecter les bugs, vulnérabilités et code smells dans votre code. C'est un outil essentiel pour identifier de façon préventive les problèmes de sécurité liés à l'OWASP Top 10.

## Accès et connexion
- **URL**: http://localhost:9000
- **Identifiants par défaut**: admin/admin
- **Première connexion**: Vous serez invité à changer le mot de passe

## Configuration pour la détection OWASP Top 10

### Création d'un profil de qualité OWASP
1. Administration > Quality Profiles
2. Create > Java (répéter pour chaque langage pertinent)
3. Nom: "OWASP Top 10"
4. Hériter de "Sonar way"

### Activation des règles spécifiques
Pour chaque catégorie OWASP:

#### A01 - Broken Access Control
1. Dans le profil, cliquer sur "Activate More Rules"
2. Filtrer avec les tags:
    - "access-control"
    - "auth"
    - "authorization"
3. Activer les règles pertinentes (ex: S5122, S4834, S3330, S6749)

#### A02 - Cryptographic Failures
1. Filtrer avec les tags:
    - "cryptography"
    - "ssl"
    - "tls"
2. Activer les règles pertinentes (ex: S4432, S5542, S2277)

#### A03 - Injection
1. Filtrer avec les tags:
    - "sql"
    - "injection"
    - "xss"
    - "command-injection"
2. Activer les règles pertinentes (ex: S3649, S2078, S2631, S5131, S2076)

#### A05 - Security Misconfiguration
1. Filtrer avec les tags:
    - "configuration"
    - "security-configuration"
2. Activer les règles pertinentes

#### A06 - Vulnerable and Outdated Components
1. Installer le plugin "Dependency-Check" si ce n'est pas déjà fait
2. Activer les règles de détection de dépendances vulnérables

#### A07 - Identification and Authentication Failures
1. Filtrer avec les tags:
    - "authentication"
    - "password"
2. Activer les règles pertinentes

## Analyse d'un projet

### Configuration du projet
1. Créer un nouveau projet manuellement
    - Administration > Projects > Create Project
    - Entrer un nom et une clé de projet (ex: "owasp-benchmark")

2. Générer un token d'analyse
    - Administration > Users > Tokens
    - Generate Tokens
    - Copier le token généré

### Exécution de l'analyse (Maven)
```bash
cd /home/vagrant/labs/java-app/benchmark
mvn clean verify sonar:sonar \
  -Dsonar.projectKey=owasp-benchmark \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=votre_token
```

### Exécution de l'analyse (Scanner autonome)
```bash
cd /home/vagrant/labs/java-app/benchmark

# Créer un fichier de configuration sonar-project.properties
echo "sonar.projectKey=owasp-benchmark
sonar.projectName=OWASP Benchmark
sonar.sources=src
sonar.java.binaries=target/classes
sonar.login=votre_token" > sonar-project.properties

# Lancer l'analyse
sonar-scanner
```

## Interprétation des résultats

### Dashboard du projet
- **Reliability**: Bugs potentiels
- **Security**: Vulnérabilités
- **Security Review**: Hotspots de sécurité nécessitant une revue manuelle
- **Maintainability**: Code smells

### Revue des vulnérabilités
1. Aller dans l'onglet "Issues"
2. Filtrer par type "Vulnerability"
3. Regrouper par tag pour identifier les vulnérabilités OWASP
4. Pour chaque vulnérabilité:
    - Examiner le code source incriminé
    - Lire la description et l'impact
    - Consulter les recommandations
    - Évaluer la correction proposée

### Analyse des hotspots de sécurité
1. Aller dans l'onglet "Security Hotspots"
2. Passer en revue chaque hotspot
3. Marquer comme "Safe" ou "Fixed" selon l'analyse
4. Les hotspots sont des points sensibles qui nécessitent une revue manuelle

## Exercice pratique

### Analyse d'une application vulnérable (OWASP Benchmark)
1. Accéder au projet Benchmark:
```bash
cd /home/vagrant/labs/java-app/benchmark
```

2. Compiler le projet:
```bash
mvn clean package
```

3. Configurer l'analyse SonarQube:
```bash
# Créer sonar-project.properties
echo "sonar.projectKey=benchmark
sonar.projectName=OWASP Benchmark
sonar.sources=src
sonar.java.binaries=target/classes
sonar.login=votre_token" > sonar-project.properties
```

4. Exécuter l'analyse:
```bash
sonar-scanner
```

5. Examiner les résultats dans l'interface web:
    - Identifier les vulnérabilités par catégorie OWASP
    - Noter les plus critiques
    - Proposer des corrections pour 3 vulnérabilités importantes

## Utilisation avec d'autres langages

### JavaScript/TypeScript
```bash
sonar-scanner \
  -Dsonar.projectKey=js-project \
  -Dsonar.sources=src \
  -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info
```

### Python
```bash
sonar-scanner \
  -Dsonar.projectKey=python-project \
  -Dsonar.sources=src \
  -Dsonar.python.coverage.reportPaths=coverage.xml
```

## Intégration dans les pipelines CI/CD
SonarQube peut être intégré dans votre pipeline CI/CD (Jenkins, GitLab CI, GitHub Actions) pour analyser automatiquement le code à chaque commit ou pull request.

## Bonnes pratiques
- Exécuter SonarQube régulièrement pendant le développement
- Corriger les problèmes au fur et à mesure plutôt qu'en fin de projet
- Prioriser les vulnérabilités critiques et élevées
- Former les développeurs aux bonnes pratiques de développement sécurisé
- Utiliser les résultats comme support pédagogique pour améliorer les compétences de l'équipe
# Guide Pratique : Ghidra

## Introduction
Ghidra est un outil d'ingénierie inverse développé par la NSA, rendu public en 2019. Il permet d'analyser des fichiers binaires pour en comprendre le fonctionnement, d'identifier des vulnérabilités et d'évaluer la sécurité des implémentations. Ghidra est particulièrement utile pour l'analyse des aspects cryptographiques et des vulnérabilités de type mémoire liées à l'OWASP Top 10.

## Lancement dans l'environnement Kali Linux
- **Via le terminal**: `ghidra`
- **Via l'interface graphique**: Applications > Reverse Engineering > Ghidra

## Configuration initiale

### Création d'un projet
1. Au premier lancement, accepter les termes et conditions
2. Sélectionner "File" > "New Project"
3. Choisir "Non-Shared Project" (projet non partagé)
4. Nommer le projet (ex: "OWASP-Binaries")
5. Sélectionner l'emplacement du projet (ex: "/home/vagrant/tools/ghidra/projects")
6. Cliquer sur "Finish"

### Importation d'un binaire
1. Dans le projet créé, sélectionner "File" > "Import File"
2. Naviguer vers le dossier contenant les binaires à analyser (ex: "/home/vagrant/labs/binaries")
3. Sélectionner un fichier binaire (ex: "lab1A")
4. Dans la boîte de dialogue d'importation:
    - Format: Auto-détection (généralement ELF pour Linux, PE pour Windows)
    - Language: Auto-détection
    - Options: Garder les options par défaut
5. Cliquer sur "OK"
6. À la question d'analyse, sélectionner "Yes" pour lancer l'analyse automatique
7. Dans la boîte de dialogue d'analyse:
    - Cocher toutes les options par défaut
    - Cliquer sur "Analyze"

## Interface principale

### CodeBrowser
Après l'analyse, double-cliquer sur le binaire importé pour ouvrir CodeBrowser, l'interface principale d'analyse de Ghidra avec plusieurs panneaux:

1. **Program Trees**: Structure du programme et sections
2. **Symbol Tree**: Fonctions, variables et symboles exportés/importés
3. **Data Type Manager**: Types de données définis et utilisés
4. **Listing**: Vue désassemblée du code avec annotations
5. **Decompiler**: Vue décompilée du code en pseudo-C
6. **Functions**: Liste des fonctions identifiées
7. **Defined Strings**: Chaînes de caractères trouvées dans le binaire

## Techniques d'analyse de base

### Navigation dans le code
1. Recherche de fonctions par nom:
    - "Search" > "Program Text" ou Ctrl+Shift+E
    - Entrer le nom ou un motif (ex: "main", "password", "crypt")

2. Recherche de chaînes:
    - "Search" > "For Strings" ou Ctrl+Shift+F
    - Filtrer les résultats avec des mots clés (ex: "password", "secret", "key")

3. Navigation par références:
    - Clic droit sur un symbole > "References" > "Show References to"
    - Observer les endroits où la fonction/variable est utilisée

### Analyse des fonctions
1. Double-cliquer sur une fonction dans la liste des fonctions
2. Observer le code assembleur dans la vue "Listing"
3. Examiner le pseudo-code C dans la vue "Decompiler"
4. Renommer les variables/fonctions pour améliorer la lisibilité:
    - Clic droit sur un identifiant > "Rename Variable" ou appuyer sur L
    - Entrer un nom descriptif

### Annotation du code
1. Ajouter des commentaires pour documenter votre analyse:
    - Clic droit sur une ligne > "Comments" > "Set Pre Comment" ou appuyer sur ;
    - Entrer votre commentaire

2. Définir des structures de données:
    - "Data" > "Define Structure"
    - Créer des champs correspondant aux structures du programme

## Analyse de sécurité spécifique OWASP

### A02 - Cryptographic Failures
1. Rechercher les fonctions cryptographiques:
    - Rechercher des chaînes comme "crypt", "hash", "md5", "aes", "des", "sha"
    - Identifier les bibliothèques cryptographiques importées (ex: OpenSSL)

2. Analyser les implémentations:
    - Vérifier l'utilisation d'algorithmes obsolètes (MD5, DES, RC4)
    - Examiner la génération et gestion des clés
    - Identifier les vecteurs d'initialisation (IV) codés en dur
    - Vérifier l'utilisation correcte des modes de chiffrement (ECB vs CBC)

3. Rechercher des secrets codés en dur:
    - Clés cryptographiques
    - Mots de passe
    - Jetons d'API
    - Certificats

### A03 - Injection (Command Injection)
1. Identifier les fonctions à risque:
    - Rechercher des appels système comme `system()`, `exec()`, `popen()`
    - Rechercher les fonctions de manipulation de commandes

2. Analyser le traitement des entrées:
    - Tracer le flux des données depuis les entrées jusqu'aux appels à risque
    - Vérifier si des validations ou assainissements sont effectués
    - Rechercher des concaténations de chaînes avec des entrées utilisateur

### A04 - Insecure Design (Memory Safety)
1. Rechercher des fonctions de manipulation de mémoire à risque:
    - `strcpy()`, `strcat()`, `sprintf()`, `gets()` (sans vérification de taille)
    - `memcpy()` sans validation de longueur
    - Allocation/libération incorrecte de mémoire

2. Analyser les validations de limites:
    - Vérifier si les tailles de buffer sont respectées
    - Rechercher des dépassements potentiels
    - Identifier des accès hors limites de tableaux

### A08 - Software and Data Integrity Failures
1. Rechercher les mécanismes de vérification d'intégrité:
    - Fonctions de hachage pour vérification
    - Vérification de signatures
    - Checksum de fichiers

2. Analyser le chargement dynamique:
    - Rechercher `dlopen()`, `LoadLibrary()`
    - Vérifier si les chemins sont validés
    - Identifier les bibliothèques chargées depuis des emplacements non sécurisés

## Exercice pratique: Analyse de binaire vulnérable

### Préparation
1. Lancer Ghidra et ouvrir le projet "OWASP-Binaries"
2. Importer le binaire de test: "/home/vagrant/labs/binaries/lab1A"
3. Lancer l'analyse automatique avec les options par défaut

### Analyse à réaliser
1. **Identification des fonctions principales**:
    - Localiser la fonction `main()`
    - Identifier les fonctions appelées depuis `main()`
    - Repérer les fonctions liées à l'entrée utilisateur

2. **Recherche de vulnérabilités potentielles**:
    - Rechercher des fonctions à risque (ex: `strcpy`, `gets`)
    - Identifier les appels système (`system`, `exec`)
    - Rechercher des opérations cryptographiques faibles

3. **Analyse approfondie**:
    - Renommer les variables pour améliorer la lisibilité
    - Documenter le flux de données
    - Identifier les validations manquantes ou inadéquates

4. **Documentation des vulnérabilités**:
    - Vulnérabilités de type buffer overflow
    - Problèmes cryptographiques
    - Injection de commandes
    - Secrets codés en dur

## Fonctionnalités avancées

### Script Ghidra
Ghidra prend en charge plusieurs langages de script (Java, Python, etc.) pour automatiser l'analyse:

1. Accéder au gestionnaire de scripts:
    - "Window" > "Script Manager"
    - Explorer les scripts disponibles par catégorie

2. Exécuter un script:
    - Sélectionner un script dans la liste
    - Cliquer sur "Run"

### Analyse collaborative
Pour les projets en équipe, Ghidra supporte des projets partagés:

1. Configurer un serveur Ghidra:
    - Exécuter `ghidraRun --server`
    - Configurer les utilisateurs et autorisations

2. Créer un projet partagé:
    - "File" > "New Project"
    - Sélectionner "Shared Project"
    - Spécifier le serveur et les détails du projet

## Astuces et bonnes pratiques
- Renommez systématiquement les variables et fonctions pour améliorer la lisibilité
- Utilisez des commentaires pour documenter votre analyse
- Combinez l'analyse statique (Ghidra) avec l'analyse dynamique (GDB, strace)
- Prenez des captures d'écran des parties importantes du code
- Pour les binaires complexes, concentrez-vous d'abord sur les fonctions critiques
- Utilisez la fonction de comparaison binaire pour analyser les différences entre versions
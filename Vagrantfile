# -*- mode: ruby -*-
# vi: set ft=ruby :

VM_NAME = "owasp-lab-environment"
VM_IP = "192.168.33.11"
# VM_MEMORY = 4096
VM_MEMORY = 8192
VM_CPUS = 4

FORWARDED_PORTS = {
  9000 => 9000,   # SonarQube
  8080 => 8080,   # Burp Suite
  8081 => 8081,   # WebGoat
  3000 => 3000,   # Juice Shop
  8888 => 8888,   # DVWA
  8000 => 8000,   # MobSF
  8834 => 8834,   # Nessus
  4000 => 4000,   # NodeGoat
  9090 => 9090    # WebWolf (part of WebGoat)
}

def arm64?
  arch = `uname -m`.strip
  return true if arch == "arm64"
  if RUBY_PLATFORM.include?("darwin")
    proc_translated = `sysctl -in sysctl.proc_translated 2>/dev/null`.strip
    return true if proc_translated == "0"
  end
  return false
end

Vagrant.configure("2") do |config|
  config.vm.boot_timeout = 900
  config.vm.graceful_halt_timeout = 300

  if arm64?
    config.vm.box = "mdiazn80/kali-arm64"
    config.vm.box_version = "2024.2"
    puts "Detected ARM64 architecture, using Kali ARM64 box"
  else
    config.vm.box = "kalilinux/rolling"
    puts "Detected x86_64 architecture, using standard Kali box"
  end

  # Provider-specific configurations
  config.vm.provider "vmware_desktop" do |vmware|
    vmware.gui = true
    vmware.memory = VM_MEMORY
    vmware.cpus = VM_CPUS
    vmware.vmx["displayName"] = VM_NAME
    vmware.vmx["memsize"] = VM_MEMORY
    vmware.vmx["numvcpus"] = VM_CPUS
    vmware.vmx["ethernet0.pcislotnumber"] = "160"
  end

  config.vm.provider "parallels" do |prl|
    prl.memory = VM_MEMORY
    prl.cpus = VM_CPUS
    prl.name = VM_NAME
    prl.customize ["set", :id, "--startup-view", "window"]
    prl.update_guest_tools = true
  end

  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
    vb.memory = VM_MEMORY
    vb.cpus = VM_CPUS
    vb.name = VM_NAME
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
  end

  config.vm.network "public_network", use_dhcp_assigned_default_route: true
#   config.vm.network "private_network", ip: VM_IP
  config.vm.hostname = "owasp-lab"

  FORWARDED_PORTS.each do |guest, host|
    config.vm.network "forwarded_port", guest: guest, host: host
  end

  # Synchronisation des dossiers
  config.vm.synced_folder "guides/", "/home/vagrant/docs/guides", create: true
  config.vm.synced_folder "exercises/", "/home/vagrant/exercises", create: true

  # Désactiver les redémarrages automatiques des services avant toute installation
  config.vm.provision "shell", inline: <<-SHELL
    export DEBIAN_FRONTEND=noninteractive

    echo '#!/bin/sh' > /usr/sbin/policy-rc.d
    echo 'exit 101' >> /usr/sbin/policy-rc.d
    chmod +x /usr/sbin/policy-rc.d

    echo 'DPkg::options { "--force-confdef"; "--force-confold"; }' > /etc/apt/apt.conf.d/local
    echo 'Dpkg::Use-Pty "0";' >> /etc/apt/apt.conf.d/local

    # Désactiver les redémarrages automatiques de services
    mkdir -p /etc/needrestart/conf.d
    echo "\$nrconf{restart} = 'a';" > /etc/needrestart/conf.d/99-vagrant-disable.conf

    echo "Configuration du système pour éviter les blocages pendant le provisionnement..."
  SHELL

  config.vm.provision "shell", path: "scripts/linux/provision.sh"

  # Restaurer le comportement normal des services après le provisionnement
  config.vm.provision "shell", inline: <<-SHELL
    # Réactiver les redémarrages automatiques des services
    rm -f /usr/sbin/policy-rc.d
    rm -f /etc/apt/apt.conf.d/local
    rm -f /etc/needrestart/conf.d/99-vagrant-disable.conf

    echo "Provisionnement terminé avec succès."
  SHELL

  # Message post-installation
  config.vm.post_up_message = <<-MESSAGE
  ╔═══════════════════════════════════════════════════════════════════╗
  ║                                                                   ║
  ║   Bienvenue dans l'Environnement de Lab OWASP Top 10 !            ║
  ║                                                                   ║
  ╚═══════════════════════════════════════════════════════════════════╝

  OUTILS PRINCIPAUX DE SÉCURITÉ:
    ▶ SonarQube (Analyse statique):   http://localhost:9000 (admin/admin)
       Usage: Détection des vulnérabilités dans le code source

    ▶ Burp Suite (Tests web):         burpsuite
       Usage: Interception et modification des requêtes HTTP/HTTPS

    ▶ Nessus Expert:                  https://localhost:8834
       Usage: Scan complet de vulnérabilités
       Gestion: nessus-start, nessus-stop, nessus-status, nessus-web

    ▶ Ghidra (Analyse binaire):       ghidra
       Usage: Rétro-ingénierie

    ▶ MobSF (Sécurité mobile):        http://localhost:8000
       Usage: Analyse statique et dynamique d'applications mobiles

  APPLICATIONS VULNÉRABLES:
    ▶ WebGoat:          http://localhost:8081/WebGoat
    ▶ WebWolf:          http://localhost:9090/WebWolf
    ▶ Juice Shop:       http://localhost:3000
    ▶ DVWA:             http://localhost:8888 (admin/password)
    ▶ NodeGoat:         http://localhost:4000 (admin/Admin_123)
      Tutorial:         http://localhost:4000/tutorial

  COMMANDES UTILES:

    GESTION DES SERVICES:
    ▶ start_services     - Démarrer tous les services
    ▶ stop_services      - Arrêter tous les services
    ▶ status             - Afficher l'état des services Docker
    ▶ restart_webgoat    - Redémarrer WebGoat
    ▶ restart_dvwa       - Redémarrer DVWA

    LANCEMENT DES OUTILS:
    ▶ burpsuite_launcher - Lancer l'installation de Burp Suite
    ▶ ghidra    - Lancer Ghidra

    CONTRÔLE DE NESSUS:
    ▶ nessus-start       - Démarrer le service Nessus
    ▶ nessus-stop        - Arrêter le service Nessus
    ▶ nessus-status      - Vérifier le statut du service Nessus
    ▶ nessus-web         - Ouvrir l'interface web de Nessus

    VÉRIFICATION DES SERVICES:
    ▶ sonarqube-status   - Vérifier si SonarQube est actif
    ▶ mobsf-status       - Vérifier si MobSF est actif
    ▶ nodegoat-status    - Vérifier si NodeGoat est actif

    ACCÈS AUX APPLICATIONS WEB:
    ▶ webgoat-web        - Ouvrir WebGoat dans le navigateur
    ▶ webwolf-web        - Ouvrir WebWolf dans le navigateur
    ▶ juiceshop-web      - Ouvrir Juice Shop dans le navigateur
    ▶ dvwa-web           - Ouvrir DVWA dans le navigateur
    ▶ nodegoat-web       - Ouvrir NodeGoat dans le navigateur
    ▶ nodegoat-tutorial  - Ouvrir le tutoriel NodeGoat
    ▶ sonarqube-web      - Ouvrir SonarQube dans le navigateur
    ▶ mobsf-web          - Ouvrir MobSF dans le navigateur

    CONSULTATION DES LOGS:
    ▶ webgoat-logs       - Afficher les logs de WebGoat en temps réel
    ▶ juiceshop-logs     - Afficher les logs de Juice Shop en temps réel
    ▶ dvwa-logs          - Afficher les logs de DVWA en temps réel
    ▶ mobsf-logs         - Afficher les logs de MobSF en temps réel
    ▶ nodegoat-logs      - Afficher les logs de NodeGoat en temps réel

    DOCUMENTATION:
    ▶ guides             - Lister les guides disponibles
    ▶ show-guide [nom]   - Afficher un guide spécifique
                           Exemple: show-guide BurpSuite_Guide.md

  DOCUMENTATION:
    ▶ Des guides détaillés pour chaque outil sont disponibles dans:
      /home/vagrant/docs/guides/
      Guides disponibles: BurpSuite_Guide.md, Ghidra_Guide.md, MobSF_Guide.md,
                          Nessus_Guide.md, SonarQube_Guide.md

  L'interface graphique de Kali Linux a été activée.
  Utilisez 'vagrant ssh' pour accéder à la ligne de commande.
  MESSAGE
  end
# -*- mode: ruby -*-
# vi: set ft=ruby :

VM_NAME = "owasp-lab-environment"
VM_IP = "192.168.33.11"
VM_MEMORY = 4096
VM_CPUS = 4

FORWARDED_PORTS = {
  9000 => 9000,   # SonarQube
  8080 => 8080,   # Burp Suite
  8081 => 8081,   # WebGoat
  3000 => 3000,   # Juice Shop
  80 => 8888,     # DVWA
  8000 => 8000,   # MobSF
  8834 => 8834,   # Nessus
  4000 => 4000    # NodeGoat
}

# Détection d'architecture pour Apple Silicon
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

  config.vm.network "private_network", ip: VM_IP
  config.vm.hostname = "owasp-lab"

  FORWARDED_PORTS.each do |guest, host|
    config.vm.network "forwarded_port", guest: guest, host: host
  end

  # Synchronisation des dossiers
  config.vm.synced_folder "guides/", "/home/vagrant/docs/guides", create: true
  config.vm.synced_folder "exercises/", "/home/vagrant/exercises", create: true
  config.vm.synced_folder "configs/", "/home/vagrant/configs", create: true

  # Désactiver les redémarrages automatiques des services avant toute installation
  config.vm.provision "shell", inline: <<-SHELL
    # Configuration pour éviter les blocages pendant l'installation des paquets
    export DEBIAN_FRONTEND=noninteractive

    # Désactiver les redémarrages de services pendant le provisionnement
    echo '#!/bin/sh' > /usr/sbin/policy-rc.d
    echo 'exit 101' >> /usr/sbin/policy-rc.d
    chmod +x /usr/sbin/policy-rc.d

    # Configuration de apt pour éviter les questions interactives
    echo 'DPkg::options { "--force-confdef"; "--force-confold"; }' > /etc/apt/apt.conf.d/local
    echo 'Dpkg::Use-Pty "0";' >> /etc/apt/apt.conf.d/local

    # Désactiver les redémarrages automatiques de services
    mkdir -p /etc/needrestart/conf.d
    echo "\$nrconf{restart} = 'a';" > /etc/needrestart/conf.d/99-vagrant-disable.conf

    echo "Configuration du système pour éviter les blocages pendant le provisionnement..."
  SHELL

  config.vm.provision "shell", path: "scripts/provision.sh"

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
  ║   Environnement de Lab OWASP Top 10 sur Kali Linux                ║
  ║                                                                   ║
  ╚═══════════════════════════════════════════════════════════════════╝

  OUTILS PRINCIPAUX DE SÉCURITÉ:
    ▶ SonarQube (Analyse statique):   http://localhost:9000 (admin/admin)
    ▶ Burp Suite (Tests web):         burp
    ▶ Nessus Expert:                  https://localhost:8834
    ▶ Ghidra (Analyse binaire):       ghidra
    ▶ MobSF (Sécurité mobile):        http://localhost:8000

  APPLICATIONS VULNÉRABLES:
    ▶ WebGoat:          http://localhost:8081/WebGoat
    ▶ Juice Shop:       http://localhost:3000
    ▶ DVWA:             http://localhost:8888 (admin/password)
    ▶ NodeGoat:         http://localhost:4000 (admin/Admin_123)
      Tutorial:         http://localhost:4000/tutorial

  L'interface graphique de Kali Linux a été activée.
  Utilisez 'vagrant ssh' uniquement si vous souhaitez accéder à la ligne de commande.
  MESSAGE
end
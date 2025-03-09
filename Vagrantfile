# -*- mode: ruby -*-
# vi: set ft=ruby :

# Configuration des ressources VM
VM_NAME = "owasp-lab-environment"
VM_IP = "192.168.33.10"
VM_MEMORY = 8192
VM_CPUS = 4

# Ports à rediriger
FORWARDED_PORTS = {
  9000 => 9000,   # SonarQube
  8080 => 8080,   # Burp Suite
  8081 => 8081,   # WebGoat
  3000 => 3000,   # Juice Shop
  80 => 8888,     # DVWA
  8000 => 8000,   # MobSF
}

Vagrant.configure("2") do |config|
  # Utiliser Kali Linux comme box de base
  config.vm.box = "kalilinux/rolling"

  # Configuration pour VMware
  config.vm.provider "vmware_desktop" do |vmware|
    vmware.gui = true
    vmware.memory = VM_MEMORY
    vmware.cpus = VM_CPUS
    vmware.vmx["displayName"] = VM_NAME
    # Options supplémentaires pour VMware
    vmware.vmx["memsize"] = VM_MEMORY
    vmware.vmx["numvcpus"] = VM_CPUS
  end

  # Configuration pour VirtualBox (alternative)
  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
    vb.memory = VM_MEMORY
    vb.cpus = VM_CPUS
    vb.name = VM_NAME
    # Performance optimisations pour VirtualBox
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
  end

  # Configuration réseau
  config.vm.network "private_network", ip: VM_IP
  config.vm.hostname = "owasp-lab"

  # Redirection de ports
  FORWARDED_PORTS.each do |guest, host|
    config.vm.network "forwarded_port", guest: guest, host: host
  end

  # Synchronisation des dossiers
  config.vm.synced_folder "guides/", "/home/vagrant/docs/guides"
  config.vm.synced_folder "exercises/", "/home/vagrant/exercises"
  config.vm.synced_folder "configs/", "/home/vagrant/configs"

  # Provisionnement
  config.vm.provision "shell", path: "scripts/provision.sh"

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
    ▶ OWASP ZAP (Alternative Nessus): zap
    ▶ Ghidra (Analyse binaire):       ghidra
    ▶ MobSF (Sécurité mobile):        http://localhost:8000

  APPLICATIONS VULNÉRABLES:
    ▶ WebGoat:          http://localhost:8081/WebGoat
    ▶ Juice Shop:       http://localhost:3000
    ▶ DVWA:             http://localhost:8888 (admin/password)

  Utilisez 'vagrant ssh' pour vous connecter à la VM.
  MESSAGE
end
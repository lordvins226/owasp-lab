# -*- mode: ruby -*-
# vi: set ft=ruby :

# Configuration des ressources VM
VM_NAME = "owasp-lab-environment"
VM_IP = "192.168.33.10"
VM_MEMORY = 4096
VM_CPUS = 2

# Ports à rediriger
FORWARDED_PORTS = {
  9000 => 9000,   # SonarQube
  8080 => 8080,   # Burp Suite
  8081 => 8081,   # WebGoat
  3000 => 3000,   # Juice Shop
  80 => 8888,     # DVWA
  8000 => 8000,   # MobSF
  8834 => 8834    # Nessus
}

Vagrant.configure("2") do |config|
  # Utiliser Kali Linux comme box de base
  config.vm.box = "kalilinux/rolling"

  # Configuration pour VMware
  config.vm.provider "vmware_desktop" do |vmware|
    # Activer l'interface graphique
    vmware.gui = true

    # Allouer les ressources
    vmware.memory = VM_MEMORY
    vmware.cpus = VM_CPUS
    vmware.vmx["displayName"] = VM_NAME

    # Options supplémentaires pour VMware
    vmware.vmx["memsize"] = VM_MEMORY
    vmware.vmx["numvcpus"] = VM_CPUS

    # Optimisation de l'affichage
    vmware.vmx["svga.autodetect"] = "TRUE"
    vmware.vmx["svga.vramSize"] = "128MB"
  end

  # Configuration pour VirtualBox (alternative)
  config.vm.provider "virtualbox" do |vb|
    # Activer l'interface graphique
    vb.gui = true

    # Allouer les ressources
    vb.memory = VM_MEMORY
    vb.cpus = VM_CPUS
    vb.name = VM_NAME

    # Performance optimisations pour VirtualBox
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--ioapic", "on"]

    # Optimisation de l'affichage
    vb.customize ["modifyvm", :id, "--vram", "128"]
    vb.customize ["modifyvm", :id, "--graphicscontroller", "vboxsvga"]
    vb.customize ["modifyvm", :id, "--accelerate3d", "on"]
  end

  # Configuration réseau
  config.vm.network "private_network", ip: VM_IP
  config.vm.hostname = "owasp-lab"

  # Redirection de ports
  FORWARDED_PORTS.each do |guest, host|
    config.vm.network "forwarded_port", guest: guest, host: host
  end

  # Synchronisation des dossiers
  config.vm.synced_folder "guides/", "/home/vagrant/docs/guides", create: true
  config.vm.synced_folder "exercises/", "/home/vagrant/exercises", create: true
  config.vm.synced_folder "configs/", "/home/vagrant/configs", create: true

  # Installation des additions invités pour VirtualBox
  config.vm.provision "shell", inline: <<-SHELL
    # Mise à jour du système
    apt-get update

    # Installation des outils pour l'environnement graphique et les additions invités
    apt-get install -y dkms build-essential linux-headers-$(uname -r)

    # Installation des additions invités selon le provider
    if [ -d "/opt/VBoxGuestAdditions" ]; then
      # VirtualBox détecté
      apt-get install -y virtualbox-guest-x11
    elif [ -d "/usr/lib/vmware-tools" ] || [ -d "/usr/lib/open-vm-tools" ]; then
      # VMware détecté
      apt-get install -y open-vm-tools open-vm-tools-desktop
    fi

    # Assurez-vous que l'interface graphique démarre correctement
    systemctl enable lightdm

    # Permettre à tous les utilisateurs de démarrer l'interface graphique
    if [ -f "/etc/X11/Xwrapper.config" ]; then
      sed -i 's/allowed_users=.*$/allowed_users=anybody/' /etc/X11/Xwrapper.config
    fi

    echo "Installation des additions invités terminée."
  SHELL

  # Provisionnement principal
  config.vm.provision "shell", path: "scripts/provision.sh"

  # Message post-installation
  config.vm.post_up_message = <<-MESSAGE
  ╔═══════════════════════════════════════════════════════════════════╗
  ║                                                                   ║
  ║   Environnement de Lab OWASP Top 10 sur Kali Linux               ║
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

  L'interface graphique de Kali Linux a été activée.
  Utilisez 'vagrant ssh' uniquement si vous souhaitez accéder à la ligne de commande.
  MESSAGE
end
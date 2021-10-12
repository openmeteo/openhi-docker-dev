# -*- mode: ruby -*-
# vi: set ft=ruby :

$script = <<-SCRIPT
# Install docker
apt-get update
apt-get -y upgrade
apt-get install -y --no-install-recommends apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y --no-install-recommends docker-ce docker-ce-cli containerd.io

# Give user "vagrant" permission to use docker
usermod -a -G docker vagrant
SCRIPT

Vagrant.configure("2") do |config|
 config.vm.box = "debian/bullseye64"
 config.vm.network "forwarded_port", guest: 8001, host: 8001
 config.vm.provider "virtualbox" do |vb|
   vb.memory = "1024"
 end
 config.vbguest.auto_update = false
 config.vbguest.no_install = false
 config.vbguest.no_remote = true
 config.ssh.forward_agent = true
 config.vm.hostname = "docker-enhydris-dev"
 config.vm.synced_folder ".", "/vagrant", :mount_options => ["rw"]
 config.vm.provision "shell",
   inline: $script
end

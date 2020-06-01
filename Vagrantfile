# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
 config.vm.box = "germanrio/docker-buster"
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
end

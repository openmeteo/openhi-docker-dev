# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
 # The default ubuntu/xenial64 image has issues with vbguest additions
 config.vm.box = "germanrio/docker-buster"
 config.vm.network "forwarded_port", guest: 8001, host: 8001

 # Set memory for the default VM
 config.vm.provider "virtualbox" do |vb|
   vb.memory = "1024"
 end

 # Configure vbguest auto update options
 config.vbguest.auto_update = false
 config.vbguest.no_install = false
 config.vbguest.no_remote = true
 config.ssh.forward_agent = true

 # Configure the hostname for the default machine
 config.vm.hostname = "docker-enhydris-dev"

 # Mount this folder as RO in the guest, since it contains secure stuff
 config.vm.synced_folder ".", "/vagrant", :mount_options => ["rw"]
 
$script = <<-'SCRIPT'
if  [ -f "/vagrant/dbdump.tar.gz" ] ; then
	 cp /vagrant/dbdump.tar.gz /vagrant/openhi-docker-dev/dbdump/
fi
SCRIPT

 config.vm.provision "shell", inline: $script, privileged: false
 # And finally run the docker local provisioner
   config.vm.provision "docker" do |docker|
    # docker.build_dir = "build"
	 docker.build_image "-t enhydris-dev", args: '/vagrant'
   end

end

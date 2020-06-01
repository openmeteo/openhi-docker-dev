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
$script = <<-'SCRIPT'
 cat /vagrant/authorized_keys  >>  "/home/vagrant/.ssh/authorized_keys"
    touch "/home/vagrant/.ssh/known_hosts"
    ssh-keyscan -H github.com >> "/home/vagrant/.ssh/known_hosts"
    sudo chown -v vagrant "/home/vagrant/.ssh/known_hosts"
    ssh -T git@github.com

if  [ -f "/vagrant/dbdump.tar.gz" ] ; then
	 cp /vagrant/dbdump.tar.gz /vagrant/openhi-docker-dev/dbdump/
fi


if [ ! -d "/vagrant/enhydris" ] ; then
    git clone git@github.com:openmeteo/enhydris /vagrant/enhydris
fi
if [ ! -d "/vagrant/enhydris-synoptic" ] ; then
git clone git@github.com:openmeteo/enhydris-synoptic /vagrant/enhydris-synoptic
fi
if [ ! -d "/vagrant/enhydris-autoprocess" ] ; then
git clone git@github.com:openmeteo/enhydris-autoprocess /vagrant/enhydris-autoprocess
fi
if [ ! -d "/vagrant/enhydris-openhigis" ] ; then
git clone git@github.com:openmeteo/enhydris-openhigis   /vagrant/enhydris-openhigis
fi
SCRIPT

 config.vm.provision "shell", inline: $script, privileged: false
 # And finally run the docker local provisioner
   config.vm.provision "docker" do |docker|
    # docker.build_dir = "build"
	 docker.build_image "-t enhydris-dev", args: '/vagrant'
  end
end

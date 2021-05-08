#!/bin/bash

sudo service apache2 start
sudo service postgresql start
sudo service rabbitmq-server start
( echo "Starting VNC server..."; USER=root vncserver :1 -geometry 1280x800 -depth 24 ) &
sleep 2
cd /opt/enhydris
echo "Container is running"
echo "Enter:"
echo " - 'dbimport' to discard any existing database and import it from dbdump.tar.gz"
echo " - 'runserver' to run the server"
echo " - 'runtests' to run all the tests"
echo " - 'runsynoptic' to create the synoptic static files"
echo " - 'celery worker -A enhydris -l info --concurrency=1' to run the celery worker"
echo " - 'exit' to stop the container"
bash
echo "Killing VNC server..."; killall Xtightvnc
sudo service rabbitmq-server stop
sudo service postgresql stop
sudo service apache2 stop

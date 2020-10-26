#!/bin/bash

service apache2 start
service postgresql start
service rabbitmq-server start
( echo "Starting VNC server ..."; USER=root vncserver :1 -geometry 1280x800 -depth 24 ) &
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
service rabbitmq-server stop
service postgresql stop
service apache2 stop

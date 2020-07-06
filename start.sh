#!/bin/bash

service apache2 start
service postgresql start
service rabbitmq-server start
cd /opt/enhydris
export PATH=/home/foo/venv/bin:$PATH
export PYTHONPATH=/opt/enhydris-openhigis:/opt/enhydris-synoptic:/opt/enhydris-autoprocess
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

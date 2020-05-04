#!/bin/bash

set -e

service postgresql start
cd /opt/enhydris
export PATH=/home/foo/venv/bin:$PATH
echo "Container is running"
echo "Enter 'dbimport' to discard any existing database and import it from dbdump.tar.gz"
echo "Enter 'python manage.py runserver 0.0.0.0:8000' to run the server"
echo "Enter 'python manage.py test' to run the tests"
echo "Enter 'exit' to stop the container"
bash
service postgresql stop

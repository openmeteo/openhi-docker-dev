#!/bin/bash
if docker ps -a | grep -q ' enhydris-dev$'; then
    echo "Container already exists; starting it..."
    docker start -i enhydris-dev
else
    echo "Container doesn't exist; creating it"
    docker run --name enhydris-dev -it \
        -v `pwd`/enhydris:/opt/enhydris \
        -v `pwd`/enhydris-openhigis:/opt/enhydris-openhigis \
        -v `pwd`/enhydris-synoptic:/opt/enhydris-synoptic \
        -v `pwd`/enhydris-autoprocess:/opt/enhydris-autoprocess \
        -v `pwd`/dbdump:/dbdump -p 8001:8000 enhydris-dev
fi

#!/bin/bash

docker_image_has_changed() {
    image_id=`docker image ls | grep '^enhydris-dev'|awk '{ print $3 }'`
    container_image_id=`docker ps -a | grep ' enhydris-dev$' | awk '{ print $2 }'`
    [[ -z "$image_id"
       || ( "$image_id" != "$container_image_id"
            &&
           "$container_image_id" != "enhydris-dev"
          )
    ]]
    return $?
}

if docker_image_has_changed; then
    echo "Container doesn't exist or the image has changed; creating new container"
    docker rm enhydris-dev
    docker run --name enhydris-dev -it \
        -v `pwd`/enhydris:/opt/enhydris \
        -v `pwd`/enhydris-openhigis:/opt/enhydris-openhigis \
        -v `pwd`/enhydris-synoptic:/opt/enhydris-synoptic \
        -v `pwd`/enhydris-autoprocess:/opt/enhydris-autoprocess \
        -v `pwd`/shared:/shared -p 15432:5432 -p 8001:80 -p 5901:5901 enhydris-dev
else
    echo "Container already exists; starting it..."
    docker start -i enhydris-dev
fi

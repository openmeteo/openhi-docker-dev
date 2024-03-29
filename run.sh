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

if [[ "$MSYSTEM" =~ ^(MINGW|MSYS) ]]; then
    # Use extra slash in Git Bash; see https://stackoverflow.com/questions/28533664/
    mingw_leading_slash=/

    mingw_winpty=winpty

    # This is used in start.sh to chown some mounted volumes; see
    # https://github.com/docker/for-win/issues/2476
    host_os_parm="-e HOST_OS=Windows"
fi

if docker_image_has_changed; then
    echo "Container doesn't exist or the image has changed; creating new container"
    docker rm enhydris-dev
    $mingw_winpty docker run --name enhydris-dev -it \
        -v ${mingw_leading_slash}`pwd`/enhydris:/opt/enhydris \
        -v ${mingw_leading_slash}`pwd`/enhydris-openhigis:/opt/enhydris-openhigis \
        -v ${mingw_leading_slash}`pwd`/enhydris-synoptic:/opt/enhydris-synoptic \
        -v ${mingw_leading_slash}`pwd`/enhydris-autoprocess:/opt/enhydris-autoprocess \
        -v ${mingw_leading_slash}`pwd`/shared:/shared \
        -p 15432:5432 -p 8001:80 -p 5901:5901 \
        --add-host localhost:127.0.0.1 --add-host mycontainer:127.0.1.1 \
        enhydris-dev
else
    echo "Container already exists; starting it..."
    $mingw_winpty docker start -i enhydris-dev
fi

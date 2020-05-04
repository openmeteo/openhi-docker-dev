# openhi-docker-dev

Ready-made Enhydris development environment

1. Clone this repository: `git clone --recurse-submodules git@github.com:openmeteo/openhi-docker-dev`.
   (If you clone forgetting `--recurse-submodules`, in the working
   directory tell it `git submodule init` and `git submodule update`.)

2. Get a database dump file named `dbdump.tar.gz` and put it in the
   `dbdump` directory.

3. `./build.sh` will build the image.

4. `./run.sh` will create/start the container.

5. Once in the container, `dbimport` will import the database.

6. In the container, `python manage.py runserver 0.0.0.0:8000` will start the
   server.

7. In your browser, visit http://localhost:8001/.

If you go by the Vagrant method: (create a vagrant directory by the directory hosting the Vagrantfile). Vagrant need this to 

1. Get a database dump file named `dbdump.tar.gz` and put it in the
   `dbdump` directory. if you have it in the source dir vagrant will copy it to the dump directory

2. `vagrant up` : If you run `vagrant up` before, run `vagrant provision` to download the repo and built the docker image

3. `vagrant ssh`: to get in the vagrant machine 

4. `./build.sh` will build the image.

5. `./run.sh` : will create/start the container.

6. Once in the container, `dbimport` will import the database.

7. In the container, `python manage.py runserver 0.0.0.0:8000` will start the server.

8. In your local host browser, visit http://localhost:8001/. (if you would like to change the host port number change line 6 of the Vagrantfile)

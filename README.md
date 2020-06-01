# openhi-docker-dev

Ready-made Enhydris development environment

Prerequisites:
 - On Windows: VirtualBox
 - Linux: Docker

1. Clone this repository: `git clone git@github.com:openmeteo/openhi-docker-dev`.

2. Enter the working directory: `cd openhi-docker-dev`

3. Clone the Enhydris repositories:

      git clone git@github.com:openmeteo/enhydris
      git clone git@github.com:openmeteo/enhydris-synoptic
      git clone git@github.com:openmeteo/enhydris-autoprocess
      git clone git@github.com:openmeteo/enhydris-openhigis

4. Get a database dump file named `dbdump.tar.gz` and put it in the
   `dbdump` directory.

5. (Windows/Vagrant only). `vagrant up`, then `vagrant ssh`.

   (Note: We haven't had success trying to run Docker on Windows, and
   how it will turn out depends on the operating system version and
   edition and on the hardware. We therefore use vagrant on VirtualBox
   to create a Debian machine, and we run Docker inside the Debian
   machine.)

6. `./build.sh` will build the image.

7. `./run.sh` will create/start the container.

8. Once in the container, `dbimport` will import the database.

9. In the container, `python manage.py runserver 0.0.0.0:8000` will start the
   server.

10. In your browser, visit http://localhost:8001/.

# openhi-docker-dev

Ready-made Enhydris development environment

## Prerequisites

- On Windows: VirtualBox
- Linux: Docker

## Setting up

1. Clone this repository: `git clone git@github.com:openmeteo/openhi-docker-dev`.

2. Enter the working directory: `cd openhi-docker-dev`

3. Clone the Enhydris repositories:

   ```
   git clone git@github.com:openmeteo/enhydris
   git clone git@github.com:openmeteo/enhydris-synoptic
   git clone git@github.com:openmeteo/enhydris-autoprocess
   git clone git@github.com:openmeteo/enhydris-openhigis
   ```

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

9. `python manage.py migrate` will ensure the database is up-to-date (the
   database import file could be slightly out of date).

10. In the container, `runserver` will start the server.

11. In your browser, visit http://localhost:8001/.

## Running the unit tests in a visible browser

First, make sure that the `chrome_options` and `SELENIUM_WEBDRIVERS`
settings in `enhydris/enhydris_project/settings/local.py` are as they
are in `local.py` (in the root directory of `enhydris-docker-dev`). (The
top-level `local.py` is copied to
`enhydris/enhydris_project/settings/local.py` when the container is
built, unless the latter file already exists.)

By default, selenium tests are run headlessly. If you want to make them
visible, then:

1. In `enhydris/enhydris_project/settings/local.py`, comment out the
   line `chrome_options.add_argument("--headless")`.
2. Use a VNC client to connect to `localhost:5901`, using `topsecret` as
   the password.

Then, when you run the Selenium tests, they should be visible.

FROM debian:bullseye-slim
ARG apt_proxy_line=''
ARG USER_ID=65534
ARG GROUP_ID=65534
RUN echo $apt_proxy_line >/etc/apt/apt.conf.d/02proxy
ADD VERSION .
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y upgrade \
    && apt-get install -y locales ca-certificates wget gnupg
RUN sed -i 's/^# en_US.UTF-8 /en_US.UTF-8 /' /etc/locale.gen && locale-gen
ENV LC_CTYPE=en_US.UTF-8

RUN echo "deb https://packagecloud.io/timescale/timescaledb/debian/ bullseye main" \
    >/etc/apt/sources.list.d/timescaledb.list \
    && wget --quiet -O - https://packagecloud.io/timescale/timescaledb/gpgkey \
        | apt-key add -

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'

RUN apt-get -y update && apt-get install -y --no-install-recommends \
        git wget build-essential dos2unix less nano vim curl unzip \
        virtualenv python3-virtualenv python3-pip python3-ipython \
        postgresql-postgis postgresql-postgis-scripts \
        timescaledb-2-postgresql-13 rabbitmq-server \
        python3-psycopg2 python3-gdal python3-pandas python3-matplotlib \
        python3-dev libjpeg-dev libfreetype6-dev \
        tmux apache2 google-chrome-stable cgi-mapserver \
        tightvncserver lxde xfonts-base xfonts-75dpi xfonts-100dpi \
        npm gettext psmisc sudo python3-tblib \
    && apt-get clean

# Make PostgreSQL way faster, at the expense of it being corruptible
RUN echo "fsync = off" >>/etc/postgresql/13/main/postgresql.conf
RUN echo "full_page_writes = off" >>/etc/postgresql/13/main/postgresql.conf

RUN echo "shared_preload_libraries = 'timescaledb'" \
    >>/etc/postgresql/13/main/postgresql.conf

# Replace Debian's too old npm with a newer one
RUN npm install -g npm@6.14.9

# install chromedriver
RUN wget -O /tmp/chromedriver.zip http://chromedriver.storage.googleapis.com/`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE`/chromedriver_linux64.zip
RUN unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/

COPY apache.conf /etc/apache2/sites-available/000-default.conf
RUN echo "ServerName enhydris.local" >>/etc/apache2/apache2.conf
RUN a2enmod proxy
RUN a2enmod proxy_http

# Mapserver
RUN a2enmod headers
RUN a2enmod cgid
RUN mkdir /var/log/mapserver
RUN chown www-data:www-data /var/log/mapserver
RUN sed -i 's/^# IPv4 local connections/host openmeteo mapserver samehost trust\n&/' /etc/postgresql/13/main/pg_hba.conf

RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/13/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/13/main/postgresql.conf
EXPOSE 5432
EXPOSE 8000
EXPOSE 5901

RUN echo "mycontainer" > /etc/hostname
RUN echo "127.0.0.1	localhost" > /etc/hosts
RUN echo "127.0.0.1	mycontainer" >> /etc/hosts

RUN addgroup --gid $GROUP_ID enhydris
RUN adduser --uid $USER_ID --gid $GROUP_ID --disabled-password --gecos "" enhydris
RUN usermod -G sudo enhydris
RUN sed -i 's/%sudo.*/%sudo	ALL=(ALL:ALL) NOPASSWD:ALL/' /etc/sudoers
WORKDIR /home/enhydris
USER enhydris

RUN virtualenv --python=/usr/bin/python3 --system-site-packages  /home/enhydris/venv
RUN /home/enhydris/venv/bin/pip install --upgrade pip==19.2.2
RUN /home/enhydris/venv/bin/pip install selenium
RUN /home/enhydris/venv/bin/pip install django-cors-headers
COPY enhydris/requirements.txt requirements-enhydris.txt
COPY enhydris/requirements-dev.txt requirements-enhydris-dev.txt
COPY enhydris-openhigis/requirements.txt requirements-enhydris-openhigis.txt
COPY enhydris-openhigis/requirements-dev.txt requirements-enhydris-openhigis-dev.txt
COPY enhydris-synoptic/requirements.txt requirements-enhydris-synoptic.txt
COPY enhydris-synoptic/requirements-dev.txt requirements-enhydris-synoptic-dev.txt
COPY enhydris-autoprocess/requirements.txt requirements-enhydris-autoprocess.txt
COPY enhydris-autoprocess/requirements-dev.txt requirements-enhydris-autoprocess-dev.txt
RUN /home/enhydris/venv/bin/pip install --no-cache-dir -r requirements-enhydris.txt
RUN /home/enhydris/venv/bin/pip install --no-cache-dir -r requirements-enhydris-openhigis.txt
RUN /home/enhydris/venv/bin/pip install --no-cache-dir -r requirements-enhydris-synoptic.txt
RUN /home/enhydris/venv/bin/pip install --no-cache-dir -r requirements-enhydris-autoprocess.txt
RUN /home/enhydris/venv/bin/pip install --no-cache-dir -r requirements-enhydris-dev.txt
RUN /home/enhydris/venv/bin/pip install --no-cache-dir -r requirements-enhydris-openhigis-dev.txt
RUN /home/enhydris/venv/bin/pip install --no-cache-dir -r requirements-enhydris-synoptic-dev.txt
RUN /home/enhydris/venv/bin/pip install --no-cache-dir -r requirements-enhydris-autoprocess-dev.txt
RUN /home/enhydris/venv/bin/pip install --no-cache-dir isort flake8 black pdbpp

RUN mkdir -p .vnc
COPY --chown=enhydris:enhydris xstartup .vnc/
RUN chmod a+x .vnc/xstartup
RUN touch .vnc/passwd
RUN /bin/bash -c "echo -e 'topsecret\ntopsecret\nn' | vncpasswd" > .vnc/passwd
RUN chmod 400 .vnc/passwd
RUN chmod go-rwx .vnc
RUN touch .Xauthority

# Copy shell scripts. If cloned on Windows, they might have CRLF line endings.
# We make sure they have Unix-style line endings, otherwise they can't execute.
COPY --chown=enhydris:enhydris start.sh /home/enhydris
COPY --chown=enhydris:enhydris bashrc /home/enhydris/.bashrc
RUN dos2unix /home/enhydris/start.sh /home/enhydris/.bashrc

CMD ["/home/enhydris/start.sh"]

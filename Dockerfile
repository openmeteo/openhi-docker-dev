FROM debian:buster-slim
ARG apt_proxy_line=''
RUN echo $apt_proxy_line >/etc/apt/apt.conf.d/02proxy
ADD VERSION .
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y upgrade \
    && apt-get install -y locales ca-certificates wget gnupg && apt-get clean
RUN sed -i 's/^# en_US.UTF-8 /en_US.UTF-8 /' /etc/locale.gen && locale-gen
ENV LC_CTYPE=en_US.UTF-8

RUN echo "deb https://packagecloud.io/timescale/timescaledb/debian buster main" \
    >/etc/apt/sources.list.d/timescaledb.list \
    && wget --quiet -O - https://packagecloud.io/timescale/timescaledb/gpgkey \
        | apt-key add - \
    && apt-get update

RUN apt-get install -y --no-install-recommends \
        git wget build-essential dos2unix less nano vim \
        virtualenv python3-virtualenv python3-pip python3-ipython \
        postgresql-postgis postgresql-postgis-scripts \
        timescaledb-postgresql-11 rabbitmq-server \
        python3-psycopg2 python3-gdal python3-pandas \
        python3-dev libjpeg-dev libfreetype6-dev \
        tmux \
    && apt-get clean

RUN echo "shared_preload_libraries = 'timescaledb'" \
    >>/etc/postgresql/11/main/postgresql.conf

WORKDIR /home/foo/

RUN virtualenv --python=/usr/bin/python3 --system-site-packages /home/foo/venv
COPY enhydris/requirements.txt requirements-enhydris.txt
COPY enhydris/requirements-dev.txt requirements-enhydris-dev.txt
COPY enhydris-openhigis/requirements.txt requirements-enhydris-openhigis.txt
COPY enhydris-openhigis/requirements-dev.txt requirements-enhydris-openhigis-dev.txt
COPY enhydris-synoptic/requirements.txt requirements-enhydris-synoptic.txt
COPY enhydris-synoptic/requirements-dev.txt requirements-enhydris-synoptic-dev.txt
COPY enhydris-autoprocess/requirements.txt requirements-enhydris-autoprocess.txt
COPY enhydris-autoprocess/requirements-dev.txt requirements-enhydris-autoprocess-dev.txt
RUN /home/foo/venv/bin/pip install --no-cache-dir -r requirements-enhydris.txt
RUN /home/foo/venv/bin/pip install --no-cache-dir -r requirements-enhydris-openhigis.txt
RUN /home/foo/venv/bin/pip install --no-cache-dir -r requirements-enhydris-synoptic.txt
RUN /home/foo/venv/bin/pip install --no-cache-dir -r requirements-enhydris-autoprocess.txt
RUN /home/foo/venv/bin/pip install --no-cache-dir -r requirements-enhydris-dev.txt
RUN /home/foo/venv/bin/pip install --no-cache-dir -r requirements-enhydris-openhigis-dev.txt
RUN /home/foo/venv/bin/pip install --no-cache-dir -r requirements-enhydris-synoptic-dev.txt
RUN /home/foo/venv/bin/pip install --no-cache-dir -r requirements-enhydris-autoprocess-dev.txt
RUN /home/foo/venv/bin/pip install --no-cache-dir isort flake8 black pdbpp

RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/11/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/11/main/postgresql.conf
EXPOSE 5432
EXPOSE 8000

# Copy shell scripts. If cloned on Windows, they might have CRLF line endings.
# We make sure they have Unix-style line endings, otherwise they can't execute.
ADD start.sh /home/foo
ADD bashrc /root/.bashrc
RUN dos2unix /home/foo/start.sh /root/.bashrc

CMD ["/home/foo/start.sh"]

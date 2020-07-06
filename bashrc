dbimport() {
    tar xzf /dbdump/dbdump.tar.gz -C /tmp || return

    mkdir -p /var/opt/enhydris/timeseries_data
    rm -f /var/opt/enhydris/timeseries_data/*
    mv /tmp/000000???? /var/opt/enhydris/timeseries_data

    for user in openmeteo anton mapserver; do
        sql="psql --command \"CREATE USER $user WITH SUPERUSER PASSWORD 'topsecret';\""
        su postgres -c "$sql" || true
    done
    su postgres -c "dropdb openmeteo" || true
    su postgres -c "createdb -O openmeteo openmeteo"
    su postgres -c 'psql -d openmeteo --command "CREATE EXTENSION IF NOT EXISTS postgis;"'
    su postgres -c 'psql -d openmeteo --command "\i /tmp/openmeteo.dump"'

    rm /tmp/openmeteo.dump
}

runtests() {
    find /opt/enhydris* -prune -name '*.py' -o -type d | xargs black --check --diff || return
    find /opt/enhydris* -prune -name '*.py' -o -type d | xargs flake8 --max-line-length=88 || return
    for dir in /opt/enhydris*; do
        ( cd $dir && find . -prune -name '*.py' -o -type d | xargs isort --check-only --diff ) || return
    done
    python /opt/enhydris/manage.py makemigrations --check || return
    python /opt/enhydris/manage.py test enhydris enhydris_openhigis enhydris_synoptic enhydris_autoprocess --failfast
}

runsynoptic() {
    python /opt/enhydris/manage.py shell -c 'from enhydris_synoptic.tasks import create_static_files; create_static_files()' || return
    echo "The files have been created in /tmp/enhydris-synoptic-root"
    echo "and are accessible at http://localhost:8001/synoptic"
}

runserver() {
    python /opt/enhydris/manage.py runserver 0.0.0.0:8000
}

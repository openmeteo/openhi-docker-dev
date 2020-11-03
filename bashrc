export PATH=/home/foo/venv/bin:$PATH
export PYTHONPATH=/opt/enhydris-openhigis:/opt/enhydris-synoptic:/opt/enhydris-autoprocess

dbimport() {
	tar xzf /dbdump/dbdump.tar.gz -C /tmp || return;
	for user in openmeteo anton mapserver;
	do
		sql="psql --command \"CREATE USER $user WITH SUPERUSER PASSWORD 'topsecret'\""
		su postgres -c "$sql" || true
	done;
	su postgres -c "dropdb openmeteo" || true
	su postgres -c "createdb -O openmeteo openmeteo"
	su postgres -c 'psql -d openmeteo' <<- EOF1
		CREATE EXTENSION IF NOT EXISTS postgis;
		CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;
	EOF1
	su postgres -c 'pg_restore -d openmeteo /tmp/openmeteo.dump';
	su postgres -c 'psql -d openmeteo' <<- EOF1
		CREATE TABLE enhydris_timeseriesrecord (
		    timeseries_id INTEGER NOT NULL,
		    "timestamp" TIMESTAMP WITH TIME ZONE NOT NULL,
		    value DOUBLE PRECISION NULL,
		    flags VARCHAR(237) NOT NULL
		);
		SELECT create_hypertable(
		    'enhydris_timeseriesrecord',
		    'timestamp',
		    chunk_time_interval => interval '1 year'
		);
		COPY enhydris_timeseriesrecord
			FROM '/tmp/openmeteo-timeseries-records.csv' CSV;
		ALTER TABLE enhydris_timeseriesrecord
			ADD CONSTRAINT enhydris_timeseriesrecord_pk
			PRIMARY KEY(timeseries_id, "timestamp");
		ALTER TABLE enhydris_timeseriesrecord
			ADD CONSTRAINT enhydris_timeseriesrecord_timeseries_fk
				FOREIGN KEY (timeseries_id)
				REFERENCES enhydris_timeseries(id)
				DEFERRABLE INITIALLY DEFERRED;
		CREATE INDEX enhydris_timeseriesrecord_timeseries_id_idx
			ON enhydris_timeseriesrecord(timeseries_id);
		CREATE INDEX enhydris_timeseriesrecord_timestamp_timeseries_id_idx
		ON enhydris_timeseriesrecord("timestamp", timeseries_id);
	EOF1
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
    echo "and are accessible at http://localhost:8001/synoptic/"
}

runserver() {
    python /opt/enhydris/manage.py runserver 0.0.0.0:8000
}

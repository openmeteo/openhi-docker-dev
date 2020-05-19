# flake8: NOQA
from celery.schedules import crontab

from . import *

DEBUG = True
ALLOWED_HOSTS = ["*"]
DATABASES = {
    "default": {
        "ENGINE": "django.contrib.gis.db.backends.postgis",
        "NAME": "openmeteo",
        "USER": "openmeteo",
        "PASSWORD": "topsecret",
        "HOST": "localhost",
        "PORT": 5432,
    }
}
ENHYDRIS_TIMESERIES_DATA_DIR = "/var/opt/enhydris/timeseries_data"
DATA_UPLOAD_MAX_NUMBER_FIELDS = 10000
ENHYDRIS_DISPLAY_COPYRIGHT_INFO = True
ENHYDRIS_USERS_CAN_ADD_CONTENT = True
ENHYDRIS_OPEN_CONTENT = True
LANGUAGE_CODE = "en"

INSTALLED_APPS.insert(0, "enhydris_openhigis")
ROOT_URLCONF = "enhydris_project.settings.urls"

INSTALLED_APPS.append("enhydris_synoptic")
ENHYDRIS_SYNOPTIC_ROOT = "/tmp/enhydris-synoptic-root"
ENHYDRIS_SYNOPTIC_URL = "/synoptic"
CELERYBEAT_SCHEDULE = {
    "do-synoptic": {
        "task": "enhydris_synoptic.tasks.create_static_files",
        "schedule": crontab(minute="2-52/10"),
    },
}

INSTALLED_APPS.append("enhydris_autoprocess")

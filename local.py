# flake8: NOQA
from celery.schedules import crontab
from selenium import webdriver
from selenium.webdriver.chrome.options import Options as ChromeOptions

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
MEDIA_ROOT = "/var/opt/enhydris/openmeteo/media"
MEDIA_URL = "/media/"
DATA_UPLOAD_MAX_NUMBER_FIELDS = 10000
ENHYDRIS_DISPLAY_COPYRIGHT_INFO = True
ENHYDRIS_USERS_CAN_ADD_CONTENT = True
ENHYDRIS_OPEN_CONTENT = True
LANGUAGE_CODE = "en"

CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.filebased.FileBasedCache',
        'LOCATION': '/var/cache/enhydris/django_cache',
    },
}

INSTALLED_APPS.append("corsheaders")
MIDDLEWARE.insert(2, "corsheaders.middleware.CorsMiddleware")
CORS_ALLOW_ALL_ORIGINS = True

INSTALLED_APPS.insert(0, "enhydris_openhigis")
ROOT_URLCONF = "enhydris_project.settings.urls"
ENHYDRIS_OWS_URL = (
    "http://localhost:8001/cgi-bin/mapserv?map=/opt/enhydris-openhigis/mapserver/"
)
MIDDLEWARE.append("enhydris_openhigis.middleware.OpenHiGISMiddleware")

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

chrome_options = ChromeOptions()
chrome_options.add_argument("--headless")
chrome_options.add_argument("--disable-gpu")
chrome_options.add_argument("--no-sandbox")
chrome_options.add_argument("--disable-dev-shm-usage")
SELENIUM_WEBDRIVERS = {
    "default": {
        "callable": webdriver.Chrome,
        "args": [],
        "kwargs": {"options": chrome_options},
    },
}

from django.conf.urls.static import static
from django.urls import include, path

from enhydris import urls as enhydris_urls

from enhydris_openhigis import urls as enhydris_openhigis_urls  # isort:skip

urlpatterns = [
    path("openhigis/", include(enhydris_openhigis_urls)),
    path("", include(enhydris_urls)),
] + static("/synoptic/", document_root="/tmp/enhydris-synoptic-root", show_indexes=True)

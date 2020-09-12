from django.conf.urls import url
from django.conf.urls.static import static
from django.contrib import admin
from .views import Index
from sigeagro.settings import MEDIA_URL, MEDIA_ROOT

urlpatterns = [
    url(r'^$', Index, name="graficos_index"),
] + static(MEDIA_URL, document_root=MEDIA_ROOT)
from django.contrib import admin
from .models import Granja, Corral, Proveedor, Lote_Animal

admin.site.register(Granja)
admin.site.register(Corral)
admin.site.register(Proveedor)
admin.site.register(Lote_Animal)

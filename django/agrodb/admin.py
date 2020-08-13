from django.contrib import admin
from .models import Granja, Corral, Proveedor, Lote_Animal, Clasificacion_Huevo, Huevos, Jornada_Recoleccion

admin.site.register(Granja)
admin.site.register(Corral)
admin.site.register(Proveedor)
admin.site.register(Lote_Animal)
admin.site.register(Clasificacion_Huevo)
admin.site.register(Huevos)
admin.site.register(Jornada_Recoleccion)

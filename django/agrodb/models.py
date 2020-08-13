from django.db import models
from django.contrib.auth.models import User
from django.urls import reverse
from django.utils.translation import ugettext_lazy as _

import uuid

class Granja(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    nombre = models.CharField(max_length=100)
    creado_por = models.ForeignKey(User, on_delete=models.CASCADE)
    fecha_creacion = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = _("Granja")
        verbose_name_plural = _("Granjas")

    def __str__(self):
        return self.nombre

class Corral(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    nombre = models.CharField(max_length=100)
    capacidad = models.IntegerField(default=0)
    granja = models.ForeignKey(Granja, on_delete=models.CASCADE, null=True)
    creado_por = models.ForeignKey(User, on_delete=models.CASCADE)
    fecha_creacion = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = _("Corral")
        verbose_name_plural = _("Corrales")

    def __str__(self):
        return self.nombre

class Proveedor(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    nombre = models.CharField(max_length=100, null=False)
    descripcion = models.CharField(max_length=255, null=True)
    creado_por = models.ForeignKey(User, on_delete=models.CASCADE)
    fecha_creacion = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = _("Proveedor")
        verbose_name_plural = _("Proveedores")

    def __str__(self):
        return self.nombre

class Clasificacion_Huevo(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    nombre = models.CharField(max_length=100)
    descripcion = models.TextField(verbose_name="Descripción", null=True)
    creado_por = models.ForeignKey(User, on_delete=models.CASCADE)
    fecha_creacion = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = _("Clasificacion de Huevos")
        verbose_name_plural = _("Clasificaciones de Huevos")

    def __str__(self):
        return self.nombre

class Huevos(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    cantidad = models.IntegerField(default=0)
    clasificacion = models.ForeignKey(Clasificacion_Huevo, on_delete=models.CASCADE)
    creado_por = models.ForeignKey(User, on_delete=models.CASCADE)
    fecha_creacion = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = _("Huevo")
        verbose_name_plural = _("Huevos")

    def __str__(self):
        return "%i Huevos - %s" % (self.cantidad, self.clasificacion.nombre)

class Lote_Animal(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    nombre = models.CharField(max_length=100, null=False, unique=True)
    tipo = models.CharField(max_length=25, null=True)
    genetica = models.CharField(max_length=100, null=True)
    fecha_nacimiento = models.DateTimeField(auto_now=False, blank=True, null=True)
    fecha_ingreso = models.DateTimeField(auto_now=False, blank=True, null=True)
    fecha_inicio_produccion = models.DateTimeField(auto_now=False, blank=True, null=True)
    fecha_fin_produccion = models.DateTimeField(auto_now=False, blank=True, null=True)
    cantidad = models.IntegerField()
    proveedor = models.ForeignKey(Proveedor, on_delete=models.CASCADE, null=True)
    corral = models.ForeignKey(Corral, on_delete=models.CASCADE, null=True)
    creado_por = models.ForeignKey(User, on_delete=models.CASCADE)
    fecha_creacion = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = _("Lote de Animales")
        verbose_name_plural = _("Lotes de Animales")

    def __str__(self):
        return self.nombre

class Jornada_Recoleccion(models.Model):
    MANANA = "MN"
    MEDIODIA = "MD"
    TARDE = "TD"
    MOMENTO_JORNADA_CH = [
        (MANANA, "Mañana"),
        (MEDIODIA, "Mediodía"),
        (TARDE, "Tarde")
    ]
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    fecha_jornada = models.DateField(null=False)
    momento_jornada = models.CharField(max_length=2, choices=MOMENTO_JORNADA_CH, default=MANANA,)
    lote_animal = models.ForeignKey(Lote_Animal, on_delete=models.CASCADE)
    huevos = models.ManyToManyField(Huevos, related_name="huevos")
    creado_por = models.ForeignKey(User, on_delete=models.CASCADE)
    fecha_creacion = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = _("Jornada de Recolección")
        verbose_name_plural = _("Jornadas de Recolección")

    def __str__(self):
        return "Jornada de %s - %s" % (self.fecha_jornada, self.momento_jornada)

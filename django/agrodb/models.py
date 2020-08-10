from django.db import models
from django.contrib.auth.models import User
from django.urls import reverse
from django.utils.translation import ugettext_lazy as _

import uuid

class Granja(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    nombre = models.CharField(max_length=100)

class Corral(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    nombre = models.CharField(max_length=100)
    capacidad = models.IntegerField()
    granja = models.ForeignKey(Granja, on_delete=models.CASCADE, null=True)

class Proveedor(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    nombre = models.CharField(max_length=100, null=False)
    descripcion = models.CharField(max_length=255, null=True)
    creado_por = models.ForeignKey(User, on_delete=models.CASCADE)
    crado_en = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = _("Proveedor")
        verbose_name_plural = _("Proveedores")

    def __str__(self):
        return self.nombre

    def get_absolute_url(self):
        return reverse("Proveedor_detail", kwargs={"pk": self.pk})
        

class Lote_Animal(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    nombre = models.CharField(max_length=100, null=False, unique=True)
    tipo = models.CharField(max_length=25, null=True)
    genetica = models.CharField(max_length=100, null=True)
    fecha_nacimiento = models.DateTimeField(auto_now=True)
    fecha_ingreso = models.DateTimeField(auto_now=True, blank=True, null=True)
    fecha_inicio_produccion = models.DateTimeField(auto_now=False, blank=True, null=True)
    fecha_fin_produccion = models.DateTimeField(auto_now=False, blank=True, null=True)
    cantidad = models.IntegerField()
    proveedor = models.ForeignKey(Proveedor, on_delete=models.CASCADE, null=True)
    corral = models.ForeignKey(Proveedor, on_delete=models.CASCADE, null=True)
    creado_por = models.ForeignKey(User, on_delete=models.CASCADE)
    crado_en = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = _("Animal")
        verbose_name_plural = _("Animales")

    def __str__(self):
        return self.nombre

    def get_absolute_url(self):
        return reverse("Animal_detail", kwargs={"pk": self.pk})
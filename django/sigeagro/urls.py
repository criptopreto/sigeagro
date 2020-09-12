"""sigeagro URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from principal.views import Index

urlpatterns = [
    path('', Index, name='index'),
    path('admin/', admin.site.urls),
    path('principal/', include(('principal.urls', 'principal'), namespace='principal')),
    path('procesos/', include(('procesos.urls', 'procesos'), namespace='procesos')),
    path('inventario/', include(('inventario.urls', 'inventario'), namespace='inventario')),
    path('proveedores/', include(('proveedores.urls', 'proveedores'), namespace='proveedores')),
    path('clientes/', include(('clientes.urls', 'clientes'), namespace='clientes')),
    path('graficos/', include(('graficos.urls', 'graficos'), namespace='graficos')),
    path('accounts/', include('django.contrib.auth.urls')),
]

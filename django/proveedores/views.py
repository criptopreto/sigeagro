from django.shortcuts import render
from django.contrib.auth.decorators import login_required

@login_required
def Index(req):
    return render(req, "proveedores/index.html")
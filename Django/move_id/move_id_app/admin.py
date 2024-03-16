from django.contrib import admin
from .models import Patiente,Nurse,Alert


admin.site.register(Patiente)
admin.site.register(Nurse)
admin.site.register(Alert)
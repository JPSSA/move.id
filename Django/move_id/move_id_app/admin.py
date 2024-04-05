from django.contrib import admin
from .models import Patient
from .models import SensorData

admin.site.register(Patient)
admin.site.register(SensorData)


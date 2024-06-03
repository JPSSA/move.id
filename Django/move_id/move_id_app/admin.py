from django.contrib import admin
from .models import Patient, SensorData, Sensor, Classifier, Dataset, UserSensor, Location, SensorDataClassification

admin.site.register(Patient)
admin.site.register(Location)
admin.site.register(Sensor)
admin.site.register(UserSensor)



admin.site.site_header = "MoveID Admin"

admin.site.site_title = "MoveID Admin"

admin.site.index_title = "Welcome to MoveID Admin Portal"



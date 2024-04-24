from django.contrib import admin
from .models import Patient
from .models import SensorData
from .models import Sensor
from .models import Classifier
from .models import Dataset
from .models import UserSensor
from .models import Location

admin.site.register(Patient)
admin.site.register(SensorData)
admin.site.register(Location)
admin.site.register(Sensor)
admin.site.register(UserSensor)
admin.site.register(Classifier)
admin.site.register(Dataset)




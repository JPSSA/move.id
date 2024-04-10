from django.contrib import admin
from .models import Patient
from .models import SensorData
from .models import PatientSensor
from .models import Classifier
from .models import DatasetAttributes
from .models import Dataset
from .models import UserSensor

admin.site.register(Patient)
admin.site.register(SensorData)
admin.site.register(PatientSensor)
admin.site.register(Classifier)
admin.site.register(DatasetAttributes)
admin.site.register(Dataset)
admin.site.register(UserSensor)



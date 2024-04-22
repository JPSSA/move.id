from django.db import models
import uuid
from django.contrib.auth.models import User


class Patient(models.Model):
    nif = models.IntegerField(primary_key=True,default=0)
    first_name = models.CharField(max_length = 50)
    last_name = models.CharField(max_length = 50)
    room = models.CharField(max_length = 50)
    bed = models.CharField(max_length = 50)
    
class SensorData(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    datetime = models.DateTimeField()
    topic_id = models.CharField(max_length=255)
    message = models.CharField()
    read = models.BooleanField()
    
    class Meta:
        db_table = 'sensor_data'
    
    
class PatientSensor(models.Model):
    idSensor = models.CharField(primary_key=True, max_length=50)
    nif = models.ForeignKey(Patient, on_delete=models.CASCADE)

    class Meta:
        db_table = 'patient_sensor'

class UserSensor(models.Model):
    user = models.ForeignKey(User,on_delete=models.CASCADE)
    idSensor = models.ForeignKey(PatientSensor, on_delete=models.CASCADE)
    location = models.CharField(max_length=255)

    class Meta:
        db_table = 'user_sensor'

class Classifier(models.Model):
    name = models.CharField(primary_key=True, max_length=255)
    path = models.CharField(max_length=255)
    score = models.FloatField(max_length=10)

class DatasetAttributes(models.Model):
    atr = models.CharField(primary_key=True, max_length=255)

    class Meta:
        db_table = 'dataset_attributes'

class Dataset(models.Model):
    path = models.CharField(primary_key=True, max_length=255)
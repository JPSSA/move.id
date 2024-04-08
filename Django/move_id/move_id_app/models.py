from django.db import models
from django.contrib.auth.models import User


class Patient(models.Model):
    nif = models.IntegerField(primary_key=True,default=0)
    fname = models.CharField(max_length = 50)
    lname = models.CharField(max_length = 50)
    
class SensorData(models.Model):
    datetime = models.DateTimeField(primary_key = True)
    topic_id = models.CharField(max_length=255)
    gyroscopeX = models.FloatField(null=True)
    gyroscopeY = models.FloatField(null=True)
    gyroscopeZ = models.FloatField(null=True)
    accelerometerX = models.FloatField(null=True)
    accelerometerY = models.FloatField(null=True)
    accelerometerZ = models.FloatField(null=True)
    
class PatientSensor(models.Model):
    idSensor = models.CharField(primary_key=True, max_length=50)
    nif = models.ForeignKey(Patient, on_delete=models.CASCADE)

class UserSensor(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    idSensor = models.ForeignKey(PatientSensor, on_delete=models.CASCADE)
    location = models.CharField(max_length=255)

class Classifier(models.Model):
    name = models.CharField(primary_key=True, max_length=255)
    path = models.CharField(max_length=255)
    score = models.FloatField(max_length=10)

class DatasetAttributes(models.Model):
    atr = models.CharField(primary_key=True, max_length=255)

class Dataset(models.Model):
    path = models.CharField(primary_key=True, max_length=255)
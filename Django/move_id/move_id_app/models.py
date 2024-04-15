from django.db import models
import uuid
from django.contrib.auth.models import User


class Patient(models.Model):
    nif = models.IntegerField(primary_key=True,default=0)
    fname = models.CharField(max_length = 50)
    lname = models.CharField(max_length = 50)
    
class SensorData(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    datetime = models.DateTimeField()
    topic_id = models.CharField(max_length=255)
    message = models.CharField()
    
    
class PatientSensor(models.Model):
    idSensor = models.CharField(primary_key=True, max_length=50)
    nif = models.ForeignKey(Patient, on_delete=models.CASCADE)

class UserSensor(models.Model):
    user = models.ForeignKey(User,on_delete=models.CASCADE)
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
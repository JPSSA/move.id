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

class Location(models.Model):
    name = models.CharField(max_length=255)
    
class Sensor(models.Model):
    id_sensor = models.CharField(primary_key=True, max_length=50)
    patient = models.ForeignKey(Patient, on_delete=models.CASCADE)
    location = models.ForeignKey(Location, on_delete=models.CASCADE)


class UserSensor(models.Model):
    user = models.ForeignKey(User,on_delete=models.CASCADE)
    sensor = models.ForeignKey(Sensor, on_delete=models.CASCADE)

    class Meta:
        db_table = 'user_sensor'

class Classifier(models.Model):
    name   = models.CharField(primary_key=True, max_length=255)
    path   = models.CharField(max_length=255)
    score  = models.FloatField(max_length=10)
    params = models.CharField()
    module = models.CharField(max_length=255)


class Dataset(models.Model):
    path = models.CharField(primary_key=True, max_length=255)

class SensorDataClassification(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    datetime = models.DateTimeField()
    message = models.CharField()
    classification = models.BooleanField(default=None, null=True)
    user = models.ForeignKey(User,on_delete=models.CASCADE)
    sensor = models.ForeignKey(Sensor,on_delete=models.CASCADE)
    
    class Meta:
        db_table = 'sensor_data_classification'





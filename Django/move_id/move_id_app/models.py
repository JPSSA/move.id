from django.db import models
from django.contrib.auth.models import User


class Patient(models.Model):
    fname = models.CharField(max_length = 50)
    lname = models.CharField(max_length = 50)
    assigned_nurse = models.ForeignKey(User,on_delete = models.CASCADE)


class SensorData(models.Model):
    datetime = models.DateTimeField(primary_key = True)
    topic_id = models.CharField(max_length=255)
    gyroscopeX = models.FloatField(null=True)
    gyroscopeY = models.FloatField(null=True)
    gyroscopeZ = models.FloatField(null=True)
    accelerometerX = models.FloatField(null=True)
    accelerometerY = models.FloatField(null=True)
    accelerometerZ = models.FloatField(null=True)
    


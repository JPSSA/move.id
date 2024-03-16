from django.db import models

class Nurse(models.Model):
    fname = models.CharField(max_length = 50)
    lname = models.CharField(max_length = 100)
    email = models.EmailField(max_length = 100)
    device_token = models.CharField(max_length = 200)

class Patiente(models.Model):
    fname = models.CharField(max_length = 50)
    lname = models.CharField(max_length = 100)
    age = models.IntegerField()
    gender = models.CharField(max_length = 30)

class Alert(models.Model):
    patiente = models.ForeignKey(Patiente, on_delete = models.CASCADE)
    nurse = models.ForeignKey(Nurse, on_delete = models.CASCADE)
    timestamp = models.DateTimeField(auto_now_add = True)
    message = models.CharField(max_length = 200)
    handled = models.BooleanField(default = False)



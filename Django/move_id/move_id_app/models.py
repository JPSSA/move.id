from django.db import models
from django.contrib.auth.models import User


class Patient(models.Model):
    fname = models.CharField(max_length = 50)
    lname = models.CharField(max_length = 50)
    assigned_nurse = models.ForeignKey(User,on_delete = models.CASCADE)

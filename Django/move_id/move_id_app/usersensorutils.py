from .models import UserSensor

def get_user_sensor_count_by_id_sensor(id_sensor):
    return UserSensor.objects.filter(idSensor=id_sensor).count()

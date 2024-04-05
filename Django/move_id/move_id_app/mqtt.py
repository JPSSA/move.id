import paho.mqtt.client as mqtt
from django.conf import settings
from .models import SensorData
import json
from datetime import datetime

subscribed_topics = []

# MQTT client configuration
client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION1)

def on_connect(mqtt_client, userdata, flags, rc):
  
    if rc == 0:
        print('Connected successfully')
        mqtt_client.subscribe('move_id/1234')  
    else:
        print('Bad connection. Code:', rc)
   

def on_message(mqtt_client, userdata, msg):
    appendData(msg)
    
    if count_rows_with_topic_id(msg.topic) >= 120:
        delete_oldest_sensor_data(msg.topic)
    
def appendData(msg):
    data = json.loads(msg.payload)
    
    gyroscope = data.get('gyroscopeSensor', {})
    accelerometer = data.get('accelerometerSensor', {})

    if gyroscope and accelerometer:
        gyroscope_x = float(gyroscope['x'])
        gyroscope_y = float(gyroscope['y'])
        gyroscope_z = float(gyroscope['z'])
        accelerometer_x = float(accelerometer['x'])
        accelerometer_y = float(accelerometer['y'])
        accelerometer_z = float(accelerometer['z'])

        sensor_data_instance = SensorData.objects.create(
            datetime = datetime.now(),
            topic_id = msg.topic,
            gyroscopeX = gyroscope_x,
            gyroscopeY = gyroscope_y,
            gyroscopeZ = gyroscope_z,
            accelerometerX = accelerometer_x,
            accelerometerY = accelerometer_y,
            accelerometerZ = accelerometer_z
        )
        print("Sensor Data saved!!")
    else:
        print("Missing Gyroscope and Accelerometer Data")


def count_rows_with_topic_id(topic_id):
    count = SensorData.objects.filter(topic_id=topic_id).count()
    return count

def delete_oldest_sensor_data(topic_id):
    try:
        oldest_sensor_data = SensorData.objects.filter(topic_id=topic_id).order_by('datetime').first()
        if oldest_sensor_data:
            oldest_sensor_data.delete()
            print(f"Oldest SensorData record with topic_id {topic_id} deleted successfully.")
        else:
            print(f"No SensorData records found with topic_id {topic_id}.")

    except Exception as e:
         print("Error occurred while deleting oldest SensorData record:", e)

# Set callback functions
client.on_connect = on_connect
client.on_message = on_message
client.username_pw_set(settings.MQTT_USER, settings.MQTT_PASSWORD)

# Connect to the MQTT broker
client.connect(
    host=settings.MQTT_SERVER,
    port=settings.MQTT_PORT,
    keepalive=settings.MQTT_KEEPALIVE
)

# Start the MQTT client loop
# here or in __ini__.py
client.loop_start()

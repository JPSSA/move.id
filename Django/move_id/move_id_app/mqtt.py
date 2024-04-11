import paho.mqtt.client as mqtt # type: ignore
from django.conf import settings
from .sensordatautils import appendData
from .sensordatautils import count_rows_with_topic_id
from .sensordatautils import delete_oldest_sensor_data
from .sensordatautils import get_sensor_data_as_dataframe
from .anomaly_detector import AnomalyDetector


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
    print(msg)
    #appendData(msg)
    #if count_rows_with_topic_id(msg.topic) >= 120:
    #    delete_oldest_sensor_data(msg.topic)
    
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

df = get_sensor_data_as_dataframe('move_id/1234')

anomalyClassifier = AnomalyDetector('LevelShift')
print('ANOMALYDETECTOR')
print(anomalyClassifier.get_anomalies_dates(df))


#print('DATAFRAME :')
#print(get_sensor_data_as_dataframe('move_id/1234'))

# Start the MQTT client loop
# here or in __ini__.py
client.loop_start()

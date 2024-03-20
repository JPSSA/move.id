import paho.mqtt.client as mqtt
from django.conf import settings

subscribed_to_topic = False


# MQTT client configuration
client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION1)

def on_connect(mqtt_client, userdata, flags, rc):
     
    if rc == 0:
        print('Connected successfully')
        # Check if not already subscribed to the topic
        if not subscribed_to_topic:
            mqtt_client.subscribe('django/move_id_test')
            subscribed_to_topic = True  # Update the flag to indicate subscription
        else:
            print('Already subscribed to the topic')
    else:
        print('Bad connection. Code:', rc)
   

def on_message(mqtt_client, userdata, msg):
    print(f'Received message on topic: {msg.topic} with payload: {msg.payload}')

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
client.loop_start()

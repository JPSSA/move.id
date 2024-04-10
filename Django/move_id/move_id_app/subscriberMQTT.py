from paho.mqtt import client as mqtt_client
import sensordatautils
import json
import os

class subscriberMQTT:
    def __init__(self, topic, ip, port=1883):
        self.broker = ip
        self.port = port
        self.topic = topic
        self.client_id = ''
        self.received_data = []  # Initialize an empty dictionary to store received data
        self.start_time = 0
        
        

    def connect_mqtt(self) -> mqtt_client:
        def on_connect(client, userdata, flags, rc):
            if rc == 0:
                print("Connected to MQTT Broker!")
            else:
                print("Failed to connect, return code %d\n", rc)
    
        client = mqtt_client.Client( self.client_id)
        # client.username_pw_set(username, password)
        client.on_connect = on_connect
        client.connect(self.broker, self.port)
        return client


    def subscribe(self,client: mqtt_client):
        def on_message(client, userdata, msg):
            if count_rows_with_topic_id(msg.topic) >= 120:
                delete_oldest_sensor_data(msg.topic)
            sensordatautils.appendData(msg)
            
        client.subscribe(self.topic)
        client.on_message = on_message


    def stop(self):
        self.client.loop_stop()
    
    def run(self):
        self.client = self.connect_mqtt()
        self.subscribe(self.client)
        self.client.loop_start()
        
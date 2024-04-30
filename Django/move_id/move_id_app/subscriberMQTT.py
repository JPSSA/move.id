from paho.mqtt import client as mqtt_client
from .votingClassifier import VotingClassifier
from move_id_app.models import Classifier, Dataset, UserSensor, SensorData, Patient, Location
from django.contrib.auth.models import User
import move_id_app.preprocessing as preprocessing
from .sensordatautils import appendData, count_rows_with_topic_id, delete_oldest_sensor_data
import json
import os
import threading
import pickle
import time

class subscriberMQTT:
    def __init__(self, location, topic_id, ip, port=1883):
        self.broker = ip
        self.port = port
        self.location = location
        self.id = topic_id
        self.client_id = ''
        self.received_data = []  # Initialize an empty dictionary to store received data
        self.start_time = 0
        self.voting = VotingClassifier()
        self.user = UserSensor.objects.filter(id_sensor=self.id).first()
        self.location = Location.objects.filter(id=self.location).first()
        
    

    def connect_mqtt(self) -> mqtt_client:
        def on_connect(client, userdata, flags, rc):
            if rc == 0:
                print("Connected to MQTT Broker!")
            else:
                print("Failed to connect, return code %d\n", rc)
    
        client = mqtt_client.Client(self.client_id)
        # client.username_pw_set(username, password)
        client.on_connect = on_connect
        client.connect(self.broker, self.port)
        return client


    def subscribe(self,client: mqtt_client):
        def on_message(client, userdata, msg):
            if count_rows_with_topic_id(msg.topic) >= 120:
                delete_oldest_sensor_data(msg.topic)
            appendData(msg)

            array_data = self.getData()

            if array_data:
                for data in array_data:
                    if data:
                        classification_thread = threading.Thread(target=self.classify_unread_messages, args=(data,))
                        classification_thread.start()

                    


            
        client.subscribe('moveID/subscriber/'+ str(self.location) + '/' + str(self.id))
        client.on_message = on_message

    

    def stop(self):
        self.client.loop_stop()

    def publish(self, client):
        msg_count = 1
        while True:
            time.sleep(1)
            msg = f"messages: {msg_count}"
            

            payload = {
                "patient_fname": self.user.patient.first_name,
                "patient_lname": self.user.patient.last_name,
                "alert": "Patient is moving, Room:" + self.user.patient.room + ", Bed:"+ self.user.patient.bed,
                "location": self.location.name
            }
            # Convert payload to JSON string
            payload_str = json.dumps(payload)
            result = client.publish('moveID/notification/' + str(self.location) + '/' + str(self.id), payload_str)
            status = result[0]
            if status == 0:
                print(f"Send `{msg}` to topic Notification")
            else:
                print(f"Failed to send message to topic Notification")
            msg_count += 1
            if msg_count > 5:
                break
    

    def getData(self):

        array = []

        instances = Dataset.objects.all() # Retrieve all rows where name is "John"
        path = instances[0].path

        dat=pickle.load(open(path,'rb'))
        #window = dat['len_window']
        window = 6

        number_messages = SensorData.objects.count()

        if(number_messages < 120):
            SensorData.objects.all().update(read=True)
            return

        unread_messages = SensorData.objects.filter(topic_id='moveID/subscriber/' + str(self.location) + '/' + str(self.id), read=False).order_by('-datetime')


        previous_messages = SensorData.objects.filter(
                topic_id=unread_messages[-1].topic_id,
                datetime__lt=unread_messages[-1].datetime,
            ).order_by('-datetime')[:window-1]

        messages = unread_messages + previous_messages

        for indice, message in enumerate(messages):
            if(indice <= len(messages) - window):
                array.append(messages[indice:indice+window])

                
        """for message in unread_messages:
            
            

            previous_messages = SensorData.objects.filter(
                topic_id=message.topic_id,
                datetime__lt=message.datetime,
            ).exclude(
                id=message.id
            ).order_by('-datetime')[:window-1]

            # Adiciona as mensagens anteriores à lista
            for prev_message in previous_messages:
                temp.append(prev_message.message)

            # Adiciona a mensagem não lida atual à lista
            temp.append(message.message)

            array.append(temp)"""

    
        return array

    def classify(self, data):
        calculated = preprocessing.calculate_statistics(data)
        matrix = preprocessing.to_matrix([calculated])

        return self.voting.predict(matrix,  self.location, self.id)

    def classify_unread_messages(self, data):
        if self.classify(data):
            self.publish(self.client)
    
    def run(self):
        self.client = self.connect_mqtt()
        self.subscribe(self.client)
        self.client.loop_start()
        
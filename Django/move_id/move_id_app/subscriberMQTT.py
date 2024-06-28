from paho.mqtt import client as mqtt_client
from .votingClassifier import VotingClassifier
from move_id_app.models import Classifier, Dataset, UserSensor, SensorData, Patient, Location, Sensor, SensorDataClassification
from django.contrib.auth.models import User
from .sensordatautils import appendData, count_rows_with_topic_id, delete_oldest_sensor_data
import json
import os
import threading
import pickle
import time
import numpy as np
import pytz
from datetime import datetime
import threading
from concurrent.futures import ThreadPoolExecutor

class subscriberMQTT:
    def __init__(self, preprocessing, email, location, id, ip, port=1883):
        """
        Initializes the subscriberMQTT class with:
        - location - location id where the sensor is located
        - topic_id - sensor id
        - ip - ip where the MQTT broker is located
        - port - port where the MQTT broker is located.

        Also sets up necessary attributes like:
        - voting - class responsible for voting for the classifiers.
        - sensor - instance of the Sensor model with the respetive sensor id given 
        - location - instance of the Location model with the respetive location id given
        """
        self.broker = ip
        self.port = port
        self.id = id
        self.preprocessing = preprocessing
        self.client_id = 'admin'
        self.received_data = [] 
        self.start_time = 0
        self.voting = VotingClassifier()
        self.sensor = Sensor.objects.filter(id_sensor = self.id).first()
        self.location = Location.objects.filter(id=location).first()
        self.executor = ThreadPoolExecutor(max_workers=4)
        
    

    def connect_mqtt(self) -> mqtt_client:
        """
        Connects to the MQTT broker and returns the client object.
        Defines the on_connect callback to handle connection status.
        """
        def on_connect(client, userdata, flags, rc):
            if rc == 0:
                print("Connected to MQTT Broker!")
            else:
                print("Failed to connect, return code %d\n", rc)
    
        client = mqtt_client.Client(self.client_id)
        client.on_connect = on_connect
        client.connect(self.broker, self.port)
        return client


    def subscribe(self,client: mqtt_client):
        """
        Subscribes to the MQTT topic for the sensor and location.
        Defines the on_message callback to handle incoming messages.
        """
        def on_message(client, userdata, msg):
            """
            Handles incoming messages. Checks the number of rows for the topic,
            deletes the oldest data if necessary, appends new data, and starts a thread
            for classifying unread messages.
            """

            if(msg.payload.decode() != {}):
                if count_rows_with_topic_id(msg.topic) >= 120:
                    delete_oldest_sensor_data(msg.topic)
                appendData(msg)

                array_data = self.getData()

                if array_data:
                    for data in array_data:
                        if len(data) != 0:
                            print("Entrou")
                            self.executor.submit(self.classify_unread_messages, data, msg)

                    


        print('moveID/subscriber/'+ str(self.location.id) + '/' + str(self.id))
        client.subscribe('moveID/subscriber/'+ str(self.location.id) + '/' + str(self.id))
        client.on_message = on_message

    

    def stop(self):
        """
        Stops the MQTT client loop.
        """
        self.client.loop_stop()

    def publish(self, client):
        """
        Publishes a notification message to the MQTT topic if a certain condition is met.
        Contains patient and location information in the payload.
        """
        msg_count = 1
        sensor_id = self.sensor.patient.id
        fname = self.sensor.patient.first_name
        lname = self.sensor.patient.last_name
        room =self.sensor.patient.room
        bed = self.sensor.patient.bed
        location_name = self.location.name
        location_id = self.location.id

        while True:
            time.sleep(1)
            msg = f"messages: {msg_count}"
            

            payload = {
                "sensor_id": sensor_id,
                "patient_fname": fname,
                "patient_lname": lname,
                "alert": "Patient is moving, Room:" + room + ", Bed:"+ bed,
                "location": location_name,
                "location_id": location_id
            }
            # Convert payload to JSON string
            payload_str = json.dumps(payload)
            result = client.publish('moveID/notification/' + str(self.location.id) + '/' + str(self.id), payload_str)
            status = result[0]
            if status == 0:
                print(f"Send `{msg}` to topic Notification")
            else:
                print(f"Failed to send message to topic Notification")
            msg_count += 1
            if msg_count > 5:
                break
    

    def getData(self):
        """
        Retrieves and processes unread messages from the database.
        Forms an array of message windows for classification.
        """

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

        unread_messages = SensorData.objects.filter(topic_id='moveID/subscriber/' + str(self.location.id) + '/' + str(self.id), read=False).order_by('-datetime')


        previous_messages = SensorData.objects.filter(
                topic_id=unread_messages[len(unread_messages)-1].topic_id,
                datetime__lt=unread_messages[len(unread_messages)-1].datetime,
            ).order_by('-datetime')[:window-1]

        messages = np.concatenate((unread_messages,previous_messages))

        for indice, message in enumerate(messages):
            if(indice <= len(messages) - window):
                array.append(messages[indice:indice+window])

                
    
        return array

    def classify(self, data):
        """
        Classifies the given data using the voting classifier.
        """
        
        matrix = self.preprocessing.fit(data)

        return self.voting.predict(matrix,  self.location.id, self.id)

    def classify_unread_messages(self, data):
        """
        Classifies unread messages. If classification is positive, saves the data, in
        a table for later classification, and calls the function to publish a notification.
        """
        if self.classify(data):
            
            instances = UserSensor.objects.filter(sensor=self.sensor)

            for instance in instances:

                data_classif = SensorDataClassification(datetime = datetime.now(pytz.UTC), message=data, user = instance.user, sensor = self.sensor)
                data_classif.save()

            self.publish(self.client)
    
    def run(self):
        """
        Runs the MQTT client by connecting to the broker, subscribing to the topic,
        and starting the client loop.
        """
        self.client = self.connect_mqtt()
        self.subscribe(self.client)
        self.client.loop_start()
        
from move_id_app.models import Classifier, Dataset, DatasetAttributes, UserSensor, SensorData
from .votingClassifier import VotingClassifier
from .subscriberMQTT import subscriberMQTT
from paho.mqtt import client as mqtt_client
import pickle
import json
import os
import csv
import move_id_app.preprocessing

class Notifier:
    '''
    Implementa todo o processo desde a subscrição a tópicos até ao processamento
    de dados e envio de notificações para os respetivos canais.

    Argumentos:
    - "ip", do servidor MQTT
    - "port", do servidor MQTT
    '''

    def __init__(self, ip, port=1883):
        self.voting = VotingClassifier()
        self.subs = []
        self.ip = ip
        self.port = port

    def new_dataset(self, path):
        #Delete the existing dataset path saved on the database
        Dataset.objects.all().delete()

        #Add the new dataset path
        new_instance = Dataset(path=path)
        new_instance.save()

        #Delete the existing data that the dataset requires
        DatasetAttributes.objects.all().delete()

        #Open that dataset
        dset=pickle.load(open(path,'rb'))

        #Get the data names that is required to work with this new dataset
        data_used = dset['data_used']

        for data in data_used:
            #Add each one to the data required table
            new_instance = DatasetAttributes(atr=data)
            new_instance.save()


        
    def add_classifier(self, classifier, parameters):
        instances = Dataset.objects.all() # Retrieve all rows where name is "John"

        path = instances[0].path

        dataset=pickle.load(open(path,'rb'))
        X = dataset['X']
        y = dataset['y']

        self.voting(classifier,parameters, X, y)
    
    
    def add_subscriber(self, idSensor, email, location):
        self.stopListening()
        # Create an instance of MyModel
        new_instance = UserSensor(idSensor=idSensor, email=email, location=location)

        # Save the instance to the database
        new_instance.save()
    
    def delete_subscriber(self, idSensor, email, location):
        self.stopListening()
        UserSensor.objects.filter(idSensor=idSensor, email=email, location=location).delete()

    
    def connect_mqtt(self) -> mqtt_client:
        def on_connect(client, userdata, flags, rc):
            if rc == 0:
                print("Connected to MQTT Broker!")
            else:
                print("Failed to connect, return code %d\n", rc)
    
        client = mqtt_client.Client('Notifier')
        # client.username_pw_set(username, password)
        client.on_connect = on_connect
        client.connect(self.ip, self.port)
        return client

    def startListening(self):

        ids_values = UserSensor.objects.values_list('idSensor', flat=True).distinct()
        
        self.subs = []

        # Loop through all instances and print their attributes
        for idSensor in ids:
            instance = UserSensor.objects.filter(idSensor=idSensor)[0]
            self.subs.append(subscriberMQTT('moveID/subscriber' + instance.location + idSensor , self.ip, self.port))
            
        for sub in self.subs:
            sub.run()

        
                
    def stopListening(self):
        for sub in self.subs:
            sub.stop()

        self.subs = []
    


    def publish(self,client, id):
        msg_count = 1
        while True:
            time.sleep(1)
            msg = f"messages: {msg_count}"
            result = client.publish('Notification', 'Alerta '+ id)
            # result: [0, 1]
            status = result[0]
            if status == 0:
                print(f"Send `{msg}` to topic `{topic}`")
            else:
                print(f"Failed to send message to topic {topic}")
            msg_count += 1
            if msg_count > 5:
                break

    def getData(self, topic_id):

        array = []

        instances = Dataset.objects.all() # Retrieve all rows where name is "John"
        path = instances[0].path

        Dataset=pickle.load(open(path,'rb'))
        window = Dataset['len_window']

        newest_rows = SensorData.objects.filter(topic_id=topic_id).order_by('-__getattr__("datetime")')[:window]

        for row in newest_rows:
            array.append(row.message)

        if(len(array)== window):
            return array
        return []

    def classify(self, data):
        calculated = preprocessing.calculate_statistics(windowed)
        matrix = preprocessing.to_matrix(calculated)

        return self.voting.predict(matrix)

        
    
    
    def run(self):
        self.client = self.connect_mqtt()
        while True:
            
            for sub in self.subs:
                data = self.getData(sub.topic)

                if data:
                    if self.classify(data):
                        client.loop_start()
                        self.publish(client, sub.topic)
                        client.loop_stop()


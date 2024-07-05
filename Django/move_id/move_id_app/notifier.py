from move_id_app.models import Classifier, Dataset, UserSensor, SensorData, Sensor, Patient, Location, SensorDataClassification
from django.contrib.auth.models import User
from .votingClassifier import VotingClassifier
from .subscriberMQTT import subscriberMQTT
from paho.mqtt import client as mqtt_client
from datetime import datetime
import pickle
import json
import os
import csv
import move_id_app.preprocessing.preprocessing as preprocessing
import time
import sys
import numpy as np
from django.db import transaction


class Notifier:
    

    def __init__(self,preprocessing, ip, port=1883):
        """
        Initializes the Notifier class with broker IP and port.
        Sets up an empty list of subscribers and an instance of VotingClassifier, just to have acess to functions .
        """
        self.subs = []
        self.ip = ip
        self.port = port
        self.voting = VotingClassifier()
        self.preprocessing = preprocessing

    
    def add_new_dataset(self, path):
        """
        Adds a new dataset to the system. If an existing dataset is found, it updates it
        and retrains the classifiers with the new dataset. Scores of old and new datasets
        are saved in a pickle file.
        """
        try:
            with transaction.atomic():
                # Verificar se já existe um dataset na tabela
                existing_dataset = Dataset.objects.first()
                # Eliminar o path ja existente 
                Dataset.objects.first().delete()

                if existing_dataset:

                    new_instance = Dataset(path=path)
                    new_instance.save()

                    classifiers = Classifier.objects.all()

                    if classifiers:

                        for cl in classifiers:
                            class_name = cl.name
                            module_name = cl.module
                            classifier = getattr(sys.modules[module_name], class_name)

                            self.add_classifier(classifier, cl.params)


                        

                        print('New dataset ready to use!')

                else:
                    new_instance = Dataset(path=path)
                    new_instance.save()

                    print("New dataset ready to use!")

                

        except Exception as e:
            print(f"An error occurred: {e}")
            raise

    def make_new_dataset(self):
        """
        Creates a new dataset by combining existing dataset with user classifications.
        """
        existing_dataset = Dataset.objects.first()
        

        path = existing_dataset.path

        dataset=pickle.load(open(path,'rb'))
        X = dataset['X']
        y = dataset['y']
        len_window = dataset['len_window']


        notification_with_avaliation = SensorDataClassification.objects.filter(classification__isnull=False)

        data = [json.loads(notif.message)[0] for notif in notification_with_avaliation]
        classifications = [ -1 if notif.classification == True else 1 for notif in notification_with_avaliation]

        

        new_X = np.vstack((X,data))
        new_y = np.hstack((y,classifications))
        
        now = datetime.now()
        

        file_name = './move_id_app/dataset' +'/' + 'dataset_with_users_classifications_' + now.strftime("%d_%m_%Y_%H_%M_%S") +'.p'
        
        with open(file_name, 'wb') as f: 
            pickle.dump({'X':new_X,'y':new_y, 'len_window':len_window}, f)
        
        print('New dataset with users classification saved on path: ' + file_name)


        
    def add_classifier(self, classifier, unsupervised):
        """
        Calls the respective method of the VotingClassifier instance, depending on whether the classifier is unsupervised or not.
        """

        if(unsupervised):
            self.voting.add_classifier_unsupervised(classifier)
        else:
            instances = Dataset.objects.all() # Retrieve all rows where name is "John"

            path = instances[0].path

            dataset=pickle.load(open(path,'rb'))
            X = dataset['X']
            y = dataset['y']

            self.voting.add_classifier(classifier, X)
    
    
    
    def delete_classifier(self, id):
        """
        Deletes a classifier from the voting system using its ID.
        """
        self.voting.delete_classifier(id)
    
    def add_subscriber(self, idSensor, email, nif, start_running=False):
        """
        Adds a new subscriber to receive notification from a sensor.
        Optionally starts the MQTT subscriber, if there isnt already a MQTT subscriber listening
        that sensor.
        """

        user = User.objects.filter(email=email).first()

        sensor = Sensor.objects.filter(id_sensor=idSensor).first()

        new_instance = UserSensor(sensor=sensor, user=user)

        # Save the instance to the database
        new_instance.save()

        already_exists = False

        for sub in self.subs:
            if(sub.id == idSensor):
                already_exists = True
        

            
        if not already_exists:
            self.subs.append(subscriberMQTT(self.preprocessing, new_instance.user.email ,new_instance.sensor.location.id, idSensor , self.ip, self.port))
            if(start_running):
                self.subs[len(self.subs)-1].run()
        
    
    def delete_subscriber(self, idSensor, email):
        """
        Deletes a subscriber from a sensor. 
        If there are no other users interested in that sensor, the MQTT subscriber is terminated.
        """

        user = User.objects.filter(email=email).delete()
        sensor = Sensor.objects.filter(id_sensor=idSensor).first()

        UserSensor.objects.filter(sensor=sensor, user=user).delete()

        
        if UserSensor.objects.filter(sensor=sensor) is None:
            index = -1
            count = 0
            for sub in self.subs:
                if(sub.id == idSensor):
                    index = count
                count += 1
            
            if(index != -1):
                self.subs[index].stop()
                self.subs.pop(index)

            
    # def connect_mqtt(self) -> mqtt_client:
    #     """
    #     Connects to the MQTT broker and returns the client object.
    #     Defines the on_connect callback to handle connection status.
    #     """
    #     def on_connect(client, userdata, flags, rc):
    #         if rc == 0:
    #             print("Connected to MQTT Broker!")
    #         else:
    #             print("Failed to connect, return code %d\n", rc)
    
    #     client = mqtt_client.Client('Notifier')
    #     # client.username_pw_set(username, password)
    #     client.on_connect = on_connect
    #     client.connect(self.ip, self.port)
    #     return client

    def startListening(self):
        """
        Starts listening for MQTT messages from all user sensors.
        Creates and runs MQTT subscribers for each sensor.
        """
        ids_values = UserSensor.objects.values_list('sensor', flat=True).distinct()
        
        self.subs = []

        # Loop through all instances and print their attributes
        for idSensor in ids_values:
            instance = UserSensor.objects.filter(sensor=idSensor)[0]
            self.subs.append(subscriberMQTT(self.preprocessing, instance.user.email ,instance.sensor.location.id, idSensor , self.ip, self.port))
            
        for sub in self.subs:
            sub.run()

        
                
    def stopListening(self):
        """
        Stops listening for MQTT messages and clears the list of subscribers.
        """
        for sub in self.subs:
            sub.stop()

        self.subs = []
    
    


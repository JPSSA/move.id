from move_id_app.models import Classifier, Dataset, UserSensor, SensorData, Sensor, Patient, Location
from django.contrib.auth.models import User
from .votingClassifier import VotingClassifier
from .subscriberMQTT import subscriberMQTT
from paho.mqtt import client as mqtt_client
from datetime import datetime
import pickle
import json
import os
import csv
import move_id_app.preprocessing as preprocessing
import time
import sys
from django.db import transaction


class Notifier:
    '''
    Implementa todo o processo desde a subscrição a tópicos até ao processamento
    de dados e envio de notificações para os respetivos canais.

    Argumentos:
    - "ip", do servidor MQTT
    - "port", do servidor MQTT
    '''

    def __init__(self, ip, port=1883):
        self.subs = []
        self.ip = ip
        self.port = port
        self.voting = VotingClassifier()

    
    def add_new_dataset(self, path):
    
        try:
            # Iniciar uma transação
            with transaction.atomic():
                # Verificar se já existe um dataset na tabela
                existing_dataset = Dataset.objects.first()

                if existing_dataset:

                    # Atualizar o caminho do dataset existente
                    existing_dataset.path = path
                    existing_dataset.save()

                    # Obter todos os classificadores existentes
                    classifiers = Classifier.objects.all()

                    # Dicionário para armazenar os scores
                    scores = {}

                    scores['old_dataset'] = [{'name': cl.name, 'path': cl.path, 'score' : cl.score, 'best_params' : cl.params} for cl in classifiers]

                    # Treinar cada classificador com o novo dataset e os parâmetros existentes
                    for cl in classifiers:
                        class_name = cl.name
                        module_name = cl.module
                        classifier = getattr(sys.modules[module_name], class_name)

                        self.add_classifier(classifier, cl.params)

                    classifiers = Classifier.objects.all()

                    scores['new_dataset'] = [{'name': cl.name, 'path': cl.path, 'score' : cl.score, 'best_params' : cl.params} for cl in classifiers]

                    now = datetime.now()

                    file_name = 'dataset' +'/' + 'dataset_change' + now.strftime("%d_%m_%Y_%H_%M_%S") +'.p'

                

                    # Salva o classificador em um arquivo pickle
                    with open(file_name, 'wb') as f: 
                        pickle.dump(scores, f)

                    print('New dataset ready to use! We provided a file "'+ file_name +'" with the score differences in each one classifier.')

                else:
                    # Se não houver um dataset existente, criar um novo
                    new_instance = Dataset(path=path)
                    new_instance.save()

                    print("New dataset ready to use!")

                    # Opcional: Treinar novos classificadores aqui, se necessário

                

        except Exception as e:
            # Lidar com erros, se necessário
            print(f"An error occurred: {e}")
            raise

    def make_new_dataset():
        existing_dataset = Dataset.objects.first()
        

        path = existing_dataset.path

        dataset=pickle.load(open(path,'rb'))
        X = dataset['X']
        y = dataset['y']

        notification_with_avaliation = SensorDataClassification.objects.filter(classification != None)

        for notification in notification_with_avaliation:
            X.append(notification.message)
            y.append(notification.classification)

        file_name = 'dataset' +'/' + 'dataset_with_users_classifications_' + now.strftime("%d_%m_%Y_%H_%M_%S") +'.p'
        
        with open(file_name, 'wb') as f: 
            pickle.dump({'X':X,'y':y}, f)
        
        print('New dataset with users classification saved on path: ' + file_name)




    def add_patient(self, nif, first_name, last_name, room, bed):
        new_instance = Patient(nif=nif, first_name=first_name, last_name=last_name,room=room, bed=bed)
        new_instance.save()
    
    def delete_patient(self, nif):
        Patient.objects.filter(nif=nif).delete()

    def add_location(self, name):
        new_instance = Location(name=name)
        new_instance.save()

    def delete_location(self,id):
        Location.objects.filter(id=id).delete()

        
    def add_classifier(self, classifier, parameters):
        instances = Dataset.objects.all() # Retrieve all rows where name is "John"

        path = instances[0].path

        dataset=pickle.load(open(path,'rb'))
        X = dataset['X']
        y = dataset['y']

        self.voting.add_classifier(classifier,parameters, X, y)
    
    def add_classifier_unsupervised(self, classifier):
        self.voting.add_classifier_unsupervised(classifier)

    def delete_classifier(self, id):
        self.voting.delete_classifier(id)
    
    def add_subscriber(self, idSensor, email, location, nif):
        self.stopListening()

        instances = Patient.objects.filter(nif=nif) # Retrieve all rows where name is "John"

        

        sensor = Sensor(idSensor=idSensor, nif=instances[0])
        sensor.save()
        # Create an instance of MyModel

        users = User.objects.filter(email=email)

        new_instance = UserSensor(idSensor=sensor, user=users[0], location=location)

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

        ids_values = UserSensor.objects.values_list('sensor', flat=True).distinct()
        
        self.subs = []

        # Loop through all instances and print their attributes
        for idSensor in ids_values:
            instance = UserSensor.objects.filter(sensor=idSensor)[0]
            self.subs.append(subscriberMQTT(instance.sensor.location.id, idSensor , self.ip, self.port))
            
        for sub in self.subs:
            sub.run()

        
                
    def stopListening(self):
        for sub in self.subs:
            sub.stop()

        self.subs = []
    
    


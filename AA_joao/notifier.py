from votingClassifier import VotingClassifier
from subscriberMQTT import subscriberMQTT
from paho.mqtt import client as mqtt_client
import json
import os
import csv
import preprocessing

class Notifier:
    def __init__(self, ip, ids_file='id_list.csv',port=1883):
        self.ids_file = ids_file
        self.voting = VotingClassifier()
        self.subs = []
        self.ip = ip
        self.port = port
        

        # Cria o arquivo CSV se não existir
        if not os.path.exists(self.ids_file):
            with open(self.ids_file, 'w', newline='') as csvfile:
                writer = csv.writer(csvfile)
                writer.writerow(['ID'])

    def add_subscriber(self, id):
        # Atualiza o arquivo CSV
        with open(self.ids_file, 'r') as csvfile:
            data = list(csv.reader(csvfile))

        data.append([id])

        with open(self.ids_file, 'w', newline='') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerows(data)

    
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
        self.subs = []
        with open(self.ids_file, 'r') as csvfile:
            reader = csv.reader(csvfile)
            next(reader)  # Pula o cabeçalho
            for row in reader:
                self.subs.append(subscriberMQTT('moveID/' + row[0], self.ip, self.port))

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

    def getData(self, file):

        data = {}
        with open(file, 'r') as csvfile:
            reader = csv.reader(csvfile)
            header = next(reader)  # Pula o cabeçalho
            for row in reader:
                for i in range(len(row)):
                    my_float_list =[]
                    for x in row[i].split('_'):
                        if(x != ''):
                            my_float_list.append(float(x))
                    data[header[i]] = { 'x' : my_float_list[0], 'y' : my_float_list[1], 'z' : my_float_list[2]}

        return data

    def classify(self, data):
        windowed = preprocessing.windowed_data(data, 6)
        calculated = preprocessing.calculate_statistics(windowed)
        matrix = preprocessing.to_matrix(calculated)

        return self.voting.predict(matrix)

        
    
    
    def run(self):
        self.client = self.connect_mqtt()
        while True:
            
            for sub in self.subs:
                print('AAAA')
                data = self.getData(sub.csv_file)
                if data.keys() == 6:
                    if self.classify(data):
                        client.loop_start()
                        self.publish(client, sub.topic)
                        client.loop_stop()

    

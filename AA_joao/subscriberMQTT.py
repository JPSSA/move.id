from paho.mqtt import client as mqtt_client
import json
import os
import csv

class subscriberMQTT:
    def __init__(self, topic, ip, port=1883):
        self.broker = ip
        self.port = port
        self.topic = topic
        self.client_id = ''
        self.received_data = []  # Initialize an empty dictionary to store received data
        self.start_time = 0
        self.csv_file = f"data_csv_{topic.replace('/', '_')}.csv"

        if not os.path.exists(self.csv_file):
            with open(self.csv_file, 'w', newline='') as csvfile:
                writer = csv.writer(csvfile)
                writer.writerow([ 'Gyroscope', 'Accelerometer'])
        

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
            payload = msg.payload.decode()
            print(f"Received `{payload}` from `{msg.topic}` topic")
            row = self.makeRow(payload)
            if row:
                self.on_message_data_append(self.topic,row)
    
        client.subscribe(self.topic)
        client.on_message = on_message

    def makeRow(self, sample):
        row = []
        sample_dict = json.loads(sample)
        if sample_dict:
            keys = list(sample_dict.keys())
            for key in keys:
                
                dict = sample_dict[key]
                keys_dict = list(dict.keys())
                string = ''
                for k in keys_dict:
                    string = string + dict[k] + '_'
                row.append(string)
        return row

    def on_message_data_append(self, topic, row):
        
    
        with open(self.csv_file, 'r') as csvfile:
            data = list(csv.reader(csvfile))

        # Se houver mais de 7 linhas, remova a segunda linha
        if len(data) > 6:
            data.pop(1)
            data.append(row)
        else:
            data.append(row)
    
        # Escreva as linhas atualizadas de volta ao arquivo CSV
        with open(self.csv_file, 'w', newline='') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerows(data) 

    def stop(self):
        self.client.loop_stop()
    
    def run(self):
        self.client = self.connect_mqtt()
        self.subscribe(self.client)
        self.client.loop_start()
        
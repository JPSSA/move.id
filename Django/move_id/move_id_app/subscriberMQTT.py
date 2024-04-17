from paho.mqtt import client as mqtt_client
from .sensordatautils import appendData, count_rows_with_topic_id, delete_oldest_sensor_data
import json
import os

class subscriberMQTT:
    def __init__(self, location, topic_id, ip, port=1883):
        self.broker = ip
        self.port = port
        self.location = location
        self.id = topic_id
        self.client_id = ''
        self.received_data = []  # Initialize an empty dictionary to store received data
        self.start_time = 0
        
        

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
            
        client.subscribe('moveID/subscriber/'+ self.location + '/' + self.id)
        client.on_message = on_message


    def stop(self):
        self.client.loop_stop()

    def publish(self,client, location, topic_id):
        msg_count = 1
        while True:
            time.sleep(1)
            msg = f"messages: {msg_count}"
            result = client.publish('moveID/notification/'+location+'/'+topic_id, 'Alerta')
            # result: [0, 1]
            status = result[0]
            #if status == 0:
                #print(f"Send `{msg}` to topic Notification")
            #else:
                #print(f"Failed to send message to topic Notification")
            msg_count += 1
            if msg_count > 5:
                break
    

    def getData(self, topic_id):

        array = []

        instances = Dataset.objects.all() # Retrieve all rows where name is "John"
        path = instances[0].path

        dat=pickle.load(open(path,'rb'))
        #window = dat['len_window']
        window = 6

        newest_rows = SensorData.objects.filter(topic_id=topic_id).order_by('-datetime')[:window]

        for row in newest_rows:
            array.append(row.message)

        if(len(array)== window):
            return array
        return []

    def classify(self, data,  location, topic_id):
        calculated = preprocessing.calculate_statistics(data)
        #print(calculated)
        matrix = preprocessing.to_matrix([calculated])


        return self.voting.predict(matrix,  location, topic_id)

    
    
    def run(self):
        self.client = self.connect_mqtt()
        self.subscribe(self.client)
        self.client.loop_start()
        
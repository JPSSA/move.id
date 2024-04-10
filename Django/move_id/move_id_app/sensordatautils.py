from .models import SensorData
import pandas as pd # type: ignore
import json
from datetime import datetime


def count_rows_with_topic_id(topic_id):
    count = SensorData.objects.filter(topic_id=topic_id).count()
    return count

def delete_oldest_sensor_data(topic_id):
    try:
        oldest_sensor_data = SensorData.objects.filter(topic_id=topic_id).order_by('datetime').first()
        if oldest_sensor_data:
            oldest_sensor_data.delete()
            print(f"Oldest SensorData record with topic_id {topic_id} deleted successfully.")
        else:
            print(f"No SensorData records found with topic_id {topic_id}.")

    except Exception as e:
         print("Error occurred while deleting oldest SensorData record:", e)

def get_sensor_data_as_dataframe(topic_id):
    
    sensor_data_queryset = SensorData.objects.filter(topic_id=topic_id).order_by('datetime')

    sensor_data_list = list(sensor_data_queryset.values('datetime', 'accelerometerX', 'accelerometerY', 'accelerometerZ'))
    
    sensor_data_df = pd.DataFrame(sensor_data_list)
    
    sensor_data_df.set_index('datetime', inplace=True)
    
    return sensor_data_df

def appendData(msg):
    sensor_data_instance = SensorData.objects.create(
        datetime = datetime.now(),
        topic_id = msg.topic,
        message=msg.payload
        )
    print("Sensor Data saved!!")
   
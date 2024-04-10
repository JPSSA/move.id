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
    
    sensor_data_queryset = SensorData.objects.filter(topic_id=topic_id)

    accelerometer_data_list = []

    for sensor_data in sensor_data_queryset:
        data = json.loads(sensor_data.message)
        accelerometer_data = data.get('accelerometerSensor')
        if accelerometer_data:
            accelerometer_data_list.append({
                'datetime': sensor_data.datetime,
                'accelerometerX': accelerometer_data.get('x'),
                'accelerometerY': accelerometer_data.get('y'),
                'accelerometerZ': accelerometer_data.get('z')
            })
    
    sensor_data_df = pd.DataFrame(accelerometer_data_list)

    sensor_data_df['datetime'] = pd.to_datetime(sensor_data_df['datetime'])  # Convert datetime to datetime type
    sensor_data_df.set_index('datetime', inplace=True)

    return sensor_data_df

def appendData(msg):
    sensor_data_instance = SensorData.objects.create(
        datetime = datetime.now(),
        topic_id = msg.topic,
        message=msg.payload.decode()
        )
    print("Sensor Data saved!!")
   
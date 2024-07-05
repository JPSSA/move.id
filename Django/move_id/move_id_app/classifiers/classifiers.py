from abc import ABC, abstractmethod
from move_id_app.sensordatautils import get_sensor_data_as_dataframe
import warnings
warnings.filterwarnings("ignore", message="Setting an item of incompatible dtype is deprecated", category=FutureWarning)

class Classifier(ABC):
    def __init__(self,score):
        self.score = score

    @abstractmethod
    def predict(self, info):
        '''
        Method that returns the classification of the data set provided(X).
        To work correctly, it must comply with the protocol. 
        It should return 1 if it is classified as an outlier and 0 
        if it is classified as normal.
        '''
        pass
    


class OneClassClassifier(Classifier):

    def __init__(self, score, model, params):
        super().__init__(score)
        self.model = model(**params)
        self.params = params

    @abstractmethod
    def fit(self, X_train):
        '''
        Method for training the model with values within the standard(X_train).
        '''
        pass


class AnomalyDetector(Classifier):

    def __init__(self,score):
        super().__init__(score)
        

    def is_majority_anomaly(self, anomaly_flags):
        """
        Check if the majority of the anomaly flags are set to 1.

        Parameters:
        anomaly_flags (list): A list of integers where 1 indicates an anomaly and 0 indicates no anomaly.

        Returns:
        bool: True if the majority of the flags are anomalies, otherwise False.
        """
        count_ones = sum(anomaly_flags) 
        total_elements = len(anomaly_flags)
        if count_ones > total_elements / 2:
            return True
        else:
            return False

    def detect_anomalies(self, location, topic_id):
        """
        Detect anomalies in the sensor data based on a specific location and topic ID.

        Parameters:
        location : The location identifier for the sensor data.
        topic_id : The topic identifier for the sensor data.

        Returns:
        list: A list of integers where 1 indicates an anomaly in a column and 0 indicates no anomaly.
        """
        anomaly_flags = []  
        dataframe = get_sensor_data_as_dataframe('moveID/subscriber/' + str(location) + '/' + str(topic_id)) 
        for column_name in dataframe.columns:  
            column_values = dataframe[column_name]  
            if self.check_detection_with_window(column_values, 6, dataframe):  
                anomaly_flags.append(1)  
            else:
                anomaly_flags.append(0)  

        return anomaly_flags  

    def predict(self, info):
        """
        Predict whether the majority of the data points are anomalies based on the given info.

        Parameters:
        info : A dictionary containing 'location' and 'topic_id'.

        Returns:
        int: 1 if the majority of the data points are anomalies, otherwise 0.
        """
        anomaly_flags = self.detect_anomalies(info['location'], info['topic_id'])  
        if self.is_majority_anomaly(anomaly_flags):  
            return 1  
        return 0  

    @abstractmethod
    def check_detection_with_window(self, column_values, window, dataframe):
        """
        Abstract method to be implemented in subclasses to check for anomalies using a sliding window.

        Parameters:
        column_values : The values of a specific column in the DataFrame.
        window : The size of the sliding window.
        dataframe : The entire DataFrame of sensor data.

        Returns:
        bool: True if an anomaly is detected, otherwise False.
        """
        pass
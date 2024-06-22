from abc import ABC, abstractmethod
import sensordatautils

class OneClassClassifier(ABC):

    def __init__(self,model):
        self.model = model

    @abstractmethod
    def fit(self, X_train):
        '''
        Method for training the model with values within the standard(X_train).
        '''
        pass


    @abstractmethod
    def predict(self, X):
        '''
        Method that returns the classification of the data set provided(X).
        To work correctly, it must comply with the protocol. 
        It should return 1 if it is classified as an outlier and 0 
        if it is classified as normal.

        '''
        pass

class AnomalyDetector(ABC):

    def __init__(self,score):
        self.score = model

    def is_majority_anomaly(self,anomaly_flags):
        count_ones = sum(anomaly_flags)
        total_elements = len(anomaly_flags)
        if count_ones > total_elements / 2:
            return True
        else:
            return False

    def detect_anomalies(self, location, topic_id):
        anomaly_flags = []
        dataframe = get_sensor_data_as_dataframe('moveID/subscriber/'+ str(location) + '/' + str(topic_id))
        for column_name in dataframe.columns:
            column_values = dataframe[column_name]
            if self.check_detection_with_window(column_values,6,dataframe):
                anomaly_flags.append(1)
            else:
                anomaly_flags.append(0)

        return anomaly_flags  

    def predict(self, location, topic_id):
        anomaly_flags = self.detect_anomalies(location, topic_id)
        if self.is_majority_anomaly(anomaly_flags):
            return 1
        return 0

      

    @abstractmethod
    def check_detection_with_window(self,column_values,window,dataframe):
        '''
        
        '''
        pass
    


from .sensordatautils import get_sensor_data_as_dataframe

class AnomalyDetector:

    def __init__(self,detector_type):

        self.detector_type = detector_type
        self.prediction = 0
        if self.detector_type == 'LevelShift':
            self.score = 0.8
        elif self.detector_type == 'Quantile':
            self.score = 0.75
        elif self.detector_type == 'OutlierDetection':
            self.score = 0.7


    def predict(self, csv_file):
        if self.detector_type == 'LevelShift':
           
            if ():
                self.prediction = 1
            else:
                self.prediction = 0
                
        elif self.detector_type == 'Quantile':
           
            if ():
                self.prediction = 1
            else:
                self.prediction = 0
                
        elif self.detector_type == 'OutlierDetection':
           
            if ():
                self.prediction = 1
            else:
                self.prediction = 0


        return self.prediction

    def get_score(self):
        return self.score
    
    def get_anomalies_dates(self, df):
        anomalies_dates = {}
        for column in df.columns:
            anomalies_dates[column] = self.get_anomalies_dates_for_column(df[column])
        return anomalies_dates

    


df = get_sensor_data_as_dataframe('move_id/1234')

anomalyClassifier = AnomalyDetector('LevelShift')
print('ANOMALYDETECTOR')
print(anomalyClassifier.get_anomalies_dates(df))
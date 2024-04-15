import warnings
warnings.filterwarnings("ignore", message="Setting an item of incompatible dtype is deprecated", category=FutureWarning)
from .sensordatautils import get_sensor_data_as_dataframe
from adtk.data import validate_series
from adtk.detector import LevelShiftAD
from adtk.detector import QuantileAD
from adtk.detector import OutlierDetector
from sklearn.neighbors import LocalOutlierFactor

class AnomalyDetector:
    
    def __init__(self,detector_type,dataframe,score):

        self.detector_type = detector_type
        self.score = score


    def predict(self):
        anomaly_flags = self.detect_anomalies()
        if self.is_majority_anomaly(anomaly_flags):
            return 1
        return 0

    def get_score(self):
        return self.score
    
    def detect_anomalies(self, location, topic_id):
        anomaly_flags = []
        dataframe = get_sensor_data_as_dataframe('moveID/subscriber/'+ location + '/' + topic_id)
        for column_name in dataframe.columns:
            column_values = dataframe[column_name]
            if self.check_detection_with_window(column_values,6,dataframe):
                anomaly_flags.append(1)
            else:
                anomaly_flags.append(0)

        return anomaly_flags

    def getanomalyList(self,anomalies):
        non_nan_anomalies = anomalies.dropna()
        anomalies_dates = []
        for anomaly_idx, anomaly in non_nan_anomalies.items():
            if anomaly:
                anomalies_dates.append(anomaly_idx)

        return anomalies_dates

    def check_detection_with_window(self,column_values,window,dataframe):
        if self.detector_type == 'LevelShift':
            validated_values = validate_series(column_values)
            level_shift_ad = LevelShiftAD(c = 6.0, side = 'both', window = 3)
            anomalies = level_shift_ad.fit_detect(validated_values)
            anomalies_list = self.getanomalyList(anomalies)
            last_rows = dataframe.tail(window)
            anomaly_detected = any(anomaly_timestamp in last_rows.index for anomaly_timestamp in anomalies_list)
            if anomaly_detected:
                return True
            else:
                return False

        elif self.detector_type == 'Quantile':
            validated_values = validate_series(column_values)
            quantile_ad = QuantileAD(high=0.99, low=0.02)
            anomalies = quantile_ad.fit_detect(validated_values)
            anomalies_list = self.getanomalyList(anomalies)
            last_rows = dataframe.tail(window)
            anomaly_detected = any(anomaly_timestamp in last_rows.index for anomaly_timestamp in anomalies_list)
            if anomaly_detected:
                return True
            else:
                return False
                
        elif self.detector_type == 'OutlierDetection':
            validated_values = validate_series(column_values)
            outlier_detector = OutlierDetector(LocalOutlierFactor(contamination=0.02))
            anomalies = outlier_detector.fit_detect(validated_values)
            anomalies_list = self.getanomalyList(anomalies)
            last_rows = dataframe.tail(window)
            anomaly_detected = any(anomaly_timestamp in last_rows.index for anomaly_timestamp in anomalies_list)
            if anomaly_detected:
                return True
            else:
                return False
            
    def is_majority_anomaly(self,anomaly_flags):
        count_ones = sum(anomaly_flags)
        total_elements = len(anomaly_flags)
        if count_ones > total_elements / 2:
            return True
        else:
            return False
           

from move_id_app.classifiers.classifiers import AnomalyDetector
from adtk.detector import OutlierDetector
import pandas as pd
from sklearn.neighbors import LocalOutlierFactor
from adtk.data import validate_series

class OutlierDetection(AnomalyDetector):

    def __init__(self):
        super().__init__(0.6)

    def check_detection_with_window(self, column_values, window, dataframe):
        """
        Check for anomalies in the column values using a sliding window approach.

        Parameters:
        column_values: The values of a specific column in the DataFrame.
        window : The size of the sliding window.
        dataframe : The entire DataFrame of sensor data.

        Returns:
        bool: True if an anomaly is detected in the last 'window' rows, otherwise False.
        """
        validated_values = validate_series(column_values)
        validated_values = pd.DataFrame(validated_values)
        outlier_detector = OutlierDetector(LocalOutlierFactor(contamination=0.02))
        anomalies = outlier_detector.fit_detect(validated_values)
        anomalies_list = self.getanomalyList(anomalies)
        last_rows = dataframe.tail(window)
        anomaly_detected = any(anomaly_timestamp in last_rows.index for anomaly_timestamp in anomalies_list)
        if anomaly_detected:
            return True 
        else:
            return False

    def getanomalyList(self, anomalies):
        """
        Extract a list of indices where anomalies are detected.

        Parameters:
        anomalies: A series indicating which data points are anomalies (True for anomaly, False otherwise).

        Returns:
        list: A list of indices where anomalies are detected.
        """
        non_nan_anomalies = anomalies.dropna() 
        anomalies_dates = []
        for anomaly_idx, anomaly in non_nan_anomalies.items():
            if anomaly:  
                anomalies_dates.append(anomaly_idx)  
        
        return anomalies_dates
        
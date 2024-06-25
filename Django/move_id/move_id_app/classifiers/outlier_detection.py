from move_id_app.classifiers.classifiers import AnomalyDetector
from adtk.detector import OutlierDetector
import pandas as pd
from sklearn.neighbors import LocalOutlierFactor

class OutlierDetection(AnomalyDetector):

    def __init__(self):
        super().__init__(0.6)

    def check_detection_with_window(self,column_values,window,dataframe):
        
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

    def getanomalyList(self,anomalies):
        non_nan_anomalies = anomalies.dropna()
        anomalies_dates = []
        for anomaly_idx, anomaly in non_nan_anomalies.items():
            if anomaly:
                anomalies_dates.append(anomaly_idx)

        return anomalies_dates

        
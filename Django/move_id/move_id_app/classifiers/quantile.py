from classifiers import AnomalyDetector
from adtk.detector import QuantileAD

class Quantile(AnomalyDetector):

    def check_detection_with_window(self,column_values,window,dataframe):
        
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

    def getanomalyList(self,anomalies):
        non_nan_anomalies = anomalies.dropna()
        anomalies_dates = []
        for anomaly_idx, anomaly in non_nan_anomalies.items():
            if anomaly:
                anomalies_dates.append(anomaly_idx)

        return anomalies_dates

        
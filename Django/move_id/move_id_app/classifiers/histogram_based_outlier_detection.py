from pyod.models.hbos import HBOS
from move_id_app.classifiers.classifiers import OneClassClassifier
from sklearn.preprocessing import StandardScaler
import numpy as np


class HistogramBasedOutlierDetection(OneClassClassifier):
    
    def __init__(self):
        super().__init__(0.7,HBOS, {})
        self.scaler = StandardScaler()

    def fit(self,X_train):
        self.scaler.fit(X_train)
        X_train_scalled = self.scaler.transform(X_train)
        self.model.fit(X_train_scalled)

    
    def predict(self,info):
        X_test_scalled = self.scaler.transform(info['X'])
        scores = self.model.decision_function(X_test_scalled) 
        threshold = np.percentile(scores, 90)
        predicitons = -(scores > threshold).astype(int)
        y_pred = [ -1 if p == -1 else 1 for p in predicitons]
        for y in y_pred:
            if(y == -1):
                return 1
        return 0
        
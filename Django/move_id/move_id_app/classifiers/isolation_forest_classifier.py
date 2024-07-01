from move_id_app.classifiers.classifiers import OneClassClassifier
from sklearn.ensemble import IsolationForest
from sklearn.preprocessing import StandardScaler

class IsolationForestClassifier(OneClassClassifier):
    
    def __init__(self):
        super().__init__(0.7,IsolationForest,  {'n_estimators': 50,'max_samples': 'auto','contamination': 'auto','max_features': 2,'bootstrap': False})
        self.scaler = StandardScaler()

    def fit(self,X_train):
        
        self.scaler.fit(X_train)
        X_train_scalled = self.scaler.transform(X_train)
        self.model.fit(X_train_scalled)

    
    def predict(self,info):
        X_test_scalled = self.scaler.transform(info['X'])
        y_pred = self.model.predict(X_test_scalled)
        for y in y_pred:
            if y == -1:
                return 1
        return 0
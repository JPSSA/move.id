from Classifiers import OneClassClassifier
from sklearn.svm import OneClassSVM

class OneClassSVMClassifier(OneClassClassifier):
    
    def __init__(self, model):
        super(OneClassSVM())

    def fit(self,X_train):
        self.model.fit(X_train)

    
    def predict(self,X):
        y_pred = self.model.predict(X)

        return [v if(v == 1) else 0 for v in y_pred]


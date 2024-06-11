from abc import ABC, abstractmethod

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
    @abstractmethod
    def predict(self, X):
        '''
        Method that returns the classification of the data set provided(X).
        To work correctly, it must comply with the protocol. 
        It should return 1 if an outlier is detected and 0 
        there is there isn't an outlier.
        '''
        pass



from abc import ABC, abstractmethod

class PreProcessing(ABC):

    def __init__(self,metrics):
        self.metrics = metrics

    @abstractmethod
    def fit(self, data):
        '''
        Method for transforming incoming data into a matrix suitable for classification
        '''
        pass




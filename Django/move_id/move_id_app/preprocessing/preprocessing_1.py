import json
import numpy as np
import scipy
from move_id_app.preprocessing.preprocessing import PreProcessing
from scipy.stats import skew, kurtosis
import warnings
warnings.filterwarnings("ignore", category=RuntimeWarning, message="Precision loss occurred in moment calculation due to catastrophic cancellation. This occurs when the data are nearly identical. Results may be unreliable.")

class PreProcessing_v1(PreProcessing):

    
    def dict_flatten(self,dic):
        Dic = {}
        for key in dic.keys():
            sample_dict = dic[key]
            if(isinstance(sample_dict, dict)):
                axis = list(dic[key].keys())
                for x in axis:
                    Dic[key+x] = sample_dict[x]
            else:
                Dic[key] = sample_dict[x]
        

        return Dic


    

    def __init__(self):
        def energy(array):
            return np.sum(np.square(array))

        def entropy(array):
            return scipy.stats.entropy(np.histogram(array)[0])

        def mad(array):
            return np.mean(np.abs(array - np.mean(array)))

        def rms(array):
            return np.sqrt(np.mean(np.square(array)))

        def skew_func(array):
            return skew(array) if not np.isnan(skew(array)) else 0

        def kurtosis_func(array):
            return kurtosis(array) if not np.isnan(kurtosis(array)) else 0
        super().__init__([np.std, np.var, mad, rms, energy, entropy, skew_func, kurtosis_func])

    def calculate_statistics(self,window):
        
        Dic = {}
        
        flatten = [self.dict_flatten(json.loads(message)) for message in window]
        
        keys = list(flatten[0].keys())

        for key in keys:
            data = []
            for sample in flatten:
                data.append(float(sample[key]))
            
            #Aplica-se todas as metricas e junta-se ao dicionário
            for metric in self.metrics:
                Dic[key+'_'+metric.__name__] = metric(data)
                        
        return Dic

    def to_matrix(self,processed_data):
        X = []
        for sample in processed_data:
            sample_values = []
            for key, value in sample.items():
                if isinstance(value, tuple):
                    sample_values.extend(value)
                else:
                    sample_values.append(value)
            X.append(sample_values)

        
        return X


    def fit(self,data):
        calculated = self.calculate_statistics(data)
        return self.to_matrix([calculated])


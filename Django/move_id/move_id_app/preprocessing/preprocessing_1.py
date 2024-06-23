import json
import numpy as np
import scipy
from preprocessing import PreProcessing
from scipy.stats import skew, kurtosis

class PreProcessing_v1(PreProcessing):

    def windowed_data(data, window_size):
        num_samples = len(data)
        num_windows = num_samples - window_size + 1
        windows = [data[i:i+window_size] for i in range(num_windows)]
        return windows

    def dict_flatten(dic):
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

    def __init__(self):
        super([np.std, np.var, mad, rms, energy, entropy, skew_func, kurtosis_func])

    def calculate_statistics(window):
        
        Dic = {}
        
        
        
        flatten = [dict_flatten(json.loads(dic.message)) for dic in window]
        
        keys = list(flatten[0].keys())

        for key in keys:
            data = []
            for sample in flatten:
                data.append(float(sample[key]))
            
            #Aplica-se todas as metricas e junta-se ao dicionário
            for metric in self.metrics:
                Dic[key+'_'+metric.__name__] = metric(data)
                        
        return Dic

    def to_matrix(processed_data):
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


    def fit(data):
        calculated = calculate_statistics(data)
        return to_matrix([calculated])


import json
import numpy as np
from scipy.stats import entropy




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

metrics = [np.mean, np.median, max, min, np.std, energy, entropy]

def calculate_statistics(window):
    
    Dic = {}
    
    
    
    flatten = [dict_flatten(json.loads(dic)) for dic in window]
    
    keys = list(json.loads(flatten[0]).keys())

    for key in keys:
        data = []
        for sample in flatten:
            data.append(sample[key])


        #Aplica-se todas as metricas e junta-se ao dicionário
        for metric in metrics:
            Dic[key+'_'+metric] = metrics[metric](data)
                    
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


def preprocessing(data,window_size):
    windowed = windowed_data(data, window_size)
    processed_data = [calculate_statistics(window) for window in neg_windows]
    X2 = to_matrix(neg_processed_data)


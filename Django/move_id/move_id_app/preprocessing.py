import json
import numpy as np
from scipy import entropy


metrics = [np.mean, np.median, max, min, np.std, energy, entropy]

def windowed_data(data, window_size):
    num_samples = len(data)
    num_windows = num_samples - window_size + 1
    windows = [data[i:i+window_size] for i in range(num_windows)]
    return windows

def calculate_statistics(window):
    
    Dic = {}
    
    keys = list(json.loads(window[0]).keys())
    
    
    for key in keys:
        data = []
        for sample in window:
            sample_dict = json.loads(sample)
            data.append(sample_dict[key])

        #Caso seja um dicionáro, ou seja, vários valores
        if(isinstance(sample_dict, dict)):
            #Recolhe-se os eixos (ou qualquer significado que tenham esses valores)
            axis = list(data[0].keys())

            #Percorre-se cada um para calcular individualmente as várias métricas
            for x in axis:
                #Recolhe-se todos os valores de x na janela
                values = [float(sample[x]) for sample in data]

                #Aplica-se todas as metricas e junta-se ao dicionário
                for metric in metrics:
                    Dic[key+'_'+x+'_'+metric] = metrics[metric](values)
                    
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

def energy(array):
    return np.sum(np.square(array))

def entropy(array):
    return scipy.stats.entropy(np.histogram(array)[0])
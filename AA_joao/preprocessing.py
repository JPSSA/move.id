import json
import numpy as np
from scipy.stats import entropy


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

        x_values = [float(sample['x']) for sample in data]
        y_values = [float(sample['y']) for sample in data]
        z_values = [float(sample['z']) for sample in data]
    
        
        mean = np.mean(x_values), np.mean(y_values), np.mean(z_values)
        median = np.median(x_values), np.median(y_values), np.median(z_values)
        largest_observation = max(x_values), max(y_values), max(z_values)
        smallest_observation = min(x_values), min(y_values), min(z_values)
        std_dev = np.std(x_values), np.std(y_values), np.std(z_values)
        energy = np.sum(np.square(x_values)) + np.sum(np.square(y_values)) + np.sum(np.square(z_values))
        entropy_val = entropy(np.histogram(x_values)[0]) + entropy(np.histogram(y_values)[0]) + entropy(np.histogram(z_values)[0])
    
        Dic[key+'_mean_x'] = mean[0],
        Dic[key+'_mean_y'] = mean[1], 
        Dic[key+'_mean_z']= mean[2],
        Dic[key+'_median_x']=median[0],
        Dic[key+'_median_y']= median[1],
        Dic[key+'_median_z']= median[2],
            
        Dic[key+'_largest_observation_x']=largest_observation[0], 
        Dic[key+'_largest_observation_y']= largest_observation[1], 
        Dic[key+'_largest_observation_z']= largest_observation[2],
        Dic[key+'_smallest_observation_x']=smallest_observation[0], 
        Dic[key+'_smallest_observation_y']= smallest_observation[1], 
        Dic[key+'_smallest_observation_z']= smallest_observation[2],
        Dic[key+'_std_dev_x']=std_dev[0], 
        Dic[key+'_std_dev_y']= std_dev[1],
        Dic[key+'_std_dev_z']= std_dev[2],
        Dic[key+'_energy']= energy,
        Dic[key+'_entropy'] = entropy_val
        
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
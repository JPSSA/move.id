import pickle
import csv
import os
from move_id_app.models import Classifier
import numpy as np
from datetime import datetime
from sklearn.model_selection import GridSearchCV

class VotingClassifier:
    def __init__(self, models_dir='/home/joao/move.id/move.id/Django/move_id/move_id_app/models'):
        self.models_dir = models_dir

        classifiers = []
        scores = []
        

        instances = Classifier.objects.all()

        for instance in instances:
            
            scores.append(float(instance.score))
            with open(instance.path, 'rb') as f:
                clf = pickle.load(f)
                classifiers.append(clf)

        self.classifiers = classifiers
        

        total_scores = np.sum(scores)

        weights = []
        
        for score in scores:
            weights.append(score/total_scores)

        self.weights = weights


    def add_classifier(self, classifier, X_train):
        """
        Adds a new classifier to the voting system and trains it with the existing dataset.
        """
        model = classifier()
        clf_name = model.__class__.__name__
        now = datetime.now()
        model_file = self.models_dir +'/' + clf_name + '_model_'+ now.strftime("%d_%m_%Y_%H_%M_%S") +'.p'

        
       

        model.fit(X_train)

        with open(model_file, 'wb') as f:
            pickle.dump(model, f)
        
        
        cl = Classifier.objects.filter(name=clf_name).first()  

        if cl is not None:
            cl.path = model_file
            cl.score = model.score
            cl.params = model.params
            cl.module = model.__module__
            cl.save()  
            
        else:
            new_instance = Classifier(name=clf_name,path=model_file, score=model.score,params=model.params,module=model.__module__)
            new_instance.save()
            

    def add_classifier_unsupervised(self, classifier):
        '''
        Adds a new classifier to the voting system that does not require a training phase, they are unsupervised
        '''
        model = classifier()
        clf_name = model.__class__.__name__
        now = datetime.now()
        model_file = self.models_dir +'/' + clf_name + '_model_'+ now.strftime("%d_%m_%Y_%H_%M_%S") +'.p'

        with open(model_file, 'wb') as f:
            pickle.dump(model, f)

        cliente = Classifier.objects.filter(name=clf_name).first()  

        if cliente is not None:
            cliente.path = model_file
            cliente.score = model.score
            cliente.module=model.__module__
            cliente.save()  
        
        else:
            new_instance = Classifier(name=clf_name,path=model_file, score=model.score,module=model.__module__)
            new_instance.save()
        


    def delete_classifier(self, id):
        """
        Deletes a classifier from the voting system using its ID.
        """
        Classifier.objects.filter(id=id).delete() 

    
    def predict(self, X,  location, topic_id):
        '''
        Aggregates predictions from multiple classifiers, and return a boolean
        which indicates whether the data to be classified is an outlier if it 
        is True, or an inlier if it is False.
        '''
        predictions = []
        

        for clf, weight in zip(self.classifiers, self.weights):
            predictions.append(clf.predict({'location':location, 'topic_id' : topic_id, 'X':X}))
        
        
        print(predictions)
        
        return int(np.sum(predictions)/len(predictions) > 0.5)


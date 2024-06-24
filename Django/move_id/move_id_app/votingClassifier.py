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


    def add_classifier(self, classifier, parameters, X_train, y_train):
        """
        Adds a new classifier to the voting system and trains it with the existing dataset.
        """
        clf_name = classifier.__class__.__name__
        now = datetime.now()
        model_file = self.models_dir +'/' + clf_name + '_model_'+ now.strftime("%d_%m_%Y_%H_%M_%S") +'.p'

        for param_combination in combinations:
            model = classification_model(**param_combination)

            model.fit(X_train_scalled)

            with open(model_file, 'wb') as f:
                pickle.dump(model, f)
        
        
            cl = Classifier.objects.filter(name=clf_name).first()  

            if cl is not None:
                cl.path = model_file
                cl.score = classifier.score
                cl.params = param_combination
                cl.module = classifier.__module__
                cl.save()  
            
            else:
                new_instance = Classifier(name=clf_name,path=model_file, score=best_score,params=parameters,module=classifier.__module__)
                new_instance.save()
            
            break

    def add_classifier_unsupervised(self, classifier):
        '''
        Adds a new classifier to the voting system that does not require a training phase, they are unsupervised
        '''
        clf_name = classifier.detector_type
        now = datetime.now()
        model_file = self.models_dir +'/' + clf_name + '_model_'+ now.strftime("%d_%m_%Y_%H_%M_%S") +'.p'

        with open(model_file, 'wb') as f:
            pickle.dump(classifier, f)

        cliente = Classifier.objects.filter(name=clf_name).first()  

        if cliente is not None:
            cliente.path = model_file
            cliente.score = classifier.score
            cliente.save()  
        
        else:
            new_instance = Classifier(name=clf_name,path=model_file, score=classifier.score)
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
            predictions.append(clf.predict(X)[0])
        
        
        return int(np.sum(predictions)/len(predictions) > 0.5)


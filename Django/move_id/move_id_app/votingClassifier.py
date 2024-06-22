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
        clf_name = classifier.__class__.__name__
        now = datetime.now()
        model_file = self.models_dir +'/' + clf_name + '_model_'+ now.strftime("%d_%m_%Y_%H_%M_%S") +'.p'

        for param_combination in combinations:
            model = classification_model(**param_combination)

            model.fit(X_train_scalled)

            # Salva o classificador em um arquivo pickle
            with open(model_file, 'wb') as f:
                pickle.dump(model, f)
        
        
            cl = Classifier.objects.filter(name=clf_name).first()  

            # Verifica se o objeto foi encontrado
            if cl is not None:
                # Modifica o campo 'nome'
                cl.path = model_file
                cl.score = classifier.score
                cl.params = param_combination
                cl.module = classifier.__module__
                # Salva as alterações no banco de dados
                cl.save()  
            
            else:
                new_instance = Classifier(name=clf_name,path=model_file, score=best_score,params=parameters,module=classifier.__module__)
                new_instance.save()
            
            break

    def add_classifier_unsupervised(self, classifier):
        clf_name = classifier.detector_type
        now = datetime.now()
        model_file = self.models_dir +'/' + clf_name + '_model_'+ now.strftime("%d_%m_%Y_%H_%M_%S") +'.p'

        # Salva o classificador em um arquivo pickle
        with open(model_file, 'wb') as f:
            pickle.dump(classifier, f)

        # Tenta recuperar o objeto Cliente pelo ID
        cliente = Classifier.objects.filter(name=clf_name).first()  

        # Verifica se o objeto foi encontrado
        if cliente is not None:
            # Modifica o campo 'nome'
            cliente.path = model_file
            cliente.score = classifier.score
            # Salva as alterações no banco de dados
            cliente.save()  
        
        else:
            new_instance = Classifier(name=clf_name,path=model_file, score=classifier.score)
            new_instance.save()
        


    def delete_classifier(self, id):

        Classifier.objects.filter(id=id).delete() 

    
    def predict(self, X,  location, topic_id):
        predictions = []
        
        
        for clf, weight in zip(self.classifiers, self.weights):
            if(clf.__class__.__name__ == 'OneClassSVM'):
                if(clf.predict(X) == -1):
                    predictions.append(0)
                else:
                    predictions.append(weight * clf.predict(X))
            elif(clf.__class__.__name__ == 'AnomalyDetector'):
                predictions.append(weight * clf.predict( location, topic_id))
            else:
                predictions.append(weight * clf.predict(X)[0])
        
        
        #print(predictions)
        return int(np.sum(predictions) > 0.5)


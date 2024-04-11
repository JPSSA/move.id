import pickle
import csv
import os
import numpy as np
from datetime import datetime
from sklearn.model_selection import GridSearchCV

class VotingClassifier:
    def __init__(self, result_file='classifiers.csv', models_dir='models'):
        self.result_file = result_file
        self.models_dir = models_dir

        # Cria o diretório se não existir
        if not os.path.exists(self.models_dir):
            os.makedirs(self.models_dir)

        # Cria o arquivo CSV se não existir
        if not os.path.exists(self.result_file):
            with open(self.result_file, 'w', newline='') as csvfile:
                writer = csv.writer(csvfile)
                writer.writerow(['Classifier', 'Score', 'Model_File'])

    def add_classifier(self, classifier, parameters, X_train, y_train):
        clf_name = classifier.__class__.__name__
        now = datetime.now()
        model_file = self.models_dir +'/' + clf_name + '_model_'+ now.strftime("%d_%m_%Y_%H_%M_%S") +'.p'

        clf = GridSearchCV(classifier, parameters, cv=5, scoring='accuracy')
        clf.fit(X_train, y_train)

        best_clf = clf.best_estimator_
        best_score = clf.best_score_


        # Salva o classificador em um arquivo pickle
        with open(model_file, 'wb') as f:
            pickle.dump(best_clf, f)

        # Atualiza o arquivo CSV
        with open(self.result_file, 'r') as csvfile:
            data = list(csv.reader(csvfile))

        # Procura e atualiza a linha correspondente ao classificador
        updated = False
        for i, row in enumerate(data):
            if row[0] == clf_name:
                data[i][1] = best_score
                data[i][2] = model_file
                updated = True
                break

        # Se o classificador não existir no CSV, adicione-o
        if not updated:
            data.append([clf_name, best_score, model_file])


        # Escreve os dados atualizados de volta ao arquivo CSV
        with open(self.result_file, 'w', newline='') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerows(data)

    def delete_classifier(self, classifier):
        clf_name = classifier.__class__.__name__

            # Read the CSV file and filter rows based on the classifier
        with open(self.result_file, 'r') as file:
            reader = csv.reader(file)
            rows = [row for row in reader if row[0] != clf_name]
    
        # Write the filtered rows back to the CSV file
        with open(self.result_file, 'w', newline='') as file:
            writer = csv.writer(file)
            writer.writerows(rows)
    
    def predict(self, X):
        predictions = []
        classifiers = []
        scores = []
        
        
        with open(self.result_file, 'r') as csvfile:
            reader = csv.reader(csvfile)
            next(reader)  # Pula o cabeçalho
            for row in reader:
                model_file = row[2]
                scores.append(float(row[1]))
                with open(model_file, 'rb') as f:
                    clf = pickle.load(f)
                    classifiers.append(clf)

        total_scores = np.sum(scores)

        weights = []
        
        for score in scores:
            weights.append(score/total_scores)
        
        for clf, weight in zip(classifiers, weights):
            if(clf.__class__.__name__ == 'OneClassSVM'):
                if(clf.predict(X) == -1):
                    predictions.append(0)
                else:
                    predictions.append(weight * clf.predict(X))
            else:
                predictions.append(weight * clf.predict(X))
        return int(np.sum(predictions) > 0.5)


import pickle

print('import')

with open('features.pickle', 'rb') as f:
    features = pickle.load(f)
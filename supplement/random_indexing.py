import string
import itertools

import numpy as np


class Features:
    def __init__(self, features, D=10_000):
        assert (D % 2) == 0, 'D must be even.'
        self.D = D

        self.features = {l: i for i, l in enumerate(features)}
        
        self.labels = np.ones((len(self.features), self.D))
        self.labels[:, :self.D // 2] = -1
        
        for i in range(len(self.labels)):
            np.random.shuffle(self.labels[i])
            
        assert not self.labels.sum(axis=1).any()
        
        self.permutation = np.random.permutation(self.D)
        
    def __getitem__(self, key):
        return np.array(self.labels[self.features[key]])


def vectorize_naive(text, window_length, features):
    window = np.zeros((window_length, features.D))

    text = itertools.chain([''], text, [''])
    
    for _i, letter in enumerate(text):
        i = _i % window_length

        window[i] = features[letter]
        
        if _i == 0:
            continue
        
        for _j in range(1, window_length):
            j = (window_length + i - _j) % window_length
            window[j] = window[j][features.permutation]
        
        if _i >= window_length - 1:
            yield window.prod(axis=0)


def vectorize(text, window_length, features):
    n_permutations = features.permutation
    for _ in range(window_length - 2):
        n_permutations = n_permutations[features.permutation]
    
    window = np.zeros(window_length, dtype=str)
    text = itertools.chain([''], text, [''])

    result = features[next(text)]
    
    for _i, letter in  enumerate(text, start=1):
        i = _i % window_length
        prev = window[i]
        window[i] = letter

        if _i > i:
            result *= features[prev][n_permutations]

        result = result[features.permutation]
        result *= features[letter]
        
        if _i + 1 >= window_length:
            yield np.array(result)
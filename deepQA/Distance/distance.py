from keras import backend as K


def city_block(y_pred, y_true):
    return K.sum(K.abs(y_pred-y_true))

def chebyshev(y_pred, y_true):
    return K.max(L.abs(y_pred - y_true))

def minkowski(y_pred, y_true):
    assert len(y_pred) == len(y_true)
    p = len(y_pred)
    return K.sum(K.abs(x-y).^p) ^ (1/p)

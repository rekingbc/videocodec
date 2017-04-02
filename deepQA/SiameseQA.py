from __future__ import absolute_import
from __future__ import print_function
import numpy as np
np.random.seed(1337)  # for reproducibility


import random
from keras.models import Sequential, Model
from keras.layers import Dense, Dropout, Input, Lambda, Activation, Flatten
from keras.layers import Convolution2D, MaxPooling2D,BatchNormalization, AveragePooling2D
from keras.regularizers import l2, activity_l2
from keras.optimizers import RMSprop,Adagrad
#from keras.metrics import kullback_leibler_divergence
from keras import backend as K
from datasets.tid import load_data


def euclidean_distance(vects):
    x, y = vects
    testK =  K.sqrt(K.sum(K.square(x - y), axis=1, keepdims=True)) / 256
    return testK

def eucl_dist_output_shape(shapes):
    shape1, shape2 = shapes
    return (shape1[0], 1)


def contrastive_loss(y_true, y_pred):
    '''Contrastive loss from Hadsell-et-al.'06
    http://yann.lecun.com/exdb/publis/pdf/hadsell-chopra-lecun-06.pdf
    '''
    margin = 1
    return K.mean(y_true * K.square(y_pred) + (1 - y_true) * K.square(K.maximum(margin - y_pred, 0)))


def create_pairs(x, digit_indices):
    '''Positive and negative pair creation.
    Alternates between positive and negative pairs.
    '''
    pairs = []
    labels = []
    n = min([len(digit_indices[d]) for d in range(10)]) - 1
    for d in range(10):
        for i in range(n):
            z1, z2 = digit_indices[d][i], digit_indices[d][i + 1]
            pairs += [[x[z1], x[z2]]]
            inc = random.randrange(1, 10)
            dn = (d + inc) % 10
            z1, z2 = digit_indices[d][i], digit_indices[dn][i]
            pairs += [[x[z1], x[z2]]]
            labels += [1, 0]
    return np.array(pairs), np.array(labels)

def create_compare(x_train, x_ref):
    pairs = []
    labels = []
    for i in xrange(25):
        for j in xrange(120):
            pairs += [[x_train[120*i+j], x_ref[i]]]

    return np.array(pairs)



def create_base_network(input_shape):
    '''Base network to be shared (eq. to feature extraction).
    '''
    seq = Sequential()

    seq.add(Convolution2D(32, 5, 5, border_mode='same',
                input_shape=input_shape))
    seq.add(Activation('relu'))
    seq.add(Convolution2D(32, 5, 5))
    seq.add(BatchNormalization())
    seq.add(Activation('relu'))
    seq.add(MaxPooling2D(pool_size=(5, 5), strides=(2, 2)))
    seq.add(Dropout(0.25))
    seq.add(Convolution2D(64, 3, 3))
    seq.add(BatchNormalization())
    seq.add(Activation('relu'))
    seq.add(Convolution2D(64, 3, 3))
    seq.add(BatchNormalization())
    seq.add(Activation('relu'))
    seq.add(AveragePooling2D(pool_size=(2, 2),strides=(2, 2)))
    seq.add(Dropout(0.25))
    seq.add(Flatten())
    seq.add(Dense(256))
    return seq





def compute_accuracy(predictions, labels):
    '''Compute classification accuracy with a fixed threshold on distances.
    '''
    return labels[predictions.ravel() < 0.5].mean()


# the data, shuffled and split between train and test sets
DistortImg, DistortLabel, RefImg, RefLabel, ScoreLabel = load_data()




# create training+test positive and negative pairs
'''digit_indices = [np.where(y_train == i)[0] for i in range(10)]
tr_pairs, tr_y = create_pairs(X_train, digit_indices)

digit_indices = [np.where(y_test == i)[0] for i in range(10)]
te_pairs, te_y = create_pairs(X_test, digit_indices)'''

all_pairs = create_compare(DistortImg, RefImg)

X_train = all_pairs[1:2001]
X_test =  all_pairs[2000:]

Y_train = ScoreLabel[1:2001]
Y_test = ScoreLabel[2000:]

Y_quant = DistortLabel

input_dim = 224,224
nb_epoch = 10
input_shape = (224,224,3)
ScoreLabel = np.array(ScoreLabel)
ScoreLabel = ScoreLabel / 10
# network definition
base_network = create_base_network(input_shape)

input_a = Input(shape=input_shape)
input_b = Input(shape=input_shape)

# because we re-use the same instance `base_network`,
# the weights of the network
# will be shared across the two branches
processed_a = base_network(input_a)
processed_b = base_network(input_b)

distance = Lambda(euclidean_distance, output_shape=eucl_dist_output_shape)([processed_a, processed_b])

model = Model(input=[input_a, input_b], output=distance)

'''x_train1 = np.expand_dims(X_train[:,0], axis=3)
x_train2 = np.expand_dims(X_train[:,1], axis=3)
x_test1 = np.expand_dims(X_test[:,0], axis=3)
x_test2 = np.expand_dims(X_test[:,1], axis=3)'''
x_valid1 = all_pairs[:,0]
x_valid2 = all_pairs[:,1]
validLabel = ScoreLabel[1:1001]

print (x_valid1[500])


'''x_train1 /= 255
x_train2 /= 255
x_test1 /= 255
x_test2 /= 255'''
x_valid1 /= 255
x_valid2 /= 255

# train
#rms = RMSprop()
adagrad=Adagrad(lr=0.01, epsilon=1e-08, decay=0.0)
#model.compile(loss='mean_squared_error', optimizer=rms)
model.compile(loss='mean_squared_error', optimizer=adagrad)
model.fit( [x_valid1, x_valid2], ScoreLabel,
          validation_split=0.01,
          batch_size=30,
          nb_epoch=500)
print (x_valid1[500])

final_predict = model.predict([x_valid1, x_valid2],batch_size=30)
final_file = open('/home/jianj/project/videocodec/deepQA/datasets/predict2.txt', 'w')
#print ("The final prediction: " ,final_predict)
for item in final_predict:
  final_file.write("%f\n" % item)
final_file.close()

# compute final accuracy on training and test sets
'''pred = model.predict([X_train[:, 0], X_train[:, 1]])
tr_acc = compute_accuracy(pred, tr_y)
pred = model.predict([X_test[:, 0], X_test[:, 1]])
te_acc = compute_accuracy(pred, te_y)

print('* Accuracy on training set: %0.2f%%' % (100 * tr_acc))
print('* Accuracy on test set: %0.2f%%' % (100 * te_acc))'''

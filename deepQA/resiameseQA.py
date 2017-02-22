from __future__ import absolute_import
from __future__ import print_function
import numpy as np
np.random.seed(1337)  # for reproducibility


import random
from keras.models import Sequential, Model
from keras.layers import  Lambda
from keras.layers import Input, Dense, Embedding, Reshape, GRU, merge, LSTM, Dropout, BatchNormalization, Activation, Flatten
from keras.layers import ZeroPadding2D, AveragePooling2D, Convolution2D, MaxPooling2D, merge, Input
from keras.regularizers import l2, activity_l2
from keras.optimizers import RMSprop
from keras import backend as K
from datasets.tid import load_data



def identity_block(input_tensor, kernel_size, filters, stage, block):
    '''The identity_block is the block that has no conv layer at shortcut
    # Arguments
        input_tensor: input tensor
        kernel_size: defualt 3, the kernel size of middle conv layer at main path
        filters: list of integers, the nb_filters of 3 conv layer at main path
        stage: integer, current stage label, used for generating layer names
        block: 'a','b'..., current block label, used for generating layer names
    '''
    nb_filter1, nb_filter2, nb_filter3 = filters
    if K.image_dim_ordering() == 'tf':
        bn_axis = 3
    else:
        bn_axis = 1
    conv_name_base = 'res' + str(stage) + block + '_branch'
    bn_name_base = 'bn' + str(stage) + block + '_branch'

    x = Convolution2D(nb_filter1, 1, 1, name=conv_name_base + '2a')(input_tensor)
    x = BatchNormalization(axis=bn_axis, name=bn_name_base + '2a')(x)
    x = Activation('relu')(x)

    x = Convolution2D(nb_filter2, kernel_size, kernel_size,
                      border_mode='same', name=conv_name_base + '2b')(x)
    x = BatchNormalization(axis=bn_axis, name=bn_name_base + '2b')(x)
    x = Activation('relu')(x)

    x = Convolution2D(nb_filter3, 1, 1, name=conv_name_base + '2c')(x)
    x = BatchNormalization(axis=bn_axis, name=bn_name_base + '2c')(x)

    x = merge([x, input_tensor], mode='sum')
    x = Activation('relu')(x)
    return x


def conv_block(input_tensor, kernel_size, filters, stage, block, strides=(2, 2)):

    nb_filter1, nb_filter2, nb_filter3 = filters
    if K.image_dim_ordering() == 'tf':
        bn_axis = 3
    else:
        bn_axis = 1
    conv_name_base = 'res' + str(stage) + block + '_branch'
    bn_name_base = 'bn' + str(stage) + block + '_branch'

    x = Convolution2D(nb_filter1, 1, 1, subsample=strides,
                      name=conv_name_base + '2a')(input_tensor)
    x = BatchNormalization(axis=bn_axis, name=bn_name_base + '2a')(x)
    x = Activation('relu')(x)

    x = Convolution2D(nb_filter2, kernel_size, kernel_size, border_mode='same',
                      name=conv_name_base + '2b')(x)
    x = BatchNormalization(axis=bn_axis, name=bn_name_base + '2b')(x)
    x = Activation('relu')(x)

    x = Convolution2D(nb_filter3, 1, 1, name=conv_name_base + '2c')(x)
    x = BatchNormalization(axis=bn_axis, name=bn_name_base + '2c')(x)

    shortcut = Convolution2D(nb_filter3, 1, 1, subsample=strides,
                             name=conv_name_base + '1')(input_tensor)
    shortcut = BatchNormalization(axis=bn_axis, name=bn_name_base + '1')(shortcut)

    x = merge([x, shortcut], mode='sum')
    x = Activation('relu')(x)
    return x


def ResNet50(include_top=True,
             input_tensor=None):
    # Determine proper input shape
    if K.image_dim_ordering() == 'th':
        if include_top:
            input_shape = (1, 96, 128)
        else:
            input_shape = (1, None, None)
    else:
        if include_top:
            input_shape = (96, 128, 1)
        else:
            input_shape = (None, None, 1)

    if input_tensor is None:
        img_input = Input(shape=input_shape)
    else:
        if not K.is_keras_tensor(input_tensor):
            img_input = Input(tensor=input_tensor)
        else:
            img_input = input_tensor
    if K.image_dim_ordering() == 'tf':
        bn_axis = 3
    else:
        bn_axis = 1

    x = ZeroPadding2D((3, 3))(img_input)
    x = Convolution2D(32, 3, 3, subsample=(2, 2), name='conv1')(x)
    x = BatchNormalization(axis=bn_axis, name='bn_conv1')(x)
    x = Activation('relu')(x)
    x = MaxPooling2D((3, 3), strides=(2, 2))(x)

    x = conv_block(x, 3, [32, 32, 64], stage=2, block='a', strides=(1, 1))
    x = identity_block(x, 3, [32, 32, 64], stage=2, block='b')
    x = identity_block(x, 3, [32, 32, 64], stage=2, block='c')
    x = identity_block(x, 3, [32, 32, 64], stage=2, block='d')
    x = AveragePooling2D((3, 3), name='avg_pool')(x)


    if include_top:
        x = Flatten()(x)

    model = Model(img_input, x)

    return model


def euclidean_distance(vects):
    x, y = vects
    return K.sqrt(K.sum(K.square(x - y), axis=1, keepdims=True))


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

    seq.add(Convolution2D(32, 3, 3, border_mode='same',
                input_shape=input_shape))
    seq.add(Activation('relu'))
    seq.add(Convolution2D(32, 3, 3))
    seq.add(Activation('relu'))
    seq.add(MaxPooling2D(pool_size=(3, 3), strides=(2, 2)))
    seq.add(Dropout(0.25))

    seq.add(Convolution2D(64, 3, 3))
    seq.add(Activation('relu'))
    seq.add(Convolution2D(64, 3, 3))
    seq.add(Activation('relu'))
    seq.add(MaxPooling2D(pool_size=(2, 2),strides=(2, 2)))
    seq.add(Dropout(0.25))

    seq.add(Flatten())
    seq.add(Dense(512))
    seq.add(Activation('relu'))
    seq.add(Dense(512))
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



input_dim = 96,128
nb_epoch = 20
input_shape = (96,128,1)

# network definition
base_network = ResNet50(include_top=True,
             input_tensor=None)

input_a = Input(shape=input_shape)
input_b = Input(shape=input_shape)

# because we re-use the same instance `base_network`,
# the weights of the network
# will be shared across the two branches
processed_a = base_network(input_a)
processed_b = base_network(input_b)

distance = Lambda(euclidean_distance, output_shape=eucl_dist_output_shape)([processed_a, processed_b])

model = Model(input=[input_a, input_b], output=distance)

x_train1 = np.expand_dims(X_train[:,0], axis=3)
x_train2 = np.expand_dims(X_train[:,1], axis=3)
x_test1 = np.expand_dims(X_test[:,0], axis=3)
x_test2 = np.expand_dims(X_test[:,1], axis=3)
x_valid1 = np.expand_dims(all_pairs[:,0], axis=3)
x_valid2 = np.expand_dims(all_pairs[:,1], axis=3)


x_train1 /= 255
x_train2 /= 255
x_test1 /= 255
x_test2 /= 255
x_valid1 /= 255
x_valid2 /= 255

# train
rms = RMSprop()
model.compile(loss="mean_squared_error", optimizer=rms)
model.fit( [x_valid1, x_valid2], ScoreLabel,
          validation_split=0.0, shuffle=True,
          batch_size=30,
          nb_epoch=nb_epoch)


final_predict = model.predict([x_valid1, x_valid2],batch_size=30)
final_file = open('/Users/rwa56//videocodec/deepQA/datasets/predict.txt', 'w')
for item in final_predict:
  final_file.write("%d\n" % item)
final_file.close()


# compute final accuracy on training and test sets
'''pred = model.predict([X_train[:, 0], X_train[:, 1]])
tr_acc = compute_accuracy(pred, tr_y)
pred = model.predict([X_test[:, 0], X_test[:, 1]])
te_acc = compute_accuracy(pred, te_y)

print('* Accuracy on training set: %0.2f%%' % (100 * tr_acc))
print('* Accuracy on test set: %0.2f%%' % (100 * te_acc))'''

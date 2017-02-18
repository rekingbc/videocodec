from __future__ import absolute_import
import numpy as np
import sys
import os
from keras.preprocessing.image import ImageDataGenerator, array_to_img, img_to_array, load_img
import cPickle as pickle
import re
from scipy import linalg
import scipy.ndimage as ndi
from six.moves import range
from keras import backend as K
from PIL import Image
import threading
import warnings
import theano

def load_data():
    dirname='/Users/rwa56/Downloads/tid2013/'
    distortion='distorted_images/'
    reference='reference_images/'
    score='mos.txt'

    size= 128, 128

    DistortImg = []
    RefImg = []
    DistortLabel = []
    RefLabel = []
    label = [0, 0, 0]

    for root, dirs, filenames in os.walk(dirname+distortion):
        for imgfile in filenames:
            img = Image.open(root+imgfile, 'r')
            #print img.getbands()
            #x = img_to_array(img)
            img.thumbnail(size, Image.ANTIALIAS)

            x0 = np.asarray(img, dtype=theano.config.floatX)
            #x = x.reshape((1,) + x.shape)
            #print 'The imgfile is' +imgfile
            x = 0.2126 * x0[:,:,0] + 0.7152 * x0[:,:,1] + 0.0722 * x0[:,:,2]
            #print  x.shape
            DistortImg.append(x)
            if(len(imgfile) < 12):
                print 'The file: ' + imgfile
            label[0] = int(imgfile[1:3])
            label[1] = int(imgfile[4:6])
            label[2] = int(imgfile[7])
            #print label
            DistortLabel.append(label)


    for root, dirs, filenames in os.walk(dirname+reference):
        for imgfile in filenames:
            #print filename
            img = Image.open(root+imgfile, 'r')
            #print img.getbands()
            #x = img_to_array(img)
            img.thumbnail(size, Image.ANTIALIAS)

            x0 = np.asarray(img, dtype=theano.config.floatX)
            #x = x.reshape((1,) + x.shape)
            #print 'The imgfile is' +imgfile
            x = 0.2126 * x0[:,:,0] + 0.7152 * x0[:,:,1] + 0.0722 * x0[:,:,2]
            RefImg.append(x)
            label[0] = int(imgfile[1:3])
            RefLabel.append(label)
            #print label


    ScoreLabel = open(dirname+score).read().splitlines()
    ScoreLabel = map(float, ScoreLabel)
    #print ScoreLabel

    print DistortImg[1]

    return DistortImg, DistortLabel, RefImg, RefLabel, ScoreLabel

"""    distortfile = open("Distort.pkl",'wb')
    pickle.dump(DistortImg, distortfile)
    distortfile.close()

    distortlabel = open("Label_distort.pkl","wb")
    pickle.dump(DistortLabel,distortlabel)
    distortlabel.close()

    reffile = open("Reference.pkl", "wb")
    pickle.dump(RefImg, reffile)
    reffile.close()

    reflabel = open('Label_ref.pkl', "wb")
    pickle.dump(RefLabel, reflabel)
    reflabel.close()"""




def main():
    load_data()

    return 0

if __name__ == '__main__':
    sys.exit(main())

from __future__ import absolute_import
import numpy as np
import sys
import os
from keras.preprocessing.image import ImageDataGenerator, array_to_img, img_to_array, load_img
import cPickle as pickle

def load_data():
    dirname='/Users/rwa56/Downloads/tid2013/'
    distortion='distorted_images/'
    reference='reference_images/'

    DistortImg = []
    RefImg = []
    DistortLabel = []
    RefLabel = []
    label = [0, 0, 0]

    for root, dirs, filenames in os.walk(dirname+distortion):
        for imgfile in filenames:
            img = load_img(root+imgfile)
            x = img_to_array(img)
            #x = x.reshape((1,) + x.shape)
            print 'The imgfile is' +imgfile
            DistortImg.append(x)
            if(len(imgfile) < 12):
                print 'The file: ' + imgfile
            label[0] = int(imgfile[1:3])
            label[1] = int(imgfile[4:6])
            label[2] = int(imgfile[7])
            print label
            DistortLabel.append(label)


    for root, dirs, filenames in os.walk(dirname+reference):
        for imgfile in filenames:
            #print filename
            img = load_img(root+imgfile)
            x = img_to_array(img)
            x = x.reshape((1,) + x.shape)
            RefImg.append(x)
            label[0] = int(imgfile[1:3])
            RefLabel.append(label)
            print label

    distortfile = open("Distort.pkl",'wb')
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
    reflabel.close()




def main():
    load_data()

    return 0

if __name__ == '__main__':
    sys.exit(main())

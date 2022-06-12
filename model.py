
import re
from matplotlib import image
import numpy as np

import pandas as pd
from collections import Counter
import os
import tensorflow as tf
from keras.preprocessing.sequence import pad_sequences
from keras.preprocessing.text import Tokenizer
from keras.models import Model
from keras.layers import Flatten, Dense, LSTM, Dropout, Embedding, Activation
from keras.layers import concatenate, BatchNormalization, Input
from keras.layers.merge import add
from keras.utils import to_categorical, plot_model
from keras.applications.inception_v3 import InceptionV3, preprocess_input
import matplotlib.pyplot as plt 
# import cv2

import ResNet50,preprocess_input,decode_predictions


caption_file = "./Flicker8k/text/Flickr8k.token.txt"
capps = []
with open (caption_file) as f:
	 capps =  f.readlines ()
capps = [x.strip() for x in capps]



descriptions_dictionary = {}
for x in capps:
    image_id , cap  = x.split('\t')
	image_id  = image_id .split('.')[0]
	if image_id  not in descriptions_dictionary.keys():
		descriptions_dictionary[image_id ] = [] 
	descriptions_dictionary  = [image_id ].append(cap)

for key, caps in descriptions_dictionary.items(): 
	for i in range (len (caps)):
		caps[i] = re.sub("[^a-z]+", "", caps[i])
		caps[i]  = caps [i].lower()
words_list = []  #allwords
for key in descriptions_dictionary.keys():
    _ = [words_list.append(i) 
for cap in descriptions_dictionary [key] for i in cap.split()]


freq = dict(Counter (words_list)) 
freq = sorted(freq.items(),reverse= True, key= lambda x:x[1])
threshold = 15
freq = [x for x in freq if x[1]>threshold]
words_list = [x[0] for x in freq]

train_file="./Flickr8k/text/Flickr_8k.trainImages.txt" 
t_file  = "./Flickr8k/text/Flickr_8k.t Images.txt"

with open (train_file) as f:
	cap_train  = f.readlines()
cap_train = [x.strip() for x in cap_train]
with open (t_file) as f:
	cap_t =  f.readlines()
cap_t  = [x.strip() for x in cap_t]
train= [r.split(".")[0] for r in cap_train] 
t =  [r.split(".") [0] for r in cap_t]
train_desc = {} 
maximum_caption_length = -1
for image_id  in train:
    train_desc[image_id ] = []
    for caption in descriptions_dictionary [image_id ]:
        train_desc[image_id ].append("#START# " + caption + " #STOP#")
		maximum_caption_length = max (maximum_caption_length,len (caption.split())+1)


model =  ResNet50(weights = "imagenet", input_shape=(224,224,3))
model.summary()

model_new = Model(model.input, model.layers[-2].output)

def encode_image(img):
    img= image.load_img (img, target_size=(224,224))
    img= np.expand_dims (img, axis=0)
    img =  image.img_to_array(img) 
	img = preprocess_input (img)
	feature_vector  = feature_vector.reshape((-1,)) 
	return feature_vector


img_data = "./Flickr8k/dataset/images/"

train_encoded =  {}
for ix, image_id  in enumerate (train):
    path = img_data+"/"+image_id  + ".jpg"
	train_encoded[image_id ] = encode_image(path) 
	if ix%100 == 0: 
		print(".", end="")

t_en = {}
for i, image_id  in enumerate (t):
	path=img_data+"/"+ image_id  + ".jpg" 
	t_en[image_id ] = encode_image(path) 
	if 1100 - 0:
		print(".", end="")

words_index = {}
index_word_dic = {}
for i, word in enumerate (words_list): 
	words_index [word]=i+1 
	index_word_dic[i+1] = word

words_index[len(index_word_dic)] = "#START#"
words_index ["#START#"] = len(index_word_dic)
index_word_dic[len (index_word_dic)] = "#STOP#" 
words_index["STOP"] = len(index_word_dic)


f = open("./glove/glove.68.50d.txt", encoding='utf8')

em = {}#embaddings 
for line in f:
    words =  line.split() 
	word_em = np.array (words [1:], dtype='float') 
	em[words[0]] = word_em
f.close()


embedding_matrix =  np.zeros((len (words_index) + 1, 50))
for word, index in words_index.items(): 
	embedding_vector =  em. get (word)
    if embedding_vector is not None: 
		embedding_matrix[index] = embedding_vector

in_img_feats = Input (shape=(2048,))
in_img_1=Dropout (0.3) (in_img_feats)
in_img_2=Dense (256, activation='relu') (in_img_1)	


in_caps = Input(shape =(maximum_caption_length, ))
in_cap_1 = Embedding(input_dim=len (words_index) + 1,
output_dim=50, mask_zero=True)(in_caps)
in_cap_2 = Dropout (0.3)(in_cap_1) 
in_cap_3 = LSTM (256)(in_cap_2)

decoder_1  = add ([in_img_2, in_cap_3])
decoder_2 =  Dense (256, activation= 'relu') (decoder_1)
outputs =  Dense(len (words_index) + 1, activation='softmax') (decoder_2)

model =  Model(inputs=[in img feats, in caps], outputs=outputs)]
model.summary=()


model.layers[2].set_weights([embedding matrix])
model.layers[2].trainable = False

model.compile(loss='categorical_crossentropy', optimizer='adam')


def data_generator(train_descs, train_encoded, words_index, maximum_caption_length, batch_size):
X1, X2, y =  [], [], []
n=0
while True:
   for key, desc_list in train_descs.items():
    n += 1
    photo = train_encoded [key] 
	for desc in desc_list:
        seq= [word index map[word] for word in if word in words_index]
        for i in range (1, len (seq)):
            xi = seq[0:1]
            yi = seq[i]
            xi = pad_sequences([xi],
        maximum_length = maximum_caption_length, value = 0, padding = 'post')[0] 
		yi = to_categorical([yi],
        num_classes=len (words_index) + 1) [0]
        X1.append (photo)
        X2.append(xi)
        y.append(yi)
        if n==batch_size:
            yield[[np.array (X1), np.array (X2)],
            np.array (y)]
        X1, X2, y = 11, 0, 0
		n = 0


size_of_batch = 3
steps = len(train_desc)//size_of_batch


generator = date_generator(train_desc, train_encoded, words_index, maximum_caption_length, batch_size) 
model.fit_generator (generator, epochs=1, steps_per_epoch=steps, verbose=1)
model.save('./model_weights/model.h5')
#!/bin/bash

#
# Prepping on the labelled wav files
#

# clear prepped dir 
labelled=`pwd`/labelled
prepped=`pwd`/prepped
if [ ! -e $prepped ]; then
  mkdir $prepped
fi
rm -rf ${prepped}/*

# prep for each label
for label in `ls ${labelled}`; do

  # data augmentation on each wav
  mkdir ${prepped}/${label}
  echo "Normalizing on ${label}..."
  for wav in `ls ${labelled}/${label}`; do
    for ((i=-7; i != -2; i++)); do # norm from -7 to -3 db
      sox --norm=$i ${labelled}/${label}/${wav} ${prepped}/${label}/norm${i}_${wav} 
    done
  done 

  echo "Generating spectrogram for ${label}..."
  # convert to spectrogram (channels=1, 16k, remove legends, high-color)
  for wav in `ls ${prepped}/${label}`; do
    sox ${prepped}/${label}/${wav} -c 1 -n rate 16k spectrogram -r -h -o ${prepped}/${label}/${wav}.png
  done
  rm ${prepped}/${label}/*.wav
 
done

# create zip file
echo "Creating prepped.zip file..."
cd ${prepped}
rm -f ../prepped.zip
zip -r ../prepped.zip *
echo "Finished."


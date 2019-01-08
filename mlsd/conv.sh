#!/bin/bash

# clear prepped dir 
labelled=`pwd`/labelled
orig=`pwd`/labelled.bak

# prep for each label
for label in `ls ${orig}`; do

  # data augmentation on each wav
  for wav in `ls ${orig}/${label}`; do
    echo "Converting ${wav}"
    if [ ! -e ${labelled}/${label} ]; then
      mkdir ${labelled}/${label}
    fi
    sox ${orig}/${label}/${wav} -c 1 -r 16000 ${labelled}/${label}/${wav}  
  done 
done



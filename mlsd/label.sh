#!/bin/bash

#
# labelling on the recorded wav files
#

# create labelled dir 
recorded=`pwd`/recorded
labelled=`pwd`/labelled
if [ ! -e ${labelled} ]; then
  mkdir ${labelled}
fi

# labelling the files
label="0"
while [ `ls ${recorded}/*.wav 2> /dev/null | wc -w` -gt 0 ]; do

  # play a file and ask its label
  filename=`ls ${recorded} | sort | head -n 1`
  echo -n "Label for ${filename} (r: replay, d: delete): "
  aplay -q ${recorded}/${filename} &
  read -e -i ${label} label
  echo ${label}

  # replay
  if [ ${label} = "r" ]; then
    continue
  fi

  # delete
  if [ ${label} = "d" ]; then
    rm ${recorded}/${filename}
    continue 
  fi

  # labelling (mkdir for each label and move the file)
  if [ ! -e ${labelled}/${label} ]; then
    mkdir ${labelled}/${label}
  fi 
  mv ${recorded}/${filename} ${labelled}/${label}/${filename} 

done
echo "Labelling ended."


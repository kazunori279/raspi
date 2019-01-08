#!/bin/bash

#
# Post processing (for recording or detection) on raw wav files 
# 

# file id for this process
id=`date +%Y%m%d-%H%M%S`
filepath=`pwd`/${id}

# create recorded dir if needed
recorded=`pwd`/recorded
if [ ! -e ${recorded} ]; then
  mkdir ${recorded}
fi 

# remove older raw wav files
wavs=`pwd`/raw_*.wav
while [ `ls ${wavs} | wc -w` -gt 3 ]
do
  first=`ls ${wavs} | sort | head -n 1`
  rm ${first}
done

# merge two 1 sec files into one 2 sec file
sox -V1 `ls ${wavs} | sort | head -n 2` ${filepath}.wav

# trim silence from the beginning 
# (change the % value to adjust sound detecting threshold)
sox -V1 ${filepath}.wav ${filepath}_tr.wav silence 1 0.1 3%

# if there's no sound or sound is shorter than 1 sec, skip it 
filesize=`cat ${filepath}_tr.wav | wc -c`
if [ ${filesize} -le 64000 ]; then
  rm ${filepath}*
  echo -n "."
  exit 0
fi

# trim after the first 1 sec
sox -V1 ${filepath}_tr.wav ${filepath}_out.wav trim 0 1

# if it's duplicated, skip it 
prevfile=`pwd`/prev.wav
if [ -e $prevfile ]; then
  cmp -s ${filepath}_out.wav $prevfile 
  if [ $? = 0 ]; then
    rm ${filepath}*
    echo -n "d"
    exit 0     
  fi
fi
cp ${filepath}_out.wav $prevfile

# if it's recoding, move the wav file to recorded dir
if [ $1 = "record" ]; then
  mv ${filepath}_out.wav ${recorded}
  rm ${filepath}*.wav 
  echo -n "*"
fi

# if it's detecting, call AutoML API for detection
if [ $1 = "detect" ]; then

  # showing the listening pic
  pics=`pwd`/pics
  sudo fbi -T 2 -d /dev/fb1 -noverbose -a ${pics}/listening.png &> /dev/null

  # normalize and convert the wav to a spectrogram
  sox --norm=-3 ${filepath}_out.wav ${filepath}_norm.wav 
  sox ${filepath}_norm.wav -c 1 -n rate 16k spectrogram -r -h -o ${filepath}.png
  rm ${filepath}*.wav

  # convert the png to base64
  img_bytes=`cat ${filepath}.png | base64`
  rm ${filepath}.png

  # build a request.json
  echo -n "{ 'payload': {'image': {'imageBytes': '" > api_request.json
  echo -n "${img_bytes}" >> api_request.json
  echo -n "'}, }}" >> api_request.json 

  # get access token
  if [ ! -e access_token ]; then
    export GOOGLE_APPLICATION_CREDENTIALS="/home/pi/key.json" # specify key path
    echo `gcloud auth application-default print-access-token` > access_token
  fi

  # call API
  curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer `cat access_token`" https://automl.googleapis.com/v1beta1/projects/gcp-samples2/locations/us-central1/models/ICN3551748946371148672:predict -d @api_request.json > api_response.json

  # get detected label  
  label=`cat api_response.json | grep "displayName" | sed -r 's/.*"displayName": "(.*)".*/\1/'`
  score=`cat api_response.json | grep "score" | sed -r 's/.*"score": (0\...).*/\1/'`
  echo
  echo "detected: ${label}, score: ${score} "

  # ignore labels with score less than 0.7 
  if [ `echo ${score} | sed -r "s/0.([0-6])[0-9]/low/"` = "low" ]; then
    label="0"
  fi

  # show the pic 
  sudo fbi -T 2 -d /dev/fb1 -noverbose -a ${pics}/${label}.png &> /dev/null
  sleep 3
  sudo fbi -T 2 -d /dev/fb1 -noverbose -a ${pics}/black.png &> /dev/null
  sudo killall fbi 

fi


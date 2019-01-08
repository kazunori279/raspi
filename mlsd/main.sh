#!/bin/bash

#
# Run a continuous loop for recording or detecting sounds
#
# For recording:
#   ./main.sh record
#
# For detecting:
#   ./main.sh detect
#

# start continuous recording 
echo "Started."
arecord -V1 --max-file-time 1 --use-strftime raw_%Y%m%d-%H%M%S.wav -q -c 1 -D plughw:1,0 -r 16000 -f S32_LE &

# repeat post-recording process every second
while :
do
  sleep 1
  ./post_process.sh $1 &
done


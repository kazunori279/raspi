#!/bin/bash

#
# removes duplicated and small wav files from labelled dir.
#

labelled=`pwd`/labelled
for label in `ls ${labelled}`; do
  wavs=`ls ${labelled}/${label} | sort`
  dups=""
  smalls=""
  while [ `echo $wavs | wc -w` -gt 1 ]; do

    # compare two files
    first=`echo $wavs | sed "s/ .*//"`
    second=`echo $wavs | sed "s/[^ ]* //" | sed "s/ .*//"` 
    echo "Comparing ${first} with ${second}"
    cmp -s ${labelled}/${label}/${first} ${labelled}/${label}/${second}
    if [ $? = 0 ]; then
      dups="${dups} ${labelled}/${label}/${first}"
    fi 

    # remove small files
    if [ `cat ${labelled}/${label}/${first} | wc -c` -lt 64000 ]; then
      smalls="${smalls} ${labelled}/${label}/${first}"
    fi 

    # next wav
    wavs=`echo $wavs | sed "s/[^ ]* //"`
  done
  echo "${label} has `echo ${dups} | wc -w` dups"
  echo "${label} has `echo ${smalls} | wc -w` smalls"
  rm ${dups} 
  rm ${smalls}
done



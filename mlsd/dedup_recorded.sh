#!/bin/bash

dir=`pwd`/recorded
wavs=`ls ${dir} | sort`
dups=""
while [ `echo $wavs | wc -w` -gt 1 ]; do
  first=`echo $wavs | sed "s/ .*//"`
  second=`echo $wavs | sed "s/[^ ]* //" | sed "s/ .*//"` 
  cmp -s ${dir}/${first} ${dir}/${second}
  if [ $? = 0 ]; then
    dups="${dups} ${dir}/${first}"
  fi 
  wavs=`echo $wavs | sed "s/[^ ]* //"`
done

echo "Found `echo ${dups} | wc -w` dups"
rm ${dups} 


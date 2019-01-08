# mlsd: raspi sound detector with AutoML Vision

## scripts

- main.sh: run a continuous loop for recording or detecting
- label.sh: labelling on the recorded wav files
- prep.sh: prepping on the labelled wav files

## usage

- Install `zip` and [sox](http://sox.sourceforge.net/)
- Make sure you can record sound with `arecord` and your USB microphone
- Run `./main.sh record` to start recording sounds
- Run `./label.sh` to play each sound and add labels
- Run `./prep.sh` to do data prep on the labelled sounds
- Download `prepped.zip`, upload it to AutoML Vision and train it
- Edit `post_process.sh` to set your model ID for AutoML prediction
- Set up credential key for AutoML access with [the document](https://cloud.google.com/vision/automl/docs/using-the-api)
- Run `./main.sh detect` to start detecting sounds


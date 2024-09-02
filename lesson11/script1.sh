#!/bin/bash
DIR=~/myfolder
sudo mkdir -p $DIR

if [ -d "$DIR" ]; then
  # Change the ownershop of a directory
  sudo chown -R $(id -u):$(id -g) $DIR

  # Create a text file with timestamp
  TIME=$(date +"%Y-%m-%d %H:%M:%S")
  sudo echo -e "Hello\n${TIME}" > $DIR/first

  # Create empty file and change file permissions to 777
  sudo touch $DIR/second
  sudo chmod 777 $DIR/second

  # Generate random string and save to file
  RANDOM_STRING=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
  echo "$RANDOM_STRING" > $DIR/third

  # Create empty files
  sudo touch $DIR/fourth
  sudo touch $DIR/fifth
fi


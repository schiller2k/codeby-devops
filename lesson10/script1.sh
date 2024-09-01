#!/bin/bash
DIR=~/myfolder
sudo mkdir -p $DIR

if [ -d "$DIR" ]; then
  sudo chown -R $(id -u):$(id -g) $DIR

  TIME=$(date +"%Y-%m-%d %H:%M:%S")
  sudo echo -e "Hello\n${TIME}" > $DIR/first

  sudo touch $DIR/second
  chmod 777 $DIR/second

  RANDOM_STRING=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
  echo "$RANDOM_STRING" > $DIR/third

  sudo touch $DIR/fourth
  sudo touch $DIR/fifth
fi


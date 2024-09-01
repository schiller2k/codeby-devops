#!/bin/bash
DIR=~/myfolder

if [ -d "$DIR" ]; then
  files_count=$(find "$DIR" -type f | wc -l)
  echo "Count files: $files_count"
  
  if [ -e "$DIR/second" ]; then
     chmod 664 $DIR/second
  fi
  
  find "$DIR" -type f -empty -exec rm {} \;

  for file in "$DIR"/*; do
    if [ -f "$file" ]; then
        head -n 1 "$file" > "$file.tmp"
        mv "$file.tmp" "$file"
    fi
  done
fi


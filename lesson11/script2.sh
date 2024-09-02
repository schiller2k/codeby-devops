#!/bin/bash
DIR=~/myfolder

if [ -d "$DIR" ]; then
  # Count files in selected folder
  files_count=$(find "$DIR" -type f | wc -l)
  echo "Count files: $files_count"
  
  # Change file permissions of the second file
  if [ -e "$DIR/second" ]; then
     chmod 664 $DIR/second
  fi
  
  # Remove empty files
  find "$DIR" -type f -empty -exec rm {} \;

  # Truncate files and save their with first line
  for file in "$DIR"/*; do
    if [ -f "$file" ]; then
        head -n 1 "$file" > "$file.tmp"
        mv "$file.tmp" "$file"
    fi
  done
fi


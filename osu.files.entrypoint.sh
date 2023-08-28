#!/bin/sh

TAR_NAME="$(basename "$FILES_URL")"
DIR_NAME="$(basename "$FILES_URL" .tar.bz2)"

TAR_PATH=./"$TAR_NAME"
DIR_PATH=./"$DIR_NAME"

if [ -d "$DIR_PATH" ]; then
  echo File Dump Directory "$DIR_PATH" Exists!
else
  echo File Dump Directory "$DIR_PATH" Doesn\'t Exist!
  # If not, then, check if the tar.bz2 is there
  if [ ! -f "$TAR_PATH" ]; then
    # If not, then download it
    echo File Dump Tar "$TAR_PATH" Doesn\'t Exist!
    echo Downloading from "$FILES_URL"
    wget -O "$(basename "$TAR_NAME")" "$FILES_URL"
  fi

  echo Extracting "$TAR_PATH"
  tar -xjf "$TAR_PATH" -C ./ || exit 1

  echo Completed Extraction. Remove tar ball "$TAR_PATH"
  rm "$TAR_PATH"
fi

/bin/sh

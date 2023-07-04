#!/bin/sh

if [ "$(find . -maxdepth 2 -iname '*.osu')" ]; then
  echo "Files already exist, skipping download"
else
  echo "Downloading osu! files"
  wget -O "$(basename "$FILE_NAME")" "$FILE_NAME"

  echo "Extracting osu! files"
  tar -xf "$(basename "$FILE_NAME")"

  echo "Remove tarball"
  rm "$(basename "$FILE_NAME")"
fi

/bin/sh

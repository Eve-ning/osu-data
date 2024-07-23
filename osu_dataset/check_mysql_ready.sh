#!/bin/bash

max_attempts=$1
attempt=0
while ((attempt < max_attempts))
do
  # Check if osu-data is running
  if [[ $(docker inspect --format='{{json .State.Health.Status}}' osu.mysql) == "\"healthy\"" ]]; then
    exit 0
  fi
  echo "Waiting for MySQL to be ready... Attempt $attempt of $max_attempts"
  sleep 10
  ((attempt++))
done
exit 1
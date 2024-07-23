#!/bin/bash

max_attempts=$1
attempt=0
while ((attempt < max_attempts))
do
  # Check if osu-data is running
  if docker ps --format '{{.Names}}' | grep -q "^osu.mysql$"; then
    # Check if MySQL is ready
    if docker logs osu.mysql 2>&1 | grep -q "ready for connections.*port: 3308"; then
      exit 0
    fi
  fi
  echo "Waiting for MySQL to be ready... Attempt $attempt of $max_attempts"
  sleep 10
  ((attempt++))
done
exit 1
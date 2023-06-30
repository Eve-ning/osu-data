FROM ubuntu:22.04

ARG FILE_NAME
ARG WORKDIR

WORKDIR $WORKDIR

# Updates our repo
# Downloads the file via curl
# Extracts (tar) the file
# Removes tar file
# Removes all unwanted .sql files
# Cleans up repo files
RUN apt-get update \
 && apt-get install -y curl tar bzip2 \
 && curl $FILE_NAME -o $(basename "$FILE_NAME") \
 && tar -xf $(basename "$FILE_NAME") \
 && rm $(basename "$FILE_NAME") \
 && rm -rf /var/cache/apt/lists

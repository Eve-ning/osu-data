FROM ubuntu:20.04
ARG FILE_URL
ARG FILE_NAME

RUN apt-get update && apt-get install -y curl tar bzip2

# Download from url
RUN curl $FILE_URL -o $FILE_NAME

# Extract tar.bz2
RUN tar -xf $FILE_NAME

# Move extracted .sql up to docker init directory
RUN mv **/*.sql ./

RUN rm $FILE_NAME
RUN rmdir $(basename $FILE_NAME .tar.bz2)

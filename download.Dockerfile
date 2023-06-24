FROM ubuntu:22.04

# File name of the downloadable.
# E.g. 2023_06_01_performance_catch_top_1000.tar.bz2
ARG FILE_NAME
ARG WORKDIR

WORKDIR $WORKDIR

RUN if [ -z "$FILE_NAME" ]; \
    then echo "FILE_NAME must be set. E.g. " && exit 1; \
    else echo "Downloading from https://data.ppy.sh/${FILE_NAME}"; \
    fi

RUN apt-get update  \
    && apt-get install -y curl tar bzip2 \
    && curl https://data.ppy.sh/${FILE_NAME} -o $FILE_NAME \
    && tar -xf $FILE_NAME \
    && find . -type f -name "*.sql" -exec mv -t . {} + \
    && rm $FILE_NAME \
    && rm -rf ./*/ \
    && rm -rf /var/cache/apt/lists

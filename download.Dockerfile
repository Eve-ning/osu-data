FROM ubuntu:20.04
ARG PROJECT_DIR
ARG FILE_PATH
WORKDIR /$PROJECT_DIR

RUN apt-get update && apt-get install -y curl tar bzip2
RUN echo
# RUN curl $FILE_PATH -o data.tar.bz2
COPY test.tar.bz2 data.tar.bz2
RUN tar -xf data.tar.bz2
RUN rm data.tar.bz2
#    fi

#https://data.ppy.sh/2023_06_01_performance_catch_top_1000.tar.bz2
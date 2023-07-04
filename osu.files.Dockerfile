FROM alpine:latest
ARG FILE_NAME
ARG WORKDIR

ENV FILE_NAME=$FILE_NAME

WORKDIR $WORKDIR

RUN apk add --no-cache tar bzip2

COPY osu.files.dl.entrypoint.sh /osu.files.dl.entrypoint.sh
ENTRYPOINT ["/osu.files.dl.entrypoint.sh"]

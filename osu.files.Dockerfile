FROM alpine:latest
ARG FILES_URL
ARG WORKDIR

ENV FILES_URL=$FILES_URL \
    DEBUG=$DEBUG

WORKDIR $WORKDIR

RUN apk add --no-cache tar bzip2

COPY osu.files.entrypoint.sh /osu.files.entrypoint.sh

RUN ["chmod", "+x", "/osu.files.entrypoint.sh"]
ENTRYPOINT ["/osu.files.entrypoint.sh"]

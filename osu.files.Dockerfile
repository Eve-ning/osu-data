FROM alpine:latest
ARG FILES_URL

ENV FILES_URL=$FILES_URL

RUN apk add --no-cache tar bzip2

COPY osu.files.entrypoint.sh /osu.files.entrypoint.sh
COPY osu.files.healthcheck.sh /osu.files.healthcheck.sh

RUN ["chmod", "+x", "/osu.files.entrypoint.sh"]
ENTRYPOINT ["/osu.files.entrypoint.sh"]

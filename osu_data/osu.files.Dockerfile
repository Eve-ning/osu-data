FROM nginx:alpine
ARG FILES_URL

ENV FILES_URL=$FILES_URL

RUN apk add --no-cache tar bzip2

COPY nginx/local.conf /etc/nginx/conf.d/default.conf
COPY nginx/404.html /usr/share/nginx/html/404.html
COPY osu.files.entrypoint.sh /osu.files.entrypoint.sh
COPY osu.files.healthcheck.sh /osu.files.healthcheck.sh

RUN ["chmod", "+x", "/osu.files.entrypoint.sh"]
RUN ["chmod", "+x", "/osu.files.healthcheck.sh"]
ENTRYPOINT ["/osu.files.entrypoint.sh"]

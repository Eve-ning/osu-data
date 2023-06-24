FROM ubuntu:22.04

# File name of the downloadable.
# E.g. 2023_06_01_performance_catch_top_1000.tar.bz2
ARG FILE_NAME
ARG WORKDIR
ARG OSU_BEATMAP_DIFFICULTY=1
ARG OSU_BEATMAPS=1
ARG OSU_BEATMAPSETS=1
ARG OSU_COUNTS=1
ARG OSU_DIFFICULTY_ATTRIBS=1
ARG OSU_SCORES_=1
ARG OSU_USER_STATS_=1
ARG OSU_BEATMAP_DIFFICULTY_ATTRIBS=0
ARG OSU_BEATMAP_FAILTIMES=0
ARG OSU_BEATMAP_PERFORMANCE_BLACKLIST=0
ARG OSU_USER_BEATMAP_PLAYCOUNT=0
ARG SAMPLE_USERS=0


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
    && if [ $OSU_BEATMAP_DIFFICULTY = "0" ];            then rm -f osu_beatmap_difficulty.sql; fi \
    && if [ $OSU_BEATMAPS = "0" ];                      then rm -f osu_beatmaps.sql; fi \
    && if [ $OSU_BEATMAPSETS = "0" ];                   then rm -f osu_beatmapsets.sql; fi \
    && if [ $OSU_COUNTS = "0" ];                        then rm -f osu_counts.sql; fi \
    && if [ $OSU_DIFFICULTY_ATTRIBS = "0" ];            then rm -f osu_difficulty_attribs.sql; fi \
    && if [ $OSU_SCORES = "0" ];                        then rm -f osu_scores_*_high.sql; fi \
    && if [ $OSU_USER_STATS = "0" ];                    then rm -f osu_user_stats_*.sql; fi \
    && if [ $OSU_BEATMAP_DIFFICULTY_ATTRIBS = "0" ];    then rm -f osu_beatmap_difficulty_attribs.sql; fi \
    && if [ $OSU_BEATMAP_FAILTIMES = "0" ];             then rm -f osu_beatmap_failtimes.sql; fi \
    && if [ $OSU_BEATMAP_PERFORMANCE_BLACKLIST = "0" ]; then rm -f osu_beatmap_performance_blacklist.sql; fi \
    && if [ $OSU_USER_BEATMAP_PLAYCOUNT = "0" ];        then rm -f osu_user_beatmap_playcount.sql; fi \
    && if [ $SAMPLE_USERS = "0" ];                      then rm -f sample_users.sql; fi \
    && rm -rf /var/cache/apt/lists \
    && rm -rf ./*/

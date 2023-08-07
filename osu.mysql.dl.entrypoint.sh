#!/bin/sh

TAR_NAME="$(basename "$DB_URL")"
DIR_NAME="$(basename "$DB_URL" .tar.bz2)"

TAR_PATH=./"$TAR_NAME"
DIR_PATH=./"$DIR_NAME"

MYSQL_INIT_PATH=../osu.mysql
if [ -d "$MYSQL_INIT_PATH" ]; then
  rm "$MYSQL_INIT_PATH"/*
fi
mkdir -p "$MYSQL_INIT_PATH"

echo DB_URL: "$DB_URL"
echo TAR_NAME: "$TAR_NAME"
echo DIR_NAME: "$DIR_NAME"

# Firstly, check if we have the required files in our volume cache
if [ -d "$DIR_PATH" ]; then
  echo DB Dump Directory "$DIR_PATH" Exists!
else
  echo DB Dump Directory "$DIR_PATH" Doesn\'t Exist!
  # If not, then, check if the tar.bz2 is there
  if [ ! -f "$TAR_PATH" ]; then
    # If not, then download it
    echo DB Dump Tar "$TAR_PATH" Doesn\'t Exist!
    echo Downloading from "$DB_URL"
    wget -O "$(basename "$TAR_NAME")" "$DB_URL"
  fi

  echo Extracting "$TAR_PATH"
  tar -xjvf "$TAR_PATH" -C ./ || exit 1

  echo Completed Extraction. Remove tar ball "$TAR_PATH"
  rm "$TAR_PATH"
fi

# Here, we guarantee that we have our .sql in $DIR_PATH
# We move the sql files to our MySQL init path
echo Moving Files to MySQL Initialization Directory
if [ "$OSU_BEATMAP_DIFFICULTY" = "1" ]; then cp "$DIR_PATH"/osu_beatmap_difficulty.sql "$MYSQL_INIT_PATH"/; fi
if [ "$OSU_BEATMAPS" = "1" ]; then cp "$DIR_PATH"/osu_beatmaps.sql "$MYSQL_INIT_PATH"/; fi
if [ "$OSU_BEATMAPSETS" = "1" ]; then cp "$DIR_PATH"/osu_beatmapsets.sql "$MYSQL_INIT_PATH"/; fi
if [ "$OSU_COUNTS" = "1" ]; then cp "$DIR_PATH"/osu_counts.sql "$MYSQL_INIT_PATH"/; fi
if [ "$OSU_DIFFICULTY_ATTRIBS" = "1" ]; then cp "$DIR_PATH"/osu_difficulty_attribs.sql "$MYSQL_INIT_PATH"/; fi
if [ "$OSU_SCORES" = "1" ]; then cp "$DIR_PATH"/osu_scores_*_high.sql "$MYSQL_INIT_PATH"/; fi
if [ "$OSU_USER_STATS" = "1" ]; then cp "$DIR_PATH"/osu_user_stats_*.sql "$MYSQL_INIT_PATH"/; fi
if [ "$OSU_BEATMAP_DIFFICULTY_ATTRIBS" = "1" ]; then cp "$DIR_PATH"/osu_beatmap_difficulty_attribs.sql "$MYSQL_INIT_PATH"/; fi
if [ "$OSU_BEATMAP_FAILTIMES" = "1" ]; then cp "$DIR_PATH"/osu_beatmap_failtimes.sql "$MYSQL_INIT_PATH"/; fi
if [ "$OSU_BEATMAP_PERFORMANCE_BLACKLIST" = "1" ]; then cp "$DIR_PATH"/osu_beatmap_performance_blacklist.sql "$MYSQL_INIT_PATH"/; fi
if [ "$OSU_USER_BEATMAP_PLAYCOUNT" = "1" ]; then cp "$DIR_PATH"/osu_user_beatmap_playcount.sql "$MYSQL_INIT_PATH"/; fi
if [ "$SAMPLE_USERS" = "1" ]; then cp "$DIR_PATH"/sample_users.sql "$MYSQL_INIT_PATH"/; fi

exit 0

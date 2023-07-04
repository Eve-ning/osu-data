#!/bin/sh

if [ "$(find . -maxdepth 1 -iname '*.sql')" ]
then
  echo "Files already exist, skipping download"
else
  echo "Downloading osu! database files"
  wget -O "$(basename "$FILE_NAME")" "$FILE_NAME"

  echo "Extracting osu! database files"
  tar -xf "$(basename "$FILE_NAME")"

  echo "Moving SQL files to top level directory"
  find . -type f -name "*.sql" -exec mv -t . {} +

  echo "Removing tarball"
  rm "$(basename "$FILE_NAME")"

  echo "Removing files that are not needed"
  if [ "$OSU_BEATMAP_DIFFICULTY" = "0" ]; then rm -f osu_beatmap_difficulty.sql; fi
  if [ "$OSU_BEATMAPS" = "0" ]; then rm -f osu_beatmaps.sql; fi
  if [ "$OSU_BEATMAPSETS" = "0" ]; then rm -f osu_beatmapsets.sql; fi
  if [ "$OSU_COUNTS" = "0" ]; then rm -f osu_counts.sql; fi
  if [ "$OSU_DIFFICULTY_ATTRIBS" = "0" ]; then rm -f osu_difficulty_attribs.sql; fi
  if [ "$OSU_SCORES" = "0" ]; then rm -f osu_scores_*_high.sql; fi
  if [ "$OSU_USER_STATS" = "0" ]; then rm -f osu_user_stats_*.sql; fi
  if [ "$OSU_BEATMAP_DIFFICULTY_ATTRIBS" = "0" ]; then rm -f osu_beatmap_difficulty_attribs.sql; fi
  if [ "$OSU_BEATMAP_FAILTIMES" = "0" ]; then rm -f osu_beatmap_failtimes.sql; fi
  if [ "$OSU_BEATMAP_PERFORMANCE_BLACKLIST" = "0" ]; then rm -f osu_beatmap_performance_blacklist.sql; fi
  if [ "$OSU_USER_BEATMAP_PLAYCOUNT" = "0" ]; then rm -f osu_user_beatmap_playcount.sql; fi
  if [ "$SAMPLE_USERS" = "0" ]; then rm -f sample_users.sql; fi
fi

/bin/sh

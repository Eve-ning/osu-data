# osu! Data on Docker
[![Docker Compose CI](https://github.com/Eve-ning/osu-data-docker/actions/workflows/docker-image.yml/badge.svg)](https://github.com/Eve-ning/osu-data-docker/actions/workflows/docker-image.yml)

>[!WARNING]
> Docker must be installed and running on your machine for this to work.
> If you're on Windows, you must have WSL2 installed and running.

Retrieving database data from https://data.ppy.sh/ and importing it into MySQL can be a time-consuming and complex task.
Extracting a large `.tar.bz2` file and setting up a new MySQL installation can pose challenges, particularly for
developers eager to quickly explore the data.

I've developed a docker compose project to

1) abstract away and automate these steps
2) serve MySQL database in a virtual machine (container)
3) (optional) additionally store all ranked/loved `.osu` files in a service
   - This service is optional and can be activated with the `-f` tag. 

## Get Started

**IMPORTANT**: You must **manually** recreate the MySQL Service if you changed the data used. 

1) Install via pip `pip install osu-data-docker`

2) Minimally, specify:
   - `-m`, `--mode`:
     The game mode to build the database with. `osu`, `taiko`, `catch` or `mania`
   - `-v`, `--version`:
     The database version. `top_1000`, `top_10000` or `random_10000`
   - (Optional) `-ym`, `--year_month`: 
     The year and month of the database in the format `YYYY_MM` Default uses the latest.
   - (Optional) `-p`, `--port`:
     The port to expose MySQL on. Default is `3308`
   - (Optional) `-f`, `--files`:
     Whether to download `.osu` files. Default is `False`

E.g.

```bash
osu-data -m osu -v top_1000 -ym 2023_08 -p 3308 -f
```

Optionally, you can specify which SQL files should be loaded. 
By default, it'll load the necessary files, which are specified below
by the boolean

- `--beatmap-difficulty-attribs`. False
- `--beatmap-difficulty`. False
- `--scores`. True
- `--beatmap-failtimes`. False
- `--user-beatmap-playcount`. False
- `--beatmaps`. True
- `--beatmapsets`. True
- `--user-stats`. True
- `--sample-users`. True
- `--counts`. True
- `--difficulty-attribs`. True
- `--beatmap-performance-blacklist`. True

3) Connect via your favorite tools on `localhost:<MYSQL_PORT>`

## `mysql.cnf`

The database is tuned to be fast in importing speed, thus some adjustment are required if you use want
ACID transactions. Notably, you should enable `innodb_doublewrite = 1` (or simply remove the line) to
re-enable the default behavior.

## Important Matters

1) Do not distribute the built images as per peppy's request.
   Instead, you can just share the code to build your image, which should yield the same result.
2) This database is meant to be for analysis, it's not tuned for production. Tweak `mysql.cnf` after importing
   for more MySQL customizations.
3) Finally, be mindful on conclusions you make from the data.

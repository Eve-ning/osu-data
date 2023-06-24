# osu! Data on Docker
[![Docker Compose CI](https://github.com/Eve-ning/osu-data-docker/actions/workflows/docker-image.yml/badge.svg)](https://github.com/Eve-ning/osu-data-docker/actions/workflows/docker-image.yml)

Retrieving database data from https://data.ppy.sh/ and importing it into MySQL can be a time-consuming and complex task.
Extracting a large `.tar.bz2` file and setting up a new MySQL installation can pose challenges, particularly for
developers eager to quickly explore the data.

I've developed a docker compose project to

1) abstract away and automate these steps
2) serve MySQL database in a virtual machine

## Get Started

1) Clone me

```bash
git clone https://github.com/Eve-ning/osu-data-docker.git
```

2) Setup what you need in the `.env` file
    - `MYSQL_PASSWORD` is exactly what it is. Note that it MUST adhere to certain requirements:
      https://dev.mysql.com/doc/refman/8.0/en/validate-password.html
    - `MYSQL_PORT` exposes this MySQL container to the `localhost`. This port is used by the host to connect to
      this container.
    - `FILE_NAME` is the file name to import from https://data.ppy.sh. It must include be the full URL including `.tar.bz2`.
    - `.TAR.BZ2` file names. These are the file names when you extract the `.tar.bz2`. To speed up importing,
      you can exclude importing certain files (by specifying `1`, else `0`).
      Field names are shown to describe the data they contain.
      By default, I've excluded some files deemed less useful and too large.
    - `WORKDIR`. This is used internally, doesn't have any effect.

```dotenv
MYSQL_PASSWORD=p@ssw0rd1
MYSQL_PORT=3307
FILE_NAME="https://data.ppy.sh/2023_06_01_performance_catch_top_1000.tar.bz2"
WORKDIR="downloads/"

# Sorted By File Size, Largest First.
OSU_BEATMAP_DIFFICULTY_ATTRIBS=0
OSU_BEATMAP_DIFFICULTY=0
OSU_BEATMAP_FAILTIMES=0
...
```

3) Compose Build and Up

```bash
docker compose up --build
```

4) Connect via your favorite tools on `localhost:<MYSQL_PORT>`
5) Shutdown the containers

```bash
docker compose down
```

## Then...

- Start up the database

```bash
docker compose up
```

- Change to another database.
  - Shutdown and remove volumes (volumes = MySQL data).
  - Change the `.env` `FILE_NAME` and build again.

```bash
docker compose down --volumes
docker compose up --build
```

- Shutdown containers and delete volumes (volumes = MySQL data)

```bash
docker compose down --volumes
```

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

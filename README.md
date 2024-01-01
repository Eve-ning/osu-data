# osu! Data on Docker

`pip install osu-data; osu-data -m mania -v top_1000 -ym YYYY_MM`

**Docker must be installed and running on your machine.**

Retrieves database data from https://data.ppy.sh/ and hosts it on a local MySQL
server.
Optionally, store all ranked/loved `.osu` files in a service with the `-f` tag.

## Get Started

**IMPORTANT**: MySQL data persists across runs.
Recreate the MySQL Service if you changed the data used.

1) Install via pip `pip install osu-data`

2) Minimally, specify:
    - `-m`, `--mode`:
      The game mode to build the database with. `osu`, `taiko`, `catch`
      or `mania`
    - `-v`, `--version`:
      The database version. `top_1000`, `top_10000` or `random_10000`
3) Optionally, specify:
    - `-ym`, `--year_month`:
      The year and month of the database in the format `YYYY_MM` Default uses
      the latest. We recommend to specify this to avoid issues where the data
      isn't ready on the start of each month.
    - `-p`, `--port`:
      The port to expose MySQL on. Default is `3308`
    - `-f`, `--files`:
      Whether to download `.osu` files.
    - `-np`, `--nginx-port`:
      The port to expose the nginx service on. Default is `8080`.
      Not used if `-f` is not specified.
    - `--...`:
      See below table, these are optional flags to include or exclude more
      data. **By specifying the flag, will INVERT the default value.**

| Option                            | Default Value |
|-----------------------------------|---------------|
| `--beatmap-difficulty-attribs`    | False         |
| `--beatmap-difficulty`            | False         |
| `--scores`                        | True          |
| `--beatmap-failtimes`             | False         |
| `--user-beatmap-playcount`        | False         |
| `--beatmaps`                      | True          |
| `--beatmapsets`                   | True          |
| `--user-stats`                    | True          |
| `--sample-users`                  | True          |
| `--counts`                        | True          |
| `--difficulty-attribs`            | True          |
| `--beatmap-performance-blacklist` | True          |

These options are chosen to be the most useful for analysis, and performance.

E.g.

```bash
osu-data \
  -m osu -v top_1000 -ym 2023_08 -p 3308 -f \
  --beatmap-difficulty 
```

- Download the top 1000 osu! standard beatmaps
- from August 2023
- expose MySQL on port 3308
- download `.osu` files
- include beatmap difficulty data

4) Connect on:
   - `localhost:<MYSQL_PORT>`
   - `localhost:<NGINX_PORT>` (if `-f` is specified)

## Common Issues

- **Docker daemon is not running**. Make sure that Docker is installed and
  running. If you're using Docker Desktop, make sure it's actually started.
- **MySQL Data isn't incorrect**. A few reasons
    - *Import was abruptly stopped*. This can cause some `.sql` files to be
      missing / incomplete. Delete the whole compose project and try again.
    - *Didn't specify the optional flags to include files*. By default, some
      `.sql` files are not loaded. Take a look at `osu-data -h` and specify the
      optional flags to include them.
    - *Data is outdated*. By default, on every re-run of `osu-data`, the data
      is
      preserved. To update the data, you must delete the whole compose project
      and try again.
- **wget: server returned error: HTTP/1.1 404 Not Found**. This happens when
  you try to pull a `YYYY_MM` that doesn't exist, and happens often when the
  data isn't yet ready on the start of each month.
  Check on https://data.ppy.sh/ to see which `YYYY_MM` are available.
- **`rm: can't remove '../osu.mysql.init/*'`**: This is safe to ignore.
- **MySQL Credentials**. By default, the MySQL doesn't have a password, so just
  use `root` as the username and leave the password blank.
- **No `files` service**. This is default, `files` service is optional and
  must be activated with the `-f` tag. `osu-data -h` for more info.

## `mysql.cnf`

The database is tuned to be fast in importing speed, thus shouldn't be used for
production. Notably, we set `innodb_doublewrite = 0` which can compromise
data integrity in the event of a crash. If you want to use this for production,
we recommend to set this up from this Git repo, and tweak `mysql.cnf`.

## Important Matters

1) Do not distribute the built images as per peppy's request.
   Instead, you can just share the code to build your image, which should yield
   the same result.
2) This database is meant to be for analysis, it's not tuned for production.
   Tweak `mysql.cnf` after importing
   for more MySQL customizations.
3) Finally, be mindful on conclusions you make from the data.
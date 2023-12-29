# osu! Data on Docker
[![Docker Compose CI](https://github.com/Eve-ning/osu-data-docker/actions/workflows/docker-image.yml/badge.svg)](https://github.com/Eve-ning/osu-data-docker/actions/workflows/docker-image.yml)

Retrieving database data from https://data.ppy.sh/ and importing it into MySQL can be a time-consuming and complex task.
Extracting a large `.tar.bz2` file and setting up a new MySQL installation can pose challenges, particularly for
developers eager to quickly explore the data.

I've developed a docker compose project to

1) abstract away and automate these steps
2) serve MySQL database in a virtual machine (container)
3) (optional) additionally store all ranked/loved `.osu` files in a service
   - This service is optional and can be activated with `docker compose --profile files up`. 

## Get Started

**IMPORTANT**: You must **manually** recreate the MySQL Service if you changed the data used. 

1) Install via pip `pip install osu-data-docker`

2) Setup what you need in the `.env` file
    - `MYSQL_PASSWORD` is exactly what it is. Note that it MUST adhere to certain requirements:
      https://dev.mysql.com/doc/refman/8.0/en/validate-password.html
    - `MYSQL_PORT` exposes the MySQL container the host via this port.
    - `DB_URL` is the Database URL to import from https://data.ppy.sh. Include the full URL including `.tar.bz2`.
    - `FILES_URL` is the Files URL to import from https://data.ppy.sh. Include the full URL including `.tar.bz2`.
    - `OSU_...`: To speed up importing, exclude certain files.
      Field names are shown to describe the data they contain.
      Default settings excludes files deemed less useful and too large.
   
For example, we can download the osu!catch database with all osu! files with this `.env`.
```dotenv
MYSQL_PASSWORD=p@ssw0rd1
MYSQL_PORT=3307
DB_URL=https://data.ppy.sh/2023_07_01_performance_catch_top_1000.tar.bz2
FILES_URL=https://data.ppy.sh/2023_07_01_osu_files.tar.bz2

# Excluded 
OSU_BEATMAP_DIFFICULTY_ATTRIBS=0
# Included 
OSU_BEATMAP_DIFFICULTY=1
# truncated ...
```

3) Compose Up with Build 

```bash
docker compose up --build  # For Database only
docker compose --build --profile files up  # For Database AND `.osu` files.
```

4) Connect via your favorite tools on `localhost:<MYSQL_PORT>`
5) Stop the containers

```bash
docker compose stop
```

## Updating Database

- Change to another database.
  - `docker compose down` to remove all containers
  - Update `.env` and build again.

```bash
docker compose down --volumes
docker compose up --build  # For Database only
docker compose --build --profile files up  # For Database AND `.osu` files.
```

- Shutdown containers and delete volumes (volumes = MySQL data and `.osu` files)

```bash
docker compose down --volumes
```

### Connecting via Terminal

Check the container names via `exec`. Container name found with `docker container ls`
```bash
docker exec -it <container_name> sh
```

Connect via MySQL. Default password is `p@ssw0rd1`

```
sh-4.4# mysql -u root -p 
Enter password: <PASSWORD>
mysql> use osu;
mysql> select * from osu_scores_fruits_high limit 10;
+----------+------------+---------+----------+ ...
| score_id | beatmap_id | user_id | score    | ...
+----------+------------+---------+----------+ ...
|       34 |      70915 |  489271 |  5312855 | ...
|      246 |      65233 |  489271 | 14784138 | ...
|  2900398 |      21014 |  129806 |   329618 | ...
|  2900572 |      29036 |  129806 |   678912 | ...
...
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

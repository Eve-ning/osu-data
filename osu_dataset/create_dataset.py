import argparse
import logging
import tarfile
from datetime import datetime
from pathlib import Path

import numpy as np
import pandas as pd
from icecream import ic
from sqlalchemy import create_engine

MAX = 320
CONN_STR = "mysql+pymysql://root@localhost:3308/osu"


def read_map_metadata(conn, sr_threshold=2.5):
    return (
        pd.read_sql(
            rf"""
        SELECT 
            beatmap_id AS mid,
            filename,
            countSlider,
            countNormal,
            approved,
            difficultyrating AS sr
        FROM osu_beatmaps
        WHERE playmode = 3
        AND difficultyrating > {sr_threshold} 
        """,
            conn,
        )
        .assign(
            ln_ratio=lambda x: x.countSlider / (x.countSlider + x.countNormal),
            mapname=lambda x: x.filename.str[:-4],
        )[["mid", "ln_ratio", "mapname", "approved", "sr"]]
        .drop_duplicates(subset=["mid"])
    )


def read_player_metadata(conn):
    return pd.read_sql(
        r"SELECT user_id AS uid, username FROM sample_users",
        conn,
    ).drop_duplicates(subset=["uid"])


def read_maps(conn, sr_threshold=2.5):
    return pd.read_sql(
        rf"""
        SELECT 
            beatmap_id AS mid,
            diff_size AS `keys`
        FROM osu_beatmaps
        WHERE playmode = 3
        AND difficultyrating > {sr_threshold}  
        """,
        conn,
    )[["mid", "keys"]].astype({"keys": int})


def read_plays(conn, score_threshold=600000):
    return pd.read_sql(
        rf"""
        SELECT 
            beatmap_id AS mid,
            user_id AS uid,
            count300, count100, count50, countmiss, countkatu, countgeki,
            enabled_mods, date 
        FROM osu_scores_mania_high WHERE score > {score_threshold}
        """,
        conn,
    ).assign(
        accuracy=lambda x: (
            x.countgeki * 1
            + x.count300 * 300 / MAX
            + x.countkatu * 200 / MAX
            + x.count100 * 100 / MAX
            + x.count50 * 50 / MAX
        )
        / (
            x.countgeki
            + x.count300
            + x.countkatu
            + x.count100
            + x.count50
            + x.countmiss
        ),
        speed=lambda x: (
            np.where(
                (x.enabled_mods & (1 << 6)) > 0,
                1,
                np.where((x.enabled_mods & (1 << 8)) > 0, -1, 0),
            )
        ),
        days_since_epoch=lambda x: (df["date"] - datetime(1970, 1, 1)).dt.days,
        # recover using: pd.to_datetime(x, unit="D")
    )[
        ["mid", "uid", "accuracy", "speed", "days_since_epoch"]
    ]


def create_dataset(
    tarball_path: Path,
    sr_threshold: float = 2.5,
    score_threshold: int = 600000,
):
    ic(
        f"Creating Dataset with "
        f"SR Threshold >={sr_threshold}, "
        f"Score Threshold >={score_threshold}"
    )
    ic(f"Connecting to MySQL at {CONN_STR}")
    conn = create_engine(
        CONN_STR, pool_pre_ping=True, pool_recycle=280, pool_timeout=300
    )

    score_path = Path("score_dataset.csv")
    player_metadata_path = Path("player_metadata.csv")
    map_metadata_path = Path("map_metadata.csv")

    ic("Score Dataset: Reading Maps")
    df_maps = read_maps(conn, sr_threshold)

    ic("Score Dataset: Reading Plays")
    df_plays = read_plays(conn, score_threshold)

    ic("Score Dataset: Merging Data")
    df_score = df_plays.merge(df_maps, on="mid")

    # For some reason, there are dupes, we'll remove the scores that are
    # poorer in accuracy
    ic("Score Dataset: Removing Duplicates")
    df_score = df_score.sort_values(
        "accuracy", ascending=False
    ).drop_duplicates(subset=["uid", "mid"], keep="first")

    ic("Score Dataset: Writing Dataset")
    df_score.to_csv(score_path, index=False)

    del df_maps, df_plays, df_score

    ic("Writing Player Metadata Dataset")
    read_player_metadata(conn).to_csv(player_metadata_path, index=False)

    ic("Writing Map Metadata Dataset")
    read_map_metadata(conn, sr_threshold).to_csv(
        map_metadata_path, index=False
    )

    ic(f"Creating Tarball at {tarball_path.as_posix()}")
    with tarfile.open(tarball_path, "w:bz2") as tar:
        tar.add(score_path)
        tar.add(map_metadata_path)
        tar.add(player_metadata_path)

    conn.dispose()


def main():
    logging.basicConfig(level=logging.INFO)
    parser = argparse.ArgumentParser(description="Create osu! Dataset")
    parser.add_argument("tar_path", type=str, help="Tarball Output Path")
    args = parser.parse_args()
    create_dataset(Path(args.tar_path))


if __name__ == "__main__":
    main()

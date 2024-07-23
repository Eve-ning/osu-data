import numpy as np
import pandas as pd
from tqdm import tqdm

MAX = 320
from sqlalchemy import create_engine

CONN_STR = "mysql+pymysql://root@localhost:3308/osu"


def read_maps(conn):
    df = pd.read_sql(
        r"SELECT * FROM osu_beatmaps WHERE playmode = 3 "
        r"AND difficultyrating > 2.5 ",
        conn,
    ).assign(
        ln_ratio=lambda x: x.countSlider / (x.countSlider + x.countNormal),
        mapname=lambda x: x.filename.str[:-4],
    )[
        [
            "beatmap_id",
            "ln_ratio",
            "mapname",
            "diff_size",
            "diff_overall",
            "approved",
            "difficultyrating",
            "playcount",
            "passcount",
        ]
    ]
    return df


def read_plays(conn):
    return pd.read_sql(
        r"SELECT * FROM osu_scores_mania_high WHERE score > 600000",
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
        year=lambda x: x.date.dt.year,
    )[
        [
            "score_id",
            "beatmap_id",
            "user_id",
            "score",
            "accuracy",
            "speed",
            "year",
            "pp",
        ]
    ]


def read_players(conn):
    return pd.read_sql(
        r"SELECT * FROM sample_users",
        conn,
    )[
        [
            "user_id",
            "username",
        ]
    ]


def merge(df_maps, df_plays, df_users):
    return (
        (
            df_plays.merge(df_maps, on="beatmap_id").merge(
                df_users, on="user_id"
            )
        )
        .rename(
            {
                "score_id": "sid",
                "beatmap_id": "mid",
                "user_id": "uid",
                "diff_size": "keys",
                "diff_overall": "od",
                "difficultyrating": "sr",
            },
            axis=1,
        )
        .set_index("sid")
    )


def write_dataset(df, conn):
    df.to_sql(
        "osu_dataset",
        conn,
        schema="osu",
        if_exists="replace",
    )


def create_dataset():
    conn = create_engine(CONN_STR, pool_pre_ping=True, pool_recycle=280,
                         pool_timeout=300)
    t = tqdm(total=6)

    t.set_description("Reading maps")
    df_maps = read_maps(conn)
    t.update(1)

    t.set_description("Reading plays")
    df_plays = read_plays(conn)
    t.update(1)

    t.set_description("Reading users")
    df_users = read_players(conn)
    t.update(1)

    t.set_description("Merging")
    df = merge(df_maps, df_plays, df_users).assign(
        rand=lambda x: np.random.uniform(0, 1, len(x)),
    )
    t.update(1)

    t.set_description("Removing duplicates")
    # For some reason, there are dupes, we'll remove the scores that are
    # poorer in accuracy
    df = df.sort_values("accuracy", ascending=False).drop_duplicates(
        subset=["uid", "mid"], keep="first"
    )
    t.update(1)

    t.set_description("Writing dataset")
    write_dataset(df, conn)
    t.update(1)

    t.close()
    conn.dispose()


if __name__ == "__main__":
    create_dataset()

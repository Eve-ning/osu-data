import sqlite3
import tarfile
from pathlib import Path

import pandas as pd
from sqlalchemy import create_engine


def main():
    CONN_STR = "mysql+pymysql://root@localhost:3308/osu"
    SQLITE_PATH = Path('osu.db')
    TARBALL_PATH = Path('osu.tar.bz2')
    TABLE = 'osu_dataset'

    mysql_engine = create_engine(CONN_STR)
    if SQLITE_PATH.exists():
        SQLITE_PATH.unlink()
    sqlite_engine = sqlite3.connect(SQLITE_PATH)
    print("Reading data from MySQL")
    df = pd.read_sql_table(TABLE, mysql_engine, index_col='sid')

    df_map = (
        df[['uid', 'keys', 'speed', 'mid', 'accuracy']]
        .drop_duplicates().reset_index(drop=True)
    )
    df_map_cast = df_map.astype({
        'uid': 'uint16',
        'keys': 'uint8',
        'speed': 'uint8',
        'mid': 'uint16',
        'accuracy': 'float32',
    })
    df_map_cast.to_sql('osu_map', sqlite_engine, if_exists='replace', )

    # Open a new tarfile in write mode with bzip2 compression
    with tarfile.open(TARBALL_PATH, 'w:bz2') as tar:
        # Add the osu.db file to the tarfile
        tar.add(SQLITE_PATH)


if __name__ == '__main__':
    main()
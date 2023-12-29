import argparse
import logging
import os
import subprocess
from datetime import datetime
from pathlib import Path

THIS_DIR = Path(__file__).parent
logger = logging.getLogger(__name__)


def main():
    parser = argparse.ArgumentParser(
        description="Spin up osu! Data on Docker. Any argument after FILES "
        "are booleans that determine if the SQL file should be "
        "loaded into the MySQL database.",
    )

    current_yyyy_mm = datetime.now().strftime("%Y_%m")
    parser.add_argument(
        "-m",
        "--mode",
        type=str,
        help="Game Mode as string",
        choices=["catch", "mania", "osu", "taiko"],
        required=True,
    )
    parser.add_argument(
        "-v",
        "--version",
        type=str,
        help="Version as string",
        choices=["top_1000", "top_10000", "random_10000"],
        required=True,
    )
    parser.add_argument(
        "-ym",
        "--year-month",
        type=str,
        help="Year and Month of the Dataset as YYYY_MM. Defaults to Current Year and Month.",
        default=f"{current_yyyy_mm}",
    )
    parser.add_argument(
        "-p",
        "--port",
        type=int,
        help="MySQL Port number",
        default=8080,
    )
    parser.add_argument(
        "-f",
        "--files",
        type=str,
        help="Whether to download the .osu files or not",
        choices=["1", "0"],
    )

    opt_kwargs = dict(type=str, choices=["1", "0"])

    parser.add_argument(
        "--beatmap-difficulty-attribs", **opt_kwargs, default="0"
    )
    parser.add_argument("--beatmap-difficulty", **opt_kwargs, default="0")
    parser.add_argument("--scores", **opt_kwargs, default="1")
    parser.add_argument("--beatmap-failtimes", **opt_kwargs, default="0")
    parser.add_argument("--user-beatmap-playcount", **opt_kwargs, default="0")
    parser.add_argument("--beatmaps", **opt_kwargs, default="1")
    parser.add_argument("--beatmapsets", **opt_kwargs, default="1")
    parser.add_argument("--user-stats", **opt_kwargs, default="1")
    parser.add_argument("--sample-users", **opt_kwargs, default="1")
    parser.add_argument("--counts", **opt_kwargs, default="1")
    parser.add_argument("--difficulty-attribs", **opt_kwargs, default="1")
    parser.add_argument(
        "--beatmap-performance-blacklist", **opt_kwargs, default="1"
    )
    args = parser.parse_args()

    logger.info(
        f"Starting osu! Data Docker. Serving MySQL on Port {args.port}"
    )

    compose_file_path = THIS_DIR / "docker-compose.yml"

    db_url = (
        f"https://data.ppy.sh/"
        f"{args.year_month}_01_performance_"
        f"{args.mode}_"
        f"{args.version}.tar.bz2"
    )
    files_url = f"https://data.ppy.sh/" f"{args.year_month}_osu_files.tar.bz2"

    os.environ["DB_URL"] = db_url
    os.environ["FILES_URL"] = files_url
    os.environ[
        "OSU_BEATMAP_DIFFICULTY_ATTRIBS"
    ] = args.beatmap_difficulty_attribs
    os.environ["OSU_BEATMAP_DIFFICULTY"] = args.beatmap_difficulty
    os.environ["OSU_SCORES"] = args.scores
    os.environ["OSU_BEATMAP_FAILTIMES"] = args.beatmap_failtimes
    os.environ["OSU_USER_BEATMAP_PLAYCOUNT"] = args.user_beatmap_playcount
    os.environ["OSU_BEATMAPS"] = args.beatmaps
    os.environ["OSU_BEATMAPSETS"] = args.beatmapsets
    os.environ["OSU_USER_STATS"] = args.user_stats
    os.environ["SAMPLE_USERS"] = args.sample_users
    os.environ["OSU_COUNTS"] = args.counts
    os.environ["OSU_DIFFICULTY_ATTRIBS"] = args.difficulty_attribs
    os.environ[
        "OSU_BEATMAP_PERFORMANCE_BLACKLIST"
    ] = args.beatmap_performance_blacklist

    # Run the Docker Compose file
    try:
        subprocess.run(
            f"docker compose -f {compose_file_path.as_posix()} up"
            f"{' --profile files' if args.files else ''}",
            check=True,
            shell=True,
            env=os.environ.copy(),
        )
    except KeyboardInterrupt:
        logger.info("Stopping osu! Data Docker")
        subprocess.run(
            f"docker compose -f {compose_file_path.as_posix()} stop",
            check=True,
            shell=True,
        )

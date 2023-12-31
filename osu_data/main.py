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
        help=f"Year and Month of the Dataset as YYYY_MM. "
             f"Defaults: {current_yyyy_mm}",
        default=f"{current_yyyy_mm}",
    )
    parser.add_argument(
        "-p",
        "--port",
        type=int,
        help="MySQL Port number. Default: 3308",
        default=3308,
    )
    parser.add_argument(
        "-f",
        "--files",
        help="Whether to download the .osu files or not. Default: false",
        action="store_true",
    )

    opt_kwargs = lambda x: dict(
        help=f"Default: {'true' if x == 'false' else 'false'}",
        action=f"store_{x}",
    )

    parser.add_argument("--beatmap-difficulty-attribs", **opt_kwargs("true"))
    parser.add_argument("--beatmap-difficulty", **opt_kwargs("true"))
    parser.add_argument("--scores", **opt_kwargs("false"))
    parser.add_argument("--beatmap-failtimes", **opt_kwargs("true"))
    parser.add_argument("--user-beatmap-playcount", **opt_kwargs("true"))
    parser.add_argument("--beatmaps", **opt_kwargs("false"))
    parser.add_argument("--beatmapsets", **opt_kwargs("false"))
    parser.add_argument("--user-stats", **opt_kwargs("false"))
    parser.add_argument("--sample-users", **opt_kwargs("false"))
    parser.add_argument("--counts", **opt_kwargs("false"))
    parser.add_argument("--difficulty-attribs", **opt_kwargs("false"))
    parser.add_argument("--beatmap-performance-blacklist",
                        **opt_kwargs("false"))
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
    os.environ["MYSQL_PORT"] = str(args.port)
    os.environ["OSU_BEATMAP_DIFFICULTY_ATTRIBS"] = (
        "1" if args.beatmap_difficulty_attribs else "0"
    )
    os.environ["OSU_BEATMAP_DIFFICULTY"] = (
        "1" if args.beatmap_difficulty else "0"
    )
    os.environ["OSU_SCORES"] = "1" if args.scores else "0"
    os.environ["OSU_BEATMAP_FAILTIMES"] = (
        "1" if args.beatmap_failtimes else "0"
    )
    os.environ["OSU_USER_BEATMAP_PLAYCOUNT"] = (
        "1" if args.user_beatmap_playcount else "0"
    )
    os.environ["OSU_BEATMAPS"] = "1" if args.beatmaps else "0"
    os.environ["OSU_BEATMAPSETS"] = "1" if args.beatmapsets else "0"
    os.environ["OSU_USER_STATS"] = "1" if args.user_stats else "0"
    os.environ["SAMPLE_USERS"] = "1" if args.sample_users else "0"
    os.environ["OSU_COUNTS"] = "1" if args.counts else "0"
    os.environ["OSU_DIFFICULTY_ATTRIBS"] = (
        "1" if args.difficulty_attribs else "0"
    )
    os.environ["OSU_BEATMAP_PERFORMANCE_BLACKLIST"] = (
        "1" if args.beatmap_performance_blacklist else "0"
    )

    logger.debug(args)

    # Run the Docker Compose file
    try:
        subprocess.run(
            f"docker compose -f {compose_file_path.as_posix()} "
            f"{' --profile files' if args.files else ''} "
            f"up --build",
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

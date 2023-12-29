import argparse
from pathlib import Path

THIS_DIR = Path(__file__).parent


def main():
    parser = argparse.ArgumentParser(description='Process some arguments.')
    parser.add_argument('-ym', '--year-month', type=str,
                        help='Year-Month string')
    parser.add_argument('-m', '--mode', type=str, help='Mode string')
    parser.add_argument('-v', '--version', type=str, help='Version string')
    parser.add_argument('-p', '--port', type=int, help='Port number')

    args = parser.parse_args()

    compose_file_path = THIS_DIR / "docker-compose.yml"

    # Print the arguments
    print(f'Year-Month: {args.year_month}')
    print(f'Mode: {args.mode}')
    print(f'Version: {args.version}')
    print(f'Port: {args.port}')


    # Run the Docker Compose file
    # subprocess.run(f"docker compose -f {compose_file_path.as_posix()} up",
    #                check=True, shell=True)


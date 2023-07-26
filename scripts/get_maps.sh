usage="\
Usage:
  $(basename "$0") [-q SQL_QUERY] [ -o OUTPUT_TAR ] [-h]

Description:
  This function pulls *.osu files from the osu.files service depending on SQL_QUERY results of osu.mysql
  and copies them to OUTPUT_TAR as a tar.bz2

  This function requires osu.mysql and osu.files services to be running.

Options:
  -q SQL_QUERY
    The query to run on the osu.mysql service.
    It must return a single column of beatmap_ids. The beatmap_ids are used to pull the files.
  -o OUTPUT_TAR
    The output tar file. The files are in the top level directory of the tar.
    E.g. osu_files.tar.bz2
         ├── 1.osu
         ├── 2.osu
         ├── 3.osu
  -h
    Show this help message and exit.
"

# Parse Arguments
while getopts ":q:o:h" opt; do
  case $opt in
  q)
    SQL_QUERY="$OPTARG"
    ;;
  o)
    OUTPUT_TAR="$OPTARG"
    ;;
  h)
    echo "$usage"
    exit 0
    ;;
  *)
    echo "Invalid option: -$OPTARG" >&2
    echo "$usage"
    exit 1
    ;;
  esac
done

if [ -z "$SQL_QUERY" ]; then
  echo "SQL_QUERY is not set!"
  echo "$usage"
  exit 1
fi

if [ -z "$OUTPUT_TAR" ]; then
  echo "OUTPUT_TAR is not set!"
  echo "$usage"
  exit 1
fi

# Check that osu.mysql and osu.files services are up
echo "Checking that osu.mysql and osu.files services are up..."
echo -n "osu.mysql: "
if docker ps --format '{{.Names}}' | grep -q 'osu.mysql'; then
  echo -e "\e[32mOK\e[0m"
else
  echo -e "\e[31mNOT RUNNING!\e[0m"
  exit 1
fi

echo -n "osu.files: "
if docker ps --format '{{.Names}}' | grep -q 'osu.files'; then
  echo -e "\e[32mOK\e[0m"
else
  echo -e "\e[31mNOT RUNNING!\e[0m"
  exit 1
fi

# Default values
OUTPUT_DIR="/tmp/osu-data-docker/$(date +%Y-%m-%d_%H-%M-%S)"
OUTPUT_FILES_DIR=$OUTPUT_DIR"/files"
mkdir -p "$OUTPUT_FILES_DIR"
MYSQL_PASSWORD=$(docker exec osu.mysql sh -c 'echo $MYSQL_ROOT_PASSWORD')

# filelist.txt is a file with the beatmap_ids of *.osu files to copy
FILELIST_PATH=$OUTPUT_DIR"/filelist.txt"

# Create file list locally
echo -e "\e[32mExecuting Query\e[0m"
FILES=$(docker exec osu.mysql mysql -u root --password="$MYSQL_PASSWORD" -D osu -N -e "$SQL_QUERY")
echo "$FILES" >"$FILELIST_PATH"

# Copy file list to osu.files
echo -e "\e[32mCopying files to osu.files directory...\e[0m"
docker exec osu.files mkdir -p "$OUTPUT_FILES_DIR" || exit 1
docker cp "$FILELIST_PATH" osu.files:"$FILELIST_PATH" || exit 1

# Loop through filelist.txt and copy files to OUTPUT_DIR
#   Retrieve <OSU_FILES_DIRNAME> /in osu.files/<OSU_FILES_DIRNAME>/*.osu
OSU_FILES_DIRNAME=$(basename "$(docker exec osu.files sh -c 'echo $FILES_URL')" .tar.bz2)
docker exec osu.files sh -c \
  '
  while read beatmap_id;
    do cp /osu.files/'"$OSU_FILES_DIRNAME"'/"$beatmap_id".osu '"$OUTPUT_FILES_DIR"'/"$beatmap_id".osu; >> /dev/null 2>&1;
    [ $? ] || echo "Beatmap ID $beatmap_id cannot be found in osu.files";
    done < '"$FILELIST_PATH"';
  '

echo -e "\e[32mCreating tar from $OUTPUT_DIR\e[0m"
docker exec osu.files sh -c "cd $OUTPUT_FILES_DIR; tar -cjf ../files.tar.bz2 . || exit 1"

echo -e "\e[32mCopying tar to host\e[0m"
docker cp osu.files:"$OUTPUT_FILES_DIR/../files.tar.bz2" "$OUTPUT_TAR" || exit 1

echo -e "\e[32mCompleted!\e[0m"

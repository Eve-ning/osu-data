# Checks the state of the files download & extraction
# Exit 0 if the download & extraction is done, else 1

# If there's no matching processlist, then it's done.
sleep 5 # Sleep is necessary just in case we're starting up

if ! (pgrep '^tar*' || pgrep '^wget*'); then
  exit 0
else
  exit 1
fi

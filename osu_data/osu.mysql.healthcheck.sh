# Checks the state of the importing.
# Exit 0 if the import is done, else 1

sleep 10;  # Sleep is necessary to ensure that the initialization has started.

if exec 6<>"/dev/tcp/localhost/$MYSQL_TCP_PORT"; then
  echo "MySQL is ready!"
else
  echo "MySQL is not ready!"
fi

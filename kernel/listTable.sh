#!/bin/bash 

echo "======================="
echo "+---- Tables Name ----+"
echo "======================="
line="                    "
# Function to list all tables

  # Check if the current database is set
  if [ -z "${DB_CURRENT}" ]; then
    echo "Error: no database selected."
  return
fi
echo "List of tables:"
ls "./databases/${DB_CURRENT}" | grep -v '\.$'

source ./database.sh
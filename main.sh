#!/bin/bash

# Define variables
DB_ROOT_DIR="databases"
DB_CURRENT=""

if [ ! -d "$DB_ROOT_DIR" ]; then
  mkdir -p "$DB_ROOT_DIR"
fi

# Define the main menu
function main_menu {
    while true
    do
    echo "Main Menu:"
    echo "1. Create Database"
    echo "2. List Databases"
    echo "3. Connect To Database"
    echo "4. Drop Database"
    echo "5. Exit"

    read choice

    case $choice in
        1)
            create_database
            ;;
        2)
            list_databases
            ;;
        3)
            connect_to_database
            ;;
        4)
            drop_database
            ;;
        5)
            exit 0
            ;;
        *)
            echo "Invalid choice."
            sleep 2
            main_menu
            ;;
    esac
    done
}

# Function to create a new database
create_database() {
  echo "Enter database name: " 
  read dbname
  if [[ -d "${DB_ROOT_DIR}/${dbname}" ]]; then
    echo "Database already exists."
  else
    mkdir "${DB_ROOT_DIR}/${dbname}"
    echo "Database created successfully."
  fi
}

# Function to list all databases
list_databases() {
  if [[ -z "$(ls -A ${DB_ROOT_DIR})" ]]; then
    echo "No databases found."
  else
    echo "Databases:"
    for db in ${DB_ROOT_DIR}/*; do
      echo " - $(basename ${db})"
    done
  fi
}

# Function to connect to a database
connect_to_database() {
  echo "Enter the name of the database to connect to:"
  read name
  # Check if the database exists
  if [ -d "${DB_ROOT_DIR}/${name}" ]; then
    # Set the current database variable
    DB_CURRENT="${name}"
    echo "Connected to database '${name}'."
    
    # table_menu
    #==================================#
    export DB_CURRENT
    source database.sh
    
  else
    echo "Error: database '${name}' does not exist."
  fi
}

# Function to drop a database
drop_database() {
  echo "Enter the name of the database to drop:"
  read name

  # Check if the database exists
  if [ -d "${DB_ROOT_DIR}/${name}" ]; then
    # Delete the database directory
    rm -r "${DB_ROOT_DIR}/${name}"
    echo "Database '${name}' dropped successfully."
  else
    echo "Error: database '${name}' does not exist."
  fi
}

# Define the table menu
function table_menu {
    while true
    do
    echo "Table Menu:"
    echo "1. Create Table"
    echo "2. List Tables"
    echo "3. Drop Table"
    echo "4. Insert into Table"
    echo "5. Select From Table"
    echo "6. Delete From Table"
    echo "7. Update Table"
    echo "8. Back to Main Menu"

    read choice

    case $choice in
        1)
            create_table
            ;;
        2)
            list_tables
            ;;
        3)
            drop_table
            ;;
        4)
            insert_into_table
            ;;
        5)
            select_from_table
            ;;
        6)
            delete_from_table
            ;;
        7)
            update_table
            ;;
        8)
            cd ..
            main_menu
            ;;
        *)
            echo "Invalid choice."
            sleep 2
            table_menu
            ;;
        
    esac
    done
}

# Function to create a new table
function create_table {
    echo "Enter the name of the table to create:"
    read tablename

    # Check if the table file already exists
    if [ -f "${DB_ROOT_DIR}/${DB_CURRENT}/${tablename}" ]; then
        echo "Table $tablename already exists"
        return 1
    fi

    # Prompt for column definitions
    echo "Enter the column names, separated by commas:"
    read colnames

    # Prompt for column data types
    echo "Enter the data types for the columns, separated by commas:"
    echo "Supported data types: int, string, float"
    read coltypes

    # Write column definitions to table file
    echo "$colnames" > "${DB_ROOT_DIR}/${DB_CURRENT}/${tablename}"
    echo "$coltypes" >> "${DB_ROOT_DIR}/${DB_CURRENT}/${tablename}"
    echo "Table $tablename created successfully"
}


# Function to list all tables
list_tables() {
  # Check if the current database is set
  if [ -z "${DB_CURRENT}" ]; then
    echo "Error: no database selected."
    return
  fi

  echo "List of tables:"
  ls "${DB_ROOT_DIR}/${DB_CURRENT}"
}

# Function to drop a table
drop_table() {
  read -p "Enter table name: " tablename
  if [[ ! -f "${DB_ROOT_DIR}/${DB_CURRENT}/${tablename}" ]]; then
    echo "Table not found."
  else
    rm "${DB_ROOT_DIR}/${DB_CURRENT}/${tablename}"
    echo "Table dropped successfully."
  fi
}


# Function to insert into a table
function insert_into_table {
  read -p "Enter table name: " tablename
  # Check if the table file exists
if [ ! -f "${DB_ROOT_DIR}/${DB_CURRENT}/${tablename}" ]; then
    echo "Table $tablename does not exist"
    return 1
fi

# Get column names and types from the first two lines of the file
colnames=$(head -n 1 ${DB_ROOT_DIR}/${DB_CURRENT}/${tablename})
coltypes=$(head -n 2 ${DB_ROOT_DIR}/${DB_CURRENT}/${tablename} | tail -n 1)

# Prompt for values to insert
echo "Enter the values to insert in the format '$colnames', separated by commas"
read values

# Check the number of values
numcols=$(echo "$colnames" | awk -F',' '{print NF}')
numvals=$(echo "$values" | awk -F',' '{print NF}')
if [ $numcols -ne $numvals ]; then
    echo "Error: expected $numcols values, got $numvals"
    return 1
fi

# Check the types of the values
IFS=',' read -r -a valarr <<< "$values"
IFS=',' read -r -a typearr <<< "$coltypes"
for i in "${!valarr[@]}"; do
    if [ "${typearr[$i]}" = "int" ] && ! [[ "${valarr[$i]}" =~ ^[0-9]+$ ]]; then
        echo "Error: expected an integer value for column ${i+1}"
        return 1
    elif [ "${typearr[$i]}" = "float" ] && ! [[ "${valarr[$i]}" =~ ^[0-9]+\.[0-9]+$ ]]; then
        echo "Error: expected a floating-point value for column ${i+1}"
        return 1
    elif [ "${typearr[$i]}" = "string" ] && ! echo "${valarr[$i]}" | grep -qE '^[[:alpha:]]+$'; then
        echo "Error: expected a string value for column ${i+1}"
        return 1
    fi
done

# Check for duplicate primary key
primarykey=$(echo "$colnames" | cut -d ',' -f 1 | head -n 1)
pkval=$(echo "$values" | cut -d ',' -f 1)
if grep -q "^$pkval," "${DB_ROOT_DIR}/${DB_CURRENT}/${tablename}"; then
    echo "Error: primary key value already exists"
    return 1
fi

# Write values to table file
echo "$values" >> "${DB_ROOT_DIR}/${DB_CURRENT}/${tablename}"
echo "Values inserted successfully"
}

# Function to select rows from a table
function select_from_table {
 echo "Enter the name of the table to select from:"
    read tablename

    # Check if the table file exists
    if [ ! -f "${DB_ROOT_DIR}/${DB_CURRENT}/${tablename}" ]; then
        echo "Table $tablename does not exist"
        return 1
    fi

    # Get column names and types from the first two lines of the file
    colnames=$(head -n 1 "${DB_ROOT_DIR}/${DB_CURRENT}/${tablename}")
    coltypes=$(head -n 2 "${DB_ROOT_DIR}/${DB_CURRENT}/${tablename}" | tail -n 1)

    # Prompt for WHERE condition
    echo "Enter the WHERE condition (e.g. 'age > 18'):"
    read wherecond

    # Evaluate the WHERE condition for each row
    result=""
    while IFS=',' read -r line; do
        if [ ! -z "$line" ]; then
            if eval "echo \"$line\" | awk '{if ($wherecond) print}'" > /dev/null 2>&1; then
                result="$line"
            fi
        fi
    done < "${DB_ROOT_DIR}/${DB_CURRENT}/${tablename}"

    # Display the result
    if [ -z "$result" ]; then
        echo "No rows found"
    else
        echo "$colnames" | column -t -s ','
        echo "$result" | column -t -s ','
    fi
}

# Function to delete rows from a table
function delete_from_table {
    echo "Enter the name of the table to delete from:"
    read tablename

    # Check if the table file exists
    if [ ! -f "${DB_ROOT_DIR}/${DB_CURRENT}/${tablename}" ]; then
        echo "Table $tablename does not exist"
        return 1
    fi

    # Get column names and types from the first two lines of the file
    colnames=$(head -n 1 "${DB_ROOT_DIR}/${DB_CURRENT}/${tablename}")
    coltypes=$(head -n 2 "${DB_ROOT_DIR}/${DB_CURRENT}/${tablename}" | tail -n 1)

    # Prompt for condition to delete rows
    echo "Enter the condition to delete rows (e.g. 'id=5' or 'name=\"John\"'):"
    read condition

    # Check if the condition contains a valid column name
    validcol=0
    for col in $(echo "$colnames" | tr ',' ' '); do
        if [[ "$condition" == *"$col"* ]]; then
            validcol=1
            break
        fi
    done
    if [ $validcol -eq 0 ]; then
        echo "Error: condition does not contain a valid column name"
        return 1
    fi

    # Check if the condition is valid
    grep -q "$condition" "${DB_ROOT_DIR}/${DB_CURRENT}/${tablename}"
    if [ $? -ne 0 ]; then
        echo "Error: invalid condition"
        return 1
    fi

    # Delete rows that satisfy the condition
    sed -i "/$condition/d" "${DB_ROOT_DIR}/${DB_CURRENT}/${tablename}"
    echo "Rows deleted successfully"
}

 main_menu
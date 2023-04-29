#!/bin/bash

check_table(){
    echo "Enter table name:"
    read tablename

    # Check if the table exists
    if [[ ! -f "./databases/$DB_CURRENT/$tablename" ]]; then
        echo "Table does not exist!"
        return 1
    fi
}

# Function to insert a new record into a table
insert_into_table() {

    # Read primary key column name from table metadata
    primarykey=$(awk -F':' '/:pk$/{print $1}' "./databases/${DB_CURRENT}/.${tablename}")

    # Read column names from table metadata
    columns=$(awk -F':' '{print $1}' "./databases/${DB_CURRENT}/.${tablename}" | tr '\n' ':')
    columns=${columns::-1} # remove trailing ':'

    # Read column data types from table metadata
    datatypes=$(awk -F':' '{print $2}' "./databases/${DB_CURRENT}/.${tablename}" | tr '\n' ':')
    datatypes=${datatypes::-1} # remove trailing ':'

    # Read record data from user input
    echo "Enter record values separated by ':' in the order of columns ($columns):"
    read record_values

    # Check if the number of record values matches the number of columns
    if [ $(echo "$record_values" | tr ':' '\n' | wc -l) -ne $(echo "$columns" | tr ':' '\n' | wc -l) ]; then
        echo "Error: number of record values does not match number of columns"
        return 1
    fi

    # Validate record data typess
    for i in $(seq 1 $(echo "$record_values" | tr ':' '\n' | wc -l)); do
        data_type=$(echo "$datatypes" | cut -d':' -f$i)
        record_value=$(echo "$record_values" | cut -d':' -f$i)
        if [ "$data_type" == "int" ] && ! [[ "$record_value" =~ ^[0-9]+$ ]]; then
            echo "Error: record value for column '$(echo $columns | cut -d':' -f$i)' must be an integer"
            return 1
        elif [ "$data_type" == "float" ] && ! [[ "$record_value" =~ ^[0-9]+\.?[0-9]*$ ]]; then
            echo "Error: record value for column '$(echo $columns | cut -d':' -f$i)' must be a float"
            return 1
        fi
    done

    # Check if the primary key value already exists
    primarykey_value=$(echo "$record_values" | cut -d':' -f$(echo "$columns" | sed 's/:/ /g' | awk -v primarykey="$primarykey" '{for (i=1;i<=NF;i++) if ($i==primarykey) print i}'))
    if grep -q "^$primarykey_value:" "./databases/${DB_CURRENT}/${tablename}"; then
        echo "Error: primary key value '$primarykey_value' already exists"
        return 1
    fi

    # Write record to table file
    echo "$record_values" >> "./databases/${DB_CURRENT}/${tablename}"
    echo "Record inserted successfully."
}
check_table
insert_into_table
source ./database.sh
#!/bin/bash

check_table(){
    echo "Enter table name:"
    read tablename

    # Check if the table exists
    if [[  -f "./databases/$DB_CURRENT/$tablename" ]]; then
        echo "Table is already exist!"
        return 1
    fi
        re='^[^0-9][a-zA-Z0-9_]+$'
}

function createTable(){



 echo "Enter column names separated by ':'"
    read columns

    echo "Enter column datatypes separated by ':' (int or float or string):"
    read datatypes

  # Check if the number of columns and datatypes match
    if [ $(echo "$columns" | tr ':' '\n' | wc -l) -ne $(echo "$datatypes" | tr ':' '\n' | wc -l) ]; then
        echo "Error: number of columns and datatypes do not match"
        return 1
    fi

    # Validate column data types
    for data_type in $(echo $datatypes | tr ':' ' '); do
        if [ "$data_type" != "int" ] && [ "$data_type" != "float" ] && [ "$data_type" != "string" ]; then
            echo "Error: invalid column data type '$data_type'"
            return 1
        fi
    done

    echo "Enter primary key column:"
    read primarykey

    # Check if primary key column name is in the list of column names
    if [[ ! "$columns" =~ (^|:)$primarykey(:|$) ]]; then
        echo "Primary key column does not exist in column names"
        return 1
    fi

    # Write meta data to file
    meta_file="${DB_ROOT_DIR}/${DB_CURRENT}/.${tablename}"
    for i in $(echo $columns | tr ':' ' '); do
        col_name=$i
        if [ "$i" == "$primarykey" ]; then
            col_name="${col_name}:${datatypes%%:*}:pk"
        else
            col_name="${col_name}:${datatypes%%:*}"
        fi
        echo "${col_name}" >> "$meta_file"
        datatypes=${datatypes#*:}
    done

    touch "${DB_ROOT_DIR}/${DB_CURRENT}/${tablename}"
    echo "Table created successfully."

}



# check if the value is not string empty
check_table
# check if the table is exists before or not
TableExist
# ask the user about column number
re='^[0-9]+$'
# check if value is number
createTable


# back to Table menu
source ./database.sh

#!/bin/bash
function TableExist(){

    while true 
    do
        if [ -f "./Databases/$TableName" ] ; then 
            echo 'Error: The Table created before ! please use another name to create table '
            printf "Enter the table name:"
            read TableName 
        else
            break ;
        fi
        
    done
}
function CheckTableName(){
    re='^[^0-9][a-zA-Z0-9_]+$'
    while [[ -z "$TableName" ]] || ! [[ $TableName =~ $re ]];
    do 
        echo "Error: Table name not valid !"
        printf "Enter the table name:"
        read TableName
    done
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


# read from user table name 
printf "Enter the table name:"
read TableName
# check if the value is not string empty
CheckTableName
# check if the table is exists before or not
TableExist
# ask the user about column number
re='^[0-9]+$'
# check if value is number
createTable


# back to Table menu
source ./database.sh
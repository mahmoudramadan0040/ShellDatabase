#!/bin/bash 

# Function to select specific columns from a table based on conditions:
select_from_table() {
    echo "Enter table name:"
    read tablename

    # Check if the table exists
    if [[ ! -f "./databases/${DB_CURRENT}/${tablename}" ]]; then
        echo "Table does not exist!"
        return 1
    fi

    # Read column names from table metadata
    columns=$(awk -F':' '{print $1}' "./databases/${DB_CURRENT}/.${tablename}" | tr '\n' ':')
    columns=${columns::-1} # remove trailing ':'

    # Read column data types from table metadata
    datatypes=$(awk -F':' '{print $2}' "./databases/${DB_CURRENT}/.${tablename}" | tr '\n' ':')
    datatypes=${datatypes::-1} # remove trailing ':'

    # Read record data from user input
    echo "Enter the where condition (column_name=column_value):"
    read condition

    # Extract column name and value from the condition
    condition_column=$(echo "$condition" | awk -F'=|==|!=|>|<|>=|<=' '{ print $1 }')
    
    condition_value=$(echo "$condition" | awk -F'=|==|!=|>|<|>=|<=' '{ print $2 }')
    opt=$(echo "$condition" | awk -F"${condition_column}" '{print $2}' | awk -F"${condition_value}" '{print $1}')
    # Check if the column exists in the table metadata
    if ! echo "$columns" | grep -qw "$condition_column"; then
        echo "Column '$condition_column' does not exist in table '$tablename'"
        return 1
    fi

    # Determine the index of the condition column
    condition_column_index=$(echo "$columns" | awk -F':' -v column="$condition_column" '{for (i=1;i<=NF;i++) if ($i==column) print i}')

    # Validate the data type of the condition column
    condition_datatype=$(awk -F":" '{print $2}' "./databases/${DB_CURRENT}/.${tablename}" |sed -n "${condition_column_index}p" )
    if [ "$condition_datatype" == "string" ] && [ "$opt" != "==" ]; then 
        echo 'Error: condition with string support only [ == ]operator'
        return 1
    fi

    # Check if the condition column and value are not empty
    if [ -z "$condition_column" ] || [ -z "$opt" ] || [ -z "$condition_value" ]; then 
        echo 'Error: value or operator should not be empty!'
        return 1;
    fi

    echo "$columns" | tr ':' '\t'

    # Read records from the table and print matching records
     result=$(awk -F":" '{ if($'$condition_column_index''$opt''$condition_value') print }' "./databases/${DB_CURRENT}/${tablename}")
    echo "____________________________________________" 
   echo $result | tr ':' '\t'
}
select_from_table
# back to Table menu
source ./database.sh
#!/bin/bash
function TableExist(){

    while true 
    do
        if ! [ -f "./databases/$DB_CURRENT/$TableName" ] ; then 
            echo 'Error: table not exists!'
            printf "Enter the table name:"
            read TableName 
        else
            break ;
        fi
        
    done
}
function checkTypesAllowed(){
    # Get the column names and types 
    colnames=$(head -n 1 "databases/${DB_CURRENT}/${TableName}")
    # Check if the condition contains a valid column name
    validcol=0
    for col in $(echo "$colnames" | tr ':' ' '); do
        if [[ "$condition" == *"$col"* ]]; then
            validcol=1
            break
        fi
    done
    if [ $validcol -eq 0 ]; then
        echo "Error: condition does not contain a valid column name"
        deleteFromTable
    fi  

    # get the value of condition 
    value=$(echo $condition | awk -F"=|==|!=|>|<|>=|<=" '{ print $2}' )
    # get the operator value 
    opt=$( echo $condition | grep -o "[=|>|<|!=|>=|<=|==]" | tr -d  '\n' )

    # check the value not be empty 
    while true
        do
            if [ -z "$value" ] || [ -z "$opt" ] || [ -z "$colnames" ]; then 
                echo 'Error: value or operator should not be embty !'
                deleteFromTable
            else
                break ;
            fi
            
        done

    # check type of table
    colType=$(awk -F":" '{print $2}' databases/${DB_CURRENT}/.${TableName} |sed -n "${columnNumber}p" )
    while true
        do
            if [ $colType == "string" ] && [ $opt != "==" ]; then 
                echo 'Error: condition with string support only [ == ]operator'
                deleteFromTable
            else
                break ;
            fi
            
        done

}
deleteFromTable(){
    printf "enter the condition :"
    read condition
    # get the number of column 
    columnNumber=$(
            awk -F":" '
            {
            for(i=1;i<=NF;i++){
                if( $i == "'$col'"){
                    printf(i)
                    break
                }
                echo "hello"
            }
        }' databases/${DB_CURRENT}/${TableName}
    )
    
    checkTypesAllowed
}

printf "Enter the table name:"
read TableName 
# check if table is exists or not
TableExist
deleteFromTable


# echo "Enter the condition to delete rows (e.g. 'id=5' or 'name=\"John\"'):"
# read condition
# echo $colnames




# echo $opt
# echo "the number is $columnNumber"
# echo "columen number is  $columnNumber"
# echo "this is condition $condition"
# get the type of operator 

# get the value of condition 
echo $columnNumber
echo $value
echo $opt
# header=$(head -1 "databases/${DB_CURRENT}/${TableName}")
result=$(awk -F":" '{ if($'$columnNumber''$opt''$value') next; print }' databases/${DB_CURRENT}/${TableName})
# echo $result > "databases/${DB_CURRENT}/${TableName}"

echo $result
> "databases/${DB_CURRENT}/${TableName}"
# $header >> "databases/${DB_CURRENT}/${TableName}"
for line in $result
do 
echo $line >> "databases/${DB_CURRENT}/${TableName}"
done
# Delete rows that satisfy the condition
# sed -i "/$condition/d" "databases/${DB_CURRENT}/${TableName}"
# echo "Rows deleted successfully"

# back to Table menu
source ./database.sh

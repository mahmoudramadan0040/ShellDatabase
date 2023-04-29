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
updateFromTable(){
    printf "enter the condition :"
    read condition
    printf "enter the Field want update:"
    read columnField
    printf "enter new Value of this field:"
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
updateFromTable

checkTypesAllowed








# back to Table menu
source ./database.sh
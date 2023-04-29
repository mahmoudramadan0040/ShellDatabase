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
function checkColumnFiled(){
    # Get the column names and types 
    colnames=$(head -n 1 "databases/${DB_CURRENT}/${TableName}")
    # Check if the condition contains a valid column name
    validcol=0
    for col in $(echo "$colnames" | tr ':' ' '); do
        if [[ "$columnField" == *"$col"* ]]; then
            validcol=1
            break
        fi
    done
    if [ $validcol -eq 0 ]; then
        echo "Error: column Field does not contain a valid column name"
        updateFromTable
    fi  
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
        updateFromTable
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
                updateFromTable
            else
                break ;
            fi
            
        done

    # check type of table
    colType=$(awk -F":" '{print $2}' databases/${DB_CURRENT}/.${TableName} |sed -n "${columnNumber}p" )
    while true
        do
            if [[ $colType == "string" ]] && [[ $opt != "==" ]]; then 
                echo 'Error: condition with string support only [ == ]operator'
                updateFromTable
            else
                break ;
            fi
            
        done

}
updateFromTable(){
    printf "enter the condition :"
    read condition
    # get the number of column 
    checkTypesAllowed
    columnNumber=$(
            awk -F":" '
            {
            for(i=1;i<=NF;i++){
                if( $i == "'$col'"){
                    printf(i)
                    break
                }
            }
        }' databases/${DB_CURRENT}/${TableName}
    )
    echo $col
    printf "enter the Field want update:"
    read columnField
    checkColumnFiled
    printf "enter new Value of this field:"
    read fieldValue
    # Read column names from table metadata
    columns=$(awk -F':' '{print $1}' "databases/${DB_CURRENT}/.${TableName}" | tr '\n' ':')
    columns=${columns::-1} # remove trailing ':'
    # Read column data types from table metadata
    datatypes=$(awk -F':' '{print $2}' databases/${DB_CURRENT}/.${TableName} | tr '\n' ':')
    datatypes=${datatypes::-1} # remove trailing ':'
    # Read primary key column name from table metadata
    primarykey=$(awk -F":" '/:pk:$/{print $1}' databases/${DB_CURRENT}/.${TableName})
    # Check if the primary key value already exists
    echo $primarykey
    primarykey_value=$(echo "$fieldValue" | cut -d':' -f $(echo "$columns" | sed 's/:/ /g' | awk -v primarykey="$primarykey" '{for (i=1;i<=NF;i++) if ($i==primarykey) print i}'))
    if grep -q "^$primarykey_value:" databases/${DB_CURRENT}/${TableName}; then
        echo "Error: primary key value '$primarykey_value' already exists"
        updateFromTable
    fi

    
    # get the number of field 
    FielNumber=$(
            awk -F":" '
            {
            for(i=1;i<=NF;i++){
                if( $i == "'$col'"){
                    printf(i)
                    break
                }
            }
        }' databases/${DB_CURRENT}/${TableName}
    )

    echo "the column number is :$columnNumber"
    echo "the fiel  number is :$FielNumber"
}


printf "Enter the table name:"
read TableName 
# check if table is exists or not
TableExist
updateFromTable

numberOfRecord=$(awk -F":" '{if($'$columnNumber''$opt''$value' && NR>1 ) print NR }' databases/${DB_CURRENT}/${TableName})
totalRecord=$(awk -F":" 'END{printf NF }' databases/${DB_CURRENT}/${TableName})
for line in $numberOfRecord
do
    gawk -i inplace 'BEGIN{FS = ":"}{if(NR=='$line') gsub($'$FielNumber',"'$fieldValue'",$'$FielNumber')}{ gsub(" ",":",$0);
    for(i=1;i<=NF;i++)
    {
       if(i=='$totalRecord')
       {
            printf($i)
       }
       else
       {
            printf($i":")
       }
    }; printf "\n" }' "databases/${DB_CURRENT}/${TableName}"
done
echo "update done successfully"





# back to Table menu
source ./database.sh

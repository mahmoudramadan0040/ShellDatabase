function TableExist(){
    echo "the directory file is "
    echo $DB_CURRENT
    echo $dropTable
    pwd
    while true 
    do
        if [ -f "./databases/$DB_CURRENT/$dropTable.txt" ] ; then 
            rm "./databases/$DB_CURRENT/$dropTable.txt"
            rm "./databases/$DB_CURRENT/.$dropTable.txt"
            echo " table droped successfully ! "
            break;
        else
            echo 'Error: The Table Not Found or Deleted Before ! '
            printf "Enter the name of table :"
            read dropTable
        fi
        
    done
}
printf "Enter the name of table :"
read dropTable
TableExist
# back to Table menu
source ./database.sh
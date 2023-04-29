#!/bin/bash 
## usb Menu:
#export important data to all scripts
# DBDir="./Databases/"
export $DB_CURRENT


printf '+============================================+\n';
printf '|=============== The Table Menu ===============|\n';
printf '+============================================+\n';
COLUMNS=12
select choice 
in 'Create Table' 'List Tables' 'Drop Table' 'Delete From Table' 'insert into Table' 'Select Table' 'update Table' 'Back to Main Menu' 'Exit';
do
case $REPLY in 
1) 
    echo "+============================================+"
    source './kernel/createTable.sh' 
    break
    ;;
2)
    echo "+============================================+"
    source './kernel/listTable.sh' 
    break
    ;;
3)
    echo "+============================================+"
    source './kernel/dropTable.sh' 
    break
    ;;
4)
    echo "+============================================+"
    source './kernel/deleteTable.sh' 
    break
    ;;
5)
    echo "+============================================+"
    source './kernel/Insert_into.sh' 
    ;;
6)
    echo "+============================================+"
    source './kernel/Select_from_table.sh' 
    ;;
7)
    echo "+============================================+"
    source './kernel/updateTable.sh' 
    ;;
8)
    echo "+============================================+"
    source './main.sh'
    ;;
9)
    echo "+============================================+"
    exit
;;
*)
    echo "invalid input please input the number between [1-8]"
    ;;
esac 
done 



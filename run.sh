#!/bin/bash

title="database of leena & mohamed says Hi"
prompt="choose one of the following :"

function DATABASE_START ()
{
  flag=0;
options=("1-database creation" "2--use database"     "3-view all databases"   "4-database deletion"    "5-exit"
		 )
  while opt=$(zenity --title="$title" --text="$prompt"  --list \
               --width=500 --height=500     --column="Options" "${options[@]}"); do

    case "$opt" in
    "${options[0]}" ) createNewDB ;;
    "${options[1]}" ) useDataBase ;;
    "${options[2]}" ) showDatabases ;;
    "${options[3]}" ) deleteDB ;;
    "${options[4]}" ) flag=1  break ;;
    *) zenity --error --text="Invalid option. Try another one.";;
    esac
    if [[ $flag -eq 1 ]]
    then
    break;
    fi

done
}
function createNewDB()
{
        if ! [[ -d ./database ]]
        then
            mkdir database
        fi
      name=$(zenity --entry  --title="database creation"  --text="Enter your database name?"  --cancel-label="Go Back")

      if [[ "$?" != "0" ]] ; then
    return 1
        fi

        if [ -z "$name" ]
        then
         zenity --error --width=500 --text="Empty value,please try again"
        createNewDB
       elif ! [[ $name =~ ^[_a-zA-Z]+$ ]]
		then
         zenity --error --width=500 --text="name is not valid,please try again"

          createNewDB
        elif  [[ -d ./database/$name ]]
        then
               zenity --error  --width=500 --text="you hava a database with this name , enter new database "

            createNewDB
        elif ! [[ $name =~ [A-Za-z] ]]
        then
           zenity --error --width=500 --text="$name must has at least one alphabet"
        else
            mkdir ./database/$name
            zenity --info  --width=500 --text="$name database is created successfully"
        fi
}
function deleteDB(){

    available_databases=($(ls ./database))
    if [[ ${#available_databases[@]} > 0 ]]
    then
       _db=($(ls ./database))
       DBname=$(zenity --list --text  "Please select the name of the  Database you want to delete!" --cancel-label="Go Back" --width=500 --height=500 --radiolist --column "Select" --column "Database Name" $(for i in ${_db[@]}; do echo FALSE $i; done) );


          if [[ "$?" != "0" ]] ; then
        return 1
            fi

        if [ -z "$DBname" ]
        then
          zenity --error --text="Empty value,please try again!!"
          deleteDB
        else
            rm -r ./database/$DBname
               zenity --info --width=500 --text " $DBname database is deleted successfully"
       fi
    else
      zenity --info  --width="500" --text "No databases found"
    fi

}

function deleteRow() {
    found=0
     selectValues=$(awk 'BEGIN {FS=":"} {print $1}' ./database/$1/$2)

     if [[ "$selectValues" != "" ]]
     then
       primaryKeyvalue=$(zenity --entry --title="delete row" --text="enter the value of your primary key : "  --cancel-label="Go Back")
       if [[ "$?" != "0" ]] ; then

       tablechoices "$DBname" "$DBtname"
       DataBasechoices "$DBname"
       DATABASE_START
       exit
       return 1
       fi

            for i in $selectValues
                do
                if [ "$i" == "$primaryKeyvalue" ]
                    then
                    found=1
                    break
                    else
                    found=0
                fi
            done

        if [ -z "$primaryKeyvalue" ]
        then
          zenity --error  --width="500" --text="Empty value,please try again!!"

          deleteRow "$1" "$2"
        elif [ $found = 0 ]
         then
          zenity --error --width="500" --text="please select a valid option"

        deleteRow "$1" "$2"
        else
            recordToDelete=$(awk -v  numm=1 -v col_value=$primaryKeyvalue 'BEGIN{ FS = ":"}{ if( $numm == col_value ){ print $0 } }' ./database/$1/$2)
            if [[ $recordToDelete != "" ]]
            then
                sed -i "/$recordToDelete/d"  ./database/$1/$2

                zenity --info --width="500" --text="the row is successfuly deleted"
            else
              zenity --error --width="500" --text="you don't have this primary key !!!!"

            fi
        fi
        else
          zenity --error --width="500" --text="your table is empty"

        fi

}
function deleteTable(){

 available_tables=($(ls ./database/$1))
if [[ ${#available_tables[@]} > 0 ]]
    then

       _db=($(ls ./database/$1))
       tableName=$(zenity --list  --title="delete table " --text  "Please select the name of the table you want to delete" --cancel-label="Go Back" --width=500 --height=500 --radiolist --column "Select" --column "Table Name" $(for i in ${_db[@]}; do if ! [[ $i == metaData* ]]; then echo FALSE $i; fi done) );


          if [[ "$?" != "0" ]] ; then
        return 1
            fi


        if [ -z "$tableName" ]
        then
        zenity --error --width=500 --text="Empty value,please try again!!"
          deleteTable $1

        else
            rm  ./database/$1/$tableName
          rm  ./database/$1/metaData_$tableName
        zenity --info  --width=500 --text " $tableName table is deleted successfully"
        fi


    else
      zenity --error --width=500  --text "No tables found"
fi

}
function showTables(){
    available_databases=($(ls ./database/$1))
    if [[ ${#available_databases[@]} > 0 ]]
    then
        _db=($(ls ./database/$1))
        for i in ${_db[@]}
        do
            if ! [[ $i == metaData* ]];
            then
            echo "$i"
            for x in $(awk 'BEGIN {FS=":"} {print $1}' ./database/$1/metaData_$i);
             do fields+=" $x  |  "
            done
            echo $fields

            fi
            fields=""
        done |  zenity --list --title="$1 Database" --text="Tables" --cancel-label="Go Back" --width=500 --height=500  --column "Table" --column="Fields"


    else
     zenity --error --width=500 --text "No tables found"
    fi
}
function selectRow(){


selectRows=$(awk 'BEGIN {FS=":"} {print $1}' ./database/$1/metaData_$2)
selectRowsss=$(awk 'BEGIN {FS=":"} {print $1}' ./database/$1/$2)


if ! [ -z "$selectRowsss" ]

then
 primaryKeyvalue=$(zenity --entry --title="select row" --text="enter the value of your primary key : "  --cancel-label="Go Back")
    if [[ "$?" != "0" ]] ; then
        return 1
            fi


  recordToSelect=$(awk  -v   numm=1 -v col_value=$primaryKeyvalue 'BEGIN{FS = ":"}{
                if( $numm == col_value )
                {
                   print $0 }
             }' ./database/$1/$2)





            if [[ $recordToSelect != "" ]]
                then

          zenity --list --text  "your Selected row " --cancel-label="Go Back" --width=500 --height=500  $(for i in ${selectRows[@]}; do echo --column="$i" ; done)  $(for x in $(echo $recordToSelect | tr ":" "\n"); do echo $x ;     done)





              else
           zenity --error  --width=500 --text="you don't have record for this primary key "
                            selectRow  "$DBname" "$DBtname"

            fi
     else
                zenity --error  --width=500 --text="your table is empty  "
      fi
}
function showDatabases() {
    if ! [[ -d ./database ]]
        then
            mkdir database
        fi
     available_databases=($(ls ./database))
    if [[ ${#available_databases[@]} > 0 ]]
    then
        _db=($(ls ./database))
        zenity  --list --text="Databases" --title="available databases" --cancel-label="Go Back" --width=500 --height=500  --column "Database Name" "${_db[@]}"
    else
    zenity --info  --width=500  --text "No databases found"
    fi
}
function updateRow() {
    found=0
     selectValues=$(awk 'BEGIN {FS=":"} {print $1}' ./database/$1/$2)

     if [[ "$selectValues" != "" ]]
     then
     primaryKeyvalue=$(zenity --entry --title="update $DBtname" --text="enter the value of your primary key : " --cancel-label="Go Back" )
     if [[ "$?" != "0" ]] ; then

       tablechoices "$DBname" "$DBtname"
       DataBasechoices "$DBname"
       DATABASE_START
       exit

    return 1
       fi

     if  [[ $primaryKeyvalue  =~  ^[_0-9a-zA-Z]+$ || $primaryKeyvalue =~ ^$ ]]
            then
    recordToUpdate=$(awk -v  numm=1 -v col_value=$primaryKeyvalue 'BEGIN{ FS = ":"}{ if( $numm == col_value ){ print NR } }' ./database/$1/$2 )
     if [[ $recordToUpdate != "" ]]
    then


        selectValues=$(awk 'BEGIN {FS=":"} {print NR}' ./database/$1/metaData_$2)

    selectField=$(zenity --entry --title="select coloumn " --text="`awk  'BEGIN { FS = ":" ; OFS=" " } {print NR "-edit coloumn " $1 " :"}' ./database/$1/metaData_$2 `"  --cancel-label="cancel")


            if  [[ $selectField =~  ^[0-9]+$ ]]
            then
                for i in $selectValues
                    do
                    if [ $i == $selectField ]
                        then
                        found=1
                        break
                        else
                        found=0
                    fi
                done
            fi


         if [ -z "$selectField" ]
        then
          zenity --error --width=500 --text="Empty value,please try again!!"
          updateRow "$1" "$2"
        elif [ $found = 0 ]
         then
           zenity --error --width=500 --text="please select a valid option"
        updateRow "$1" "$2"
        else
            selectFieldValue=$(awk -F ':' -v lineNo="$selectField"  'NR == lineNo { print $0 }'  OFS=':' ./database/$1/metaData_$2 )
            columnValue=$(echo "$selectFieldValue" | cut -d ":" -f 1)
            dataType=$(echo "$selectFieldValue" | cut -d ":" -f 2)
            firstConstraint=$(echo "$selectFieldValue" | cut -d ":" -f 3)
            secondConstraint=$(echo "$selectFieldValue"| cut -d ":" -f 4)
            if [[ -n "$firstConstraint" ]]
            then
            firstConstraint=$firstConstraint
            else
            firstConstraint=0
            fi
            if [[ -n "$secondConstraint" ]]
            then
            secondConstraint=$secondConstraint
            else
            secondConstraint=0
            fi
            colNumber=$selectField
            updateFlag=1
            checkDataType $columnValue $dataType $firstConstraint $secondConstraint $1 $2 $colNumber $updateFlag
            recordToSelect=$(awk  -v   numm=1 -v col_value="$columnValue" 'BEGIN{FS = ":"}{
                if( $numm == col_value )
                {
                print $0 }
            }' ./database/$1/metaData_$2)
            c=$(awk -F ':' -v lineNo="$recordToUpdate" -v val="$val" -v field="$selectField" 'NR == lineNo { $field = val }1'  OFS=':' ./database/$1/$2 >temp && mv temp ./database/$1/$2 )

            zenity --info --width=500 --text="the row is successfully updated"
             fi
        else
          zenity --error --width=500 --text="you don't have this primary key !!!!"
            updateRow "$1" "$2"

        fi
    else
      zenity --error --width=500 --text="wrong format !!!!"
            updateRow "$1" "$2"

        fi
         else
           zenity --error --width=500 --text="your table is empty"
        fi
}

function primaryColumnValidations(){
    pkFlag=1
    colName=$(zenity --entry --title="create coloumn  " --text="Enter your primary key :"  --cancel-label="cancel")
    if [[ "$?" != "0" ]] ; then
      rm  ./database/$1/$tableName
     rm  ./database/$1/metaData_$tableName
     DataBasechoices  $1
     DATABASE_START
     exit
  return 1
      fi




        if [ -z "$colName" ]
    then
      zenity --error  --width=500  --text="Empty value,please try again!!"

    primaryColumnValidations $1 $2
    elif ! [[ $colName =~ ^[a-zA-Z]+$ ]]
    then
      zenity --error  --width=500  --text="$colName is not valid format,please try again!!"

    primaryColumnValidations $1 $2
    else
        echo -n $colName >> ./database/$1/$2

        specifyColumnDataType $colName $1 $2 $pkFlag
        echo -e ":pk" >> ./database/$1/$2

    fi
}
function columnValidations(){

  colName=$(zenity --entry --title="$tableName" --text="Enter column $i :"  --cancel-label="cancel")
  if [[ "$?" != "0" ]] ; then
    rm  ./database/$1/$tableName
   rm  ./database/$1/metaData_$tableName
   DataBasechoices  $1
   DATABASE_START
   exit
return 1
    fi
        if [ -z "$colName" ]
    then
      zenity --error  --width=500  --text="Empty value,please try again!!"

    columnValidations $1 $2
    elif ! [[ $colName =~ ^[_a-zA-Z]+$ ]]
    then
      zenity --error  --width=500  --text="$colName is not valid format,please try again!!"

    columnValidations $1 $2
    elif  grep -w "$colName" ./database/$1/$2
    then
      zenity --error  --width=500  --text="already exists"

        columnValidations  $1 $2
    else
      echo -n $colName >> ./database/$1/$2
     specifyColumnDataType $colName $1 $2
    fi

}

function specifyConstrients()
{

    if [[ -n "$4" ]]
        then
        flagnull=$4
        else
         flagnull=0
    fi

     if [[ -n "$5" ]]
        then
         flagunique=$5
        else
           flagunique=0
    fi



     options=("1-not null" "2-unique"     "3-done with constraints"
     		 )
       while optw=$(zenity --title="$1" --text="what constraints you desire ??"  --list \
                    --width=500 --height=500     --column="Options" "${options[@]}"); do




         case "$optw" in
         "${options[0]}" ) if [[ $flagnull = 0 ]]
                then
                      echo -e -n ":notNull" >> ./database/$2/$3
                     flagnull=1
                else
                  zenity --error  --width=500  --text="You have already set this constraint before"

                fi
                 ;;
         "${options[1]}" )  if [[ $flagunique = 0 ]]
                 then
                         echo -e -n ":unique" >> ./database/$2/$3
                     flagunique=1
                 else
                   zenity --error  --width=500  --text="You have already set this constraint before"

                 fi
             ;;
         "${options[2]}" )  echo -e "" >> ./database/$2/$3
          break ;;

         *) zenity --error --text="Invalid option. Try another one."
         specifyConstrients $1 $2 $3 $flagnull $flagunique
          break;
         ;;
         esac

     done



}

function specifyColumnDataType()
{



  options=("1-varchar"      "2-integer"  )
   opttt=$(zenity --title="$colName" --text=""  --list \
               --width=500 --height=500     --column="for $1 field what data type you want " "${options[@]}");
               if [[ "$?" != "0" ]] ; then
               rm  ./database/$DBname/$tableName
              rm  ./database/$DBname/metaData_$tableName
                DataBasechoices  $DBname
                DATABASE_START
                exit
             return 1
                 fi



    case "$opttt" in
    "${options[0]}" )    echo -e -n  ":varchar" >> ./database/$2/$3
       if [[ "$4" = '' ]]
          then
          specifyConstrients $1 $2 $3

          fi

      ;;
    "${options[1]}" )   echo -e -n ":integer" >> ./database/$2/$3
      if [[ "$4" = '' ]]
          then
          specifyConstrients $1 $2 $3

      fi
      ;;

        *)
              zenity --error --text="Invalid option. Try another one."
              specifyColumnDataType $1 $2 $3 $4
                            ;;
    esac

}


function enterColumnNumbers()
{

      colNum=$(zenity --entry --title="number of coloumns  " --text="Enter the number of the coloums for $tableName  :"  --cancel-label="cancel")
      if [[ "$?" != "0" ]] ; then
        rm  ./database/$1/$tableName
       rm  ./database/$1/metaData_$tableName
    return 1
        fi

     if [ -z "$colNum" ]
    then
      zenity --error  --width=500  --text="Empty value,please try again!!"

    enterColumnNumbers $1 $2
    elif ! [[ $colNum =~ ^[0-9]+$ ]]
    then
      zenity --error  --width=500  --text="wrong format "

        enterColumnNumbers $1 $2
    elif [[ $colNum -lt 2 ]]
    then
      zenity --error  --width=500  --text="column numbers can not be less than 2"
      enterColumnNumbers $1 $2
    else
         for i in $(seq $colNum)
            do
            if [[ i -eq 1 ]]
            then
                primaryColumnValidations $1 metaData_$2

            else
                columnValidations $1 metaData_$2
            fi
        done

        zenity --info   --width=500  --text="table is created successfully"
                              DataBasechoices $DBname
                              DATABASE_START
                              exit


    fi
}
function createTable(){

    tableName=$(zenity --entry --title="create table " --text="Enter the name of the table :"  --cancel-label="Go Back")
    if [[ "$?" != "0" ]] ; then
  return 1
      fi




     if [ -z "$tableName" ]
        then
          zenity --error   --width=500  --text="Empty value,please try again!!"
           createTable $1
        elif ! [[ $tableName =~ ^[_a-zA-Z]+$ ]]
		then
      zenity --error --text="invalid name ,please try again!!"
          createTable $1
        elif  [[ -f ./database/$1/$tableName ]]
        then
          zenity --error  --width=500 --text="you have table with this name ,please choose another name !!"
            createTable $1

        elif [[ $tableName  == MetaData* ]]
        then
            zenity --error   --width=500  --text=" you can not start database with metaData (reserved word) ,please choose another name !!"

        else
             touch ./database/$1/$tableName
             touch ./database/$1/metaData_$tableName
             enterColumnNumbers $1 $tableName
        fi
}

function DataBasechoices(){

  prompt="Pick an option:"
toptions=("1-show tables " "2-create table"     "3-delete table"   "4-use table "
     )
  while opt1=$(zenity --title="$1" --text="$prompt"  --list \
               --width=500 --height=500     --column="Options" "${toptions[@]}"); do

    case "$opt1" in
    "${toptions[0]}" ) showTables  "$1" ;;
    "${toptions[1]}" ) createTable "$1" ;;
    "${toptions[2]}" )  deleteTable "$1" ;;
    "${toptions[3]}" )   useTable "$1" ;;

    *) zenity --error   --width=500  --text="Invalid option , select again ";;
    esac


done

}
function useDataBase()
{
  available_databases=($(ls ./database))
 if [[ ${#available_databases[@]} > 0 ]]
 then

 _db=($(ls ./database))
DBname=$(zenity --list --title="use database" --text  "select  the Database you want to use!" --cancel-label="Go Back" --width=500 --height=500 --radiolist --column "Select" --column "Database Name" $(for i in ${_db[@]}; do echo FALSE $i; done) );

       if [[ "$?" != "0" ]] ; then
     return 1
         fi


     if [ -z "$DBname" ]
     then
       zenity --error  --width=500  --text="Empty value,please select one !!"
       useDataBase
     else
              DataBasechoices "$DBname"

    fi
 else
 zenity --info   --width=500 --text "No databases found"
 fi


}


function checkDataType()
{



 val=$(zenity --entry --title="$1" --text="Enter the  value of the $1 :"  --cancel-label="Go Back")
# typeset -i t=1

        #    if [[ "$?" != "0" ]] ;
          #  then
          #          if [[$t -eq  1]]
            #            then
              #           tablechoices "$DBname" "$DBtname"
              #           DataBasechoices "$DBname"
              #           DATABASE_START
              #           exit
              #          return 1
            #        else
            #          echo "hello there"
            #            fi
    #  fi

    #  t=$((t+1))

if [[ "$2" = integer ]]
    then

               if [[ "$val" =~ ^[0-9]+$  || "$val" =~ ^$ ]]
                then
                 checkFirstConstraint "$val" $3 $4 $5 $6 $7 $2 $1 $8

               else
                 zenity --error  --width=500 --text="your data type is intger , enter integers only please"

                  checkDataType $1 $2 $3 $4 $5 $6 $7 $8
               fi
    fi



  if [[ "$2" = varchar ]]
    then

      if [[ "$val" =~ ":" ]]
       then
        zenity --error --width=500 --text="wrong format canot accept : "

        checkDataType $1 $2 $3 $4 $5 $6 $7 $8

      elif [[ "$val" =~ ^[_a-zA-Z]+ || "$val" =~ ^$  ]]
      then
      checkFirstConstraint "$val" $3 $4 $5 $6 $7 $2 $1 $8
      else
      zenity --error --width=500 --text="your data type is varchar , enter varchars only please "

        checkDataType $1 $2 $3 $4 $5 $6 $7 $8
      fi
    fi

}
function checkFirstConstraint()
{



    found=1
    cfound=1
    if [[ "$2" = "pk" ]]
        then
           if [[ "$1" != "" ]]
            then
                pkValues=$(awk 'BEGIN {FS=":"} {print $1}' ./database/$4/$5)
                    if [[ $pkValues = "" ]]
                    then
                     if [[ "$9" = '' ]]
                    then
                    echo -n "$1" >> ./database/$4/$5
                    echo -n ":" >> ./database/$4/$5
                    fi
                    else
                        for i in $pkValues
                            do

                            if [ "$i" == "$1" ]
                                then
              zenity --error --width=500 --text="primary key must be unique"

                                checkDataType $8 $7 $2 $3 $4 $5 $6 $9
                                found=1
                                break
                            else
                                found=0

                            fi
                        done
                         if [[ $found = 0 ]]
                            then
                              if [[ "$9" = '' ]]
                                then
                                echo -n "$1" >> ./database/$4/$5
                                echo -n ":" >> ./database/$4/$5
                                fi

                        fi
                    fi
            else
                  zenity --error --width=500 --text="primary key mustn't be null"

                checkDataType $8 $7 $2 $3 $4 $5 $6 $9
            fi
    elif [[ "$2" = "unique" ]]
    then

            if [[ "$1" != "" ]]
            then
            colValues=$(awk -v col=$6 'BEGIN { FS = ":" } {print $col}' ./database/$4/$5)
            if [[ $colValues = "" ]]
              then

               checkSecondConstraint "$1" $2 $3 $4 $5 $6 $7 $8 $9
            else
              for i in $colValues
                    do
                    if [ "$i" == "$1" ]
                        then
                          zenity --error --width=500 --text="column value must be unique"

                           checkDataType $8 $7 $2 $3 $4 $5 $6 $9
                         cfound=1
                         break
                    else
                    cfound=0

                    fi
                done
                  if [[ $cfound = 0 ]]
                    then
                    checkSecondConstraint "$1" $2 $3 $4 $5 $6 $7 $8 $9
                fi
            fi
        else
            checkSecondConstraint "$1" $2 $3 $4 $5 $6 $7 $8 $9
        fi
    elif [[ "$2" = "notNull" ]]
    then
        if [[ "$1" = "" ]]
            then
              zenity --error --width=500 --text="error ! must be not null"

           checkDataType $8 $7 $2 $3 $4 $5 $6 $9
        else

        checkSecondConstraint "$1" $2 $3 $4 $5 $6 $7 $8 $9
        fi
    else
      if [[ "$1" != "" ]]
            then
            if [[ "$9" = '' ]]
                then
                echo -n "$1" >> ./database/$4/$5
                echo -n ":" >> ./database/$4/$5
                fi
        else
        if [[ "$9" = '' ]]
            then
            echo -n ":" >> ./database/$4/$5
            fi

        fi
    fi
}
function checkSecondConstraint()
{

    found=1
    cfound=1
      if [[ "$3" = "unique" ]]
    then

         if [[ "$1" != "" ]]
            then
            colValues=$(awk -v col=$6 'BEGIN { FS = ":" } {print $col}' ./database/$4/$5)
            if [[ $colValues = "" ]]
              then

           if [[ "$9" = '' ]]
                then
                echo -n "$1" >> ./database/$4/$5
                echo -n ":" >> ./database/$4/$5
                fi
            else
              for i in $colValues
                    do
                    if [ "$i" == "$1" ]
                        then
                          zenity --error  --width=500 --text="column value must be unique"

                      checkDataType $8 $7 $2 $3 $4 $5 $6 $9
                         cfound=1
                         break
                    else
                    cfound=0

                    fi
                done
                  if [[ $cfound = 0 ]]
                    then
                  if [[ "$9" = '' ]]
                then
                echo -n "$1" >> ./database/$4/$5
                echo -n ":" >> ./database/$4/$5
                fi
                fi
            fi
     else
            checkSecondConstraint "$1" $2 $3 $4 $5 $6 $7 $8 $9
        fi
    elif [[ "$3" = "notNull" ]]
    then
        if [[ "$1" = "" ]]
            then
              zenity --error  --width=500 --text="error ! must be not null"

           checkDataType $8 $7 $2 $3 $4 $5 $6 $9
        else
         if [[ "$9" = '' ]]
                then
                echo -n "$1" >> ./database/$4/$5
                echo -n ":" >> ./database/$4/$5
                fi
        fi
    else
       if [[ "$1" != "" ]]
            then
    if [[ "$9" = '' ]]
                then
                echo -n "$1" >> ./database/$4/$5
                echo -n ":" >> ./database/$4/$5
                fi
        else
        if [[ "$9" = '' ]]
                then
                echo -n ":" >> ./database/$4/$5
                fi
        fi
    fi

}

function insertRow()
{
  rows=$(awk 'BEGIN {FS=":"} {
      print $0
    }' ./database/$1/metaData_$2)
        colNumber=0
      for x in $rows
        do
        ((colNumber++))
        columnValue=$(echo "$x" | cut -d ":" -f 1)
        dataType=$(echo "$x" | cut -d ":" -f 2)
        firstConstraint=$(echo "$x" | cut -d ":" -f 3)
        secondConstraint=$(echo "$x"| cut -d ":" -f 4)
        if [[ -n "$firstConstraint" ]]
        then
        firstConstraint=$firstConstraint
        else
        firstConstraint=0
        fi
         if [[ -n "$secondConstraint" ]]
        then
        secondConstraint=$secondConstraint
        else
        secondConstraint=0
        fi
        checkDataType $columnValue $dataType $firstConstraint $secondConstraint $1 $2 $colNumber

        done




      zenity --info  --width=500 --text " your record has been inserted successfully "


        truncate -s-1 ./database/$1/$2
        echo -e "" >> ./database/$1/$2

}

function tablechoices(){
  options=("1-insert row " "2-select row "     "3-delete row "   "4-update row "
  		 )
    while input=$(zenity --title="$2" --text="select the option you want "  --list \
                 --width=500 --height=500     --column="Options" "${options[@]}"); do

      case "$input" in
      "${options[0]}" ) insertRow "$1" "$2" ;;
      "${options[1]}" )  selectRow "$1" "$2" ;;
      "${options[2]}" ) deleteRow "$1" "$2" ;;
      "${options[3]}" ) updateRow "$1" "$2" ;;

      *) zenity --error --width=500 --text="Invalid option. Try another one.";;
      esac


  done



}

function useTable()
{

     availableTables=($(ls ./database/$1))
  if [[ ${#availableTables[@]} > 0 ]]
  then
    _dbt=($(ls -I "metaData_*" ./database/$1))
   DBtname=$(zenity --list --title="use table" --text  "select  the table  you want to use" --cancel-label="Go Back" --width=500 --height=500 --radiolist --column "Select" --column "Table Name" $(for i in ${_dbt[@]}; do echo FALSE $i; done) );

           if [[ "$?" != "0" ]] ; then
                return 1
            fi
     if [ -z "$DBtname" ]
     then
       zenity --error  --width=500  --text="Empty value,please select one "
       useTable $1

        else
            tablechoices "$1" "$DBtname"
        fi
  else
      zenity --error  --width=500  --text="No tables found"

  fi


}



DATABASE_START

#!/bin/bash

# change to script directory
cd $(dirname $0)

# relabel parameters
PATH_HISTFILE=$1
PATH_SQLBIN=$2
PATH_DB=$3
MD5BIN=$4

echo "FILENAME: $0"
echo "PATH_HISTFILE: $1"
echo "PATH_SQLBIN: $2"
echo "PATH_DB: $3"
echo "MD5BIN: $4"

declare -a assArray
declare -i lineCount=0

function checkCmd(){
  command -v $1 > /dev/null
}

function queryDB(){
  QUERY_RESULT=$($PATH_SQLBIN $PATH_DB $1)
}

# while-loop through input file
# split with internal field separator (IFS)
while IFS= read -r line
do
# check if start of cmdLine is valid.
  if [[ $line =~ ^[a-z].* ]]
  then
    # calculate line hash and extract data from line
    lineHash=$(echo -n "$line" | $MD5BIN | awk '{print $1}')
    cmd=$(echo "$line" | awk '{print $1}')
    options=$(echo "$line" | awk '{$1=""; print $0}')

    # query DB to check if linehash is already present: 
    queryDB "SELECT * FROM commands WHERE hash='$lineHash'"
    # if query output is empty, continue with the next loop iteration
    [[ ! -z "$QUERY_RESULT" ]] && continue

    # check if first word of line (≈command) is valid
    checkCmd $cmd
    if [[ $? -eq 0 ]]; then
      queryDB "INSERT INTO commands(hash, command, options)
        VALUES('$lineHash', '$cmd', '$options')"

    #   # save valid command to array
    #   IFS=' ' read -r -a array <<< "$line"
    #   # print array
    #   for i in "${array[*]}"
    #   do
    #     echo $i
    #   done
    # printf "\n"
      # save valid command to associative array.
      assArray[$lineCount]="$line"
      # echo $lineCount
      # printf '%s\n' "${assArray[$lineCount]}"
      ((lineCount=lineCount+1))
    fi
  fi
# input source
done < "$PATH_HISTFILE"

length=${#assArray[@]}
echo $length
echo First entry: ${assArray[0]}
echo Last entry: ${assArray[(($length-1))]}


# # print associative array
# for key in "${assArray[@]}"
# do
#   printf '%s\n' "$key"
# done

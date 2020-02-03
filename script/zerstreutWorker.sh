#!/bin/bash

# change to script directory
cd $(dirname $0)

# relabel parameters
PATH_HISTFILE=$1
PATH_SQLBIN=$2
PATH_DB=$3
MD5BIN=$4

echo "FILENAME: $0"
echo "PATH_HISTFILE: '$1'"
echo "PATH_SQLBIN: $2"
echo "PATH_DB: $3"
echo "MD5BIN: $4"
printf '\n'

declare -a assArray
declare -i lineCount=0

function checkCmd(){
  command -v $1 > /dev/null
}

function queryDB(){
  # Path to binary, path to database, query
  QUERY_RESULT=$($PATH_SQLBIN $PATH_DB $1)
  #QUERY_RESULT=$($PATH_SQLBIN $PATH_DB "SELECT * FROM commands WHERE hash='$lineHash'")
}

# while-loop through input file
# split with internal field separator (IFS)
while IFS= read -r line
do
# check if start of cmdLine is valid.
  if [[ $line =~ ^[[:space:]]*[a-z].*$ ]]
  then
    # calculate line hash and extract data from line
    # extract line hash
    lineHash=$(echo -n "$line" | $MD5BIN | awk '{print $1}')
    # extract command
    cmd=$(echo "$line" | awk '{print $1}')
    # extract options
    options=$(echo "$line" | tr -d \' | awk '{$1=""; print $0}')

    # query DB to check if linehash is already present:
    QUERY_RESULT=$($PATH_SQLBIN $PATH_DB "SELECT * FROM commands WHERE hash='$lineHash'")
    # if query output is not empty -> command + options already in database -> continue with the next loop iteration
    [[ ! -z "$QUERY_RESULT" ]] && continue

    # query output ist empty -> new coms*[a-z].*mand + options
    # check if first word of line (≈command) is valid
    checkCmd $cmd
    if [[ $? -eq 0 ]]; then
      echo "Hash: " $lineHash
      echo "Command: " $cmd
      echo "Options and Parameters: " $options
      printf '\n'
      QUERY_RESULT=$($PATH_SQLBIN $PATH_DB "INSERT INTO commands(hash, command, options) VALUES('$lineHash', '$cmd', '$options')")

      # save valid command to associative array.
      assArray[$lineCount]="$line"

      ((lineCount=lineCount+1))
    fi
  fi
# input source
done < "$PATH_HISTFILE"

length=${#assArray[@]}
echo "Amount of new entries added: "$length

# # print associative array
# for key in "${assArray[@]}"
# do
#   printf '%s\n' "$key"
# done

#!/bin/sh

# var = first param ≈ path of .txt input
#echo "Path: "$1
input=./inputTmp.txt

function checkCmd(){
  command -v $1 > /dev/null
}

# while-loop through input file
# split with internal field separator (IFS)
while IFS= read -r line
do
# check if start of cmdLine is valid.
if [[ $line =~ ^[a-z].* ]]
then
  # get first word of line
  cmd=$(echo "$line" | awk '{print $1}')
  # check if first word of line (≈command) is valid
  checkCmd $cmd
  if [[ $? -eq 0 ]]
  then
    # save valid command to array
    IFS=' ' read -r -a array <<< "$line"
    # print array
    for i in "${array[*]}"
    do
      echo $i
    done
  printf "\n"
  fi
fi
# input source
done < "$input"

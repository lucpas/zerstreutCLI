#!/bin/sh

# var = first param ≈ path of .txt input
#echo "Path: "$1
input=./inputTmp.txt
declare -a assArray
declare -i lineCount=0

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
done < "$input"

length=${#assArray[@]}
echo $length
echo First entry: ${assArray[0]}
echo Last entry: ${assArray[(($length-1))]}


# print associative array
for key in "${assArray[@]}"
do
  printf '%s\n' "$key"
done

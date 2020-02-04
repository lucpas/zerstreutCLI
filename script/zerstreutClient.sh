#!/bin/bash

abort() {
  echo $@
  exit 1
}

cd $(dirname "$0")

CONFIG="../.config"
if [ -f "$CONFIG" ]; then
  # PWD=$(awk 'NR==1 {print; exit}' $CONFIG)
  PATH_SQLBIN=$(awk 'NR==3 {print; exit}' $CONFIG)
  PATH_DB=$(awk 'NR==4 {print; exit}' $CONFIG)
  # cd $PWD
else
  abort "Config file not found. Try running install.sh"
fi

while getopts 't:c:o:' OPTION; do
  case "$OPTION" in
  t)
    TAG=$OPTARG
    ;;
  c)
    COMMAND=$OPTARG
    ;;
  o)
    OPTIONS=$OPTARG
    ;;
  ?)
    echo "Invalid parameters entered; exiting..."
    ;;
  esac
done
shift "$(($OPTIND - 1))"


if [[ $TAG && $COMMAND ]] || [[ $TAG && $OPTIONS ]] || [[ $OPTIONS && $COMMAND ]]; then
  abort "Specify EITHER a tag, a command or an option to search"
fi

if [ $TAG ]; then
  echo "Stored commands using tag '$TAG':"
  SOURCE="commands WHERE tag='$TAG'"
elif [ $COMMAND ]; then
  echo "Stored commands using command '$COMMAND':"
  SOURCE="commands WHERE command='$COMMAND'"
elif [ $OPTIONS ]; then
  echo "Stored commands containing options '$OPTIONS':"
  SOURCE="commands WHERE options LIKE '%$OPTIONS%'"
else
  abort "Specify a tag, a command or an option"
fi

IFS=$'\n'

QUERY_RESULT_HASH=(`$PATH_SQLBIN $PATH_DB "SELECT hash FROM $SOURCE"`)
QUERY_RESULT_COMMAND=(`$PATH_SQLBIN $PATH_DB "SELECT command FROM $SOURCE"`)
QUERY_RESULT_OPTIONS=(`$PATH_SQLBIN $PATH_DB "SELECT options FROM $SOURCE"`)


for ((i = 0; i < ${#QUERY_RESULT_HASH[@]}; ++i)); do
  echo "$((i + 1))) CMD: ${QUERY_RESULT_COMMAND[i]}"
  echo "   OPT: ${QUERY_RESULT_OPTIONS[i]}"
  echo "   HSH: ${QUERY_RESULT_HASH[i]}"
done

echo
read -p "Select command for editing or quit (q): " SELECTED_CMD_INDEX

if [[ SELECTED_CMD_INDEX -ge 1 && SELECTED_CMD_INDEX -le ${#QUERY_RESULT_HASH[@]} ]]; then
  SELECTED_CMD_INDEX=$((SELECTED_CMD_INDEX - 1))
  SELECTED_CMD_HASH=${QUERY_RESULT_HASH[$SELECTED_CMD_INDEX]}
elif [ "$SELECTED_CMD_INDEX" == "q" ]; then
  exit 0
else
  abort "No valid index entered. Exiting..."
fi

echo "------"
echo "1) Create tag"
echo "2) Remove tag"
echo "3) Delete entry"
read -p "Select action (1|2|3) or quit (q): " ACTION
echo "------"
case "$ACTION" in
  1)
    read -p "Enter a unique tag: " NEW_TAG
    QUERY_RESULT=(`$PATH_SQLBIN $PATH_DB "UPDATE commands SET tag='$NEW_TAG' WHERE hash='$SELECTED_CMD_HASH'"`)
    if [ $? == 0 ]; then
      echo "Tag created"
    else
      echo "Error creating tag; exiting..."
    fi
    ;;
  2)
    QUERY_RESULT=(`$PATH_SQLBIN $PATH_DB "UPDATE commands SET tag=null WHERE hash='$SELECTED_CMD_HASH'"`)
    if [ $? == 0 ]; then
      echo "Tag deleted"
    else
      echo "Error deleting tag; exiting..."
    fi    ;;
  3)
    QUERY_RESULT=(`$PATH_SQLBIN $PATH_DB "DELETE FROM commands WHERE hash='$SELECTED_CMD_HASH'"`)
    if [ $? == 0 ]; then
      echo "Entry deleted"
    else
      echo "Error deleting entry; exiting..."
    fi
    ;;
  q)
    exit 0
    ;;
  ?)
    abort "Invalid input. Exiting..."
esac
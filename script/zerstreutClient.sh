#!/bin/bash

abort() {
  echo $@
  exit 1
}

# Change to directory where this file is located
cd $(dirname "$0")

# Load config file
CONFIG="../.config"
if [ -f "$CONFIG" ]; then
  PATH_SQLBIN=$(awk 'NR==3 {print; exit}' $CONFIG)
  PATH_DB=$(awk 'NR==4 {print; exit}' $CONFIG)
else
  abort "Config file not found. Try running install.sh"
fi

# Parse options and their values
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

# Abort if more than one option was given
if [[ $TAG && $COMMAND ]] || [[ $TAG && $OPTIONS ]] || [[ $OPTIONS && $COMMAND ]]; then
  abort "Specify EITHER a tag [-t], a command [-c] or an option [-o] to search"
fi

# Create database statement
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
  abort "Specify a tag [-t], a command [-c] or an option [-o]"
fi

IFS=$'\n'

# Query database
QUERY_RESULT_HASH=($($PATH_SQLBIN $PATH_DB "SELECT hash FROM $SOURCE"))
QUERY_RESULT_COMMAND=($($PATH_SQLBIN $PATH_DB "SELECT command FROM $SOURCE"))
QUERY_RESULT_OPTIONS=($($PATH_SQLBIN $PATH_DB "SELECT options FROM $SOURCE"))

# Print query results
for ((i = 0; i < ${#QUERY_RESULT_HASH[@]}; ++i)); do
  echo "$((i + 1))) CMD: ${QUERY_RESULT_COMMAND[i]}"
  echo "   OPT: ${QUERY_RESULT_OPTIONS[i]}"
  echo "   HSH: ${QUERY_RESULT_HASH[i]}"
done

# Require user to select a result or quit
echo
read -p "Select command (1|2|3|...) for editing or quit (q): " SELECTED_CMD_INDEX

if [[ SELECTED_CMD_INDEX -ge 1 && SELECTED_CMD_INDEX -le ${#QUERY_RESULT_HASH[@]} ]]; then
  # Decrement the selected result (0-based index) 
  SELECTED_CMD_INDEX=$((SELECTED_CMD_INDEX - 1))
  SELECTED_CMD_HASH=${QUERY_RESULT_HASH[$SELECTED_CMD_INDEX]}
elif [ "$SELECTED_CMD_INDEX" == "q" ]; then
  exit 0
else
  abort "No valid index entered. Exiting..."
fi

# Print actions and require user to select one
echo "------"
echo "1) Create tag"
echo "2) Remove tag"
echo "3) Delete entry"
read -p "Select action (1|2|3) or quit (q): " ACTION
echo "------"

# Execute selected action
case "$ACTION" in
1)
  # Create new or override existing tag
  read -p "Enter a unique tag: " NEW_TAG
  QUERY_RESULT=($($PATH_SQLBIN $PATH_DB "UPDATE commands SET tag='$NEW_TAG' WHERE hash='$SELECTED_CMD_HASH'"))
  if [ $? == 0 ]; then
    echo "Tag created"
  else
    echo "Error creating tag; exiting..."
  fi
  ;;
2)
  # Delete existing tag
  QUERY_RESULT=($($PATH_SQLBIN $PATH_DB "UPDATE commands SET tag=null WHERE hash='$SELECTED_CMD_HASH'"))
  if [ $? == 0 ]; then
    echo "Tag deleted"
  else
    echo "Error deleting tag; exiting..."
  fi
  ;;
3)
  # Delete command entry from database
  QUERY_RESULT=($($PATH_SQLBIN $PATH_DB "DELETE FROM commands WHERE hash='$SELECTED_CMD_HASH'"))
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
  ;;
esac

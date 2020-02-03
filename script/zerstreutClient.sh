#!/bin/bash

CONFIG=".config"

abort() {
  echo $@
  exit 1
}

if [ -f "$CONFIG" ]; then
  PWD=$(awk 'NR==1 {print; exit}' $CONFIG)
  PATH_HISTORY=$(awk 'NR==2 {print; exit}' $CONFIG)
  PATH_SQLBIN=$(awk 'NR==3 {print; exit}' $CONFIG)
  PATH_DB=$(awk 'NR==4 {print; exit}' $CONFIG)
else
  abort "Config file not found. Try running start.sh"
fi

cd $PWD

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

#echo "-t" $TAG "-c" $COMMAND "-o" $OPTIONS

if [[ $TAG && $COMMAND ]] || [[ $TAG && $OPTIONS ]] || [[ $OPTIONS && $COMMAND ]]; then
  abort "Specify EITHER a tag, a command or an option to search"
fi

if [ $TAG ]; then
  SOURCE="commands WHERE tag='$TAG'"
fi

if [ $COMMAND ]; then
  SOURCE="commands WHERE command='$COMMAND'"
fi

if [ $OPTIONS ]; then
  SOURCE="commands WHERE instr(options, $OPTIONS) > 0"
fi

QUERY_RESULT_HASH=($($PATH_SQLBIN $PATH_DB "SELECT hash FROM $SOURCE"))
QUERY_RESULT_COMMAND=($($PATH_SQLBIN $PATH_DB "SELECT command FROM $SOURCE"))
QUERY_RESULT_OPTIONS=($($PATH_SQLBIN $PATH_DB "SELECT options FROM $SOURCE"))

echo "Stored commands using '$TAG$COMMAND$OPTIONS':"

for ((i = 0; i < ${#QUERY_RESULT_HASH[@]}; ++i)); do
  echo "$((i + 1)) CMD: ${QUERY_RESULT_COMMAND[i]}"
  echo "  OPT: ${QUERY_RESULT_OPTIONS[i]}"
done

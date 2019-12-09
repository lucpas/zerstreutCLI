#!/bin/bash

# Helper functions
createDatabase() {
    echo "Creating DB..."
    $PATH_SQLBIN $PATH_DB "
    CREATE TABLE IF NOT EXISTS commands (
        hash TEXT PRIMARY KEY,
        timestamp INTEGER,
        command TEXT NOT NULL,
        options TEXT)"
}

# Startup greeting
echo "                            _                  _   _____  _     _____           "
echo "                           | |                | | /  __ \| |   |_   _|          "
echo "           _______ _ __ ___| |_ _ __ ___ _   _| |_| /  \/| |     | |            "
echo "          |_  / _ \ '__/ __| __| '__/ _ \ | | | __| |    | |     | |            "
echo "           / /  __/ |  \__ \ |_| | |  __/ |_| | |_| \__/\| |_____| |_           "
echo "          /___\___|_|  |___/\__|_|  \___|\__,_|\__|\____/\_____/\___/           "
echo "                                                                                "
echo "                                                                                "
echo "                          ____________                                          "
echo "                        ##,.   . . .,*#%(                                       "
echo "                      /% ...                *(                                  "
echo "                      %. ,,.     ...           ,#                               "
echo "                      %, ., .   ( .,/,.  .,(%%#,.(##. .,.                       "
echo "                      *%          ,. .#/,,(.../..%/,(..,,.(                     "
echo "                       */ .      ...,/,,,#,./*,,./,/../,/./*                    "
echo "                        /*         .**,.,/*../...#..*((,..(.                    "
echo "                         .%. .(#/..  /,,,,,/*,*#/...    ,*                      "
echo "                           %#.,.  ..  .**,..,/  .*..  .  *,                     "
echo "                          (.(.,.       ..//, .,. *((#/*%%(                      "
echo "                           ./ (,.      . ..*(...      . ./(/                    "
echo "                             /*.*   .  *(  . .    ...  .  . #                   "
echo "                              /(/,.  ..,*.,.*//(/.   #.*%/*.                    "
echo "                               *##,.             ./((*,                         "
echo "                                .*.             .(                              "
echo "                              #**.. . *      ../#.                              "
echo "                            #,  (.*..* .. . ,%                                  "
echo "                          *%.   ((. ,*  *.. #.   ###                            "
echo "                        /, (    (..,((,*.,##/  .# /(/(#.                        "
echo "                       (.  /    #.........*,(/ //.((,,(*                        "
echo "                      #,   ..   /,(*.....//*. /#..#/ (*.                        "
echo "                     *,    ((   .*.......,/ *  . *..*./#,(,                     "
echo "                     %      &/   #,......,/ (.      *..,#(                      "
echo "                     #       (   ,(......*/.*       .*#.(                       "
echo "                     ------------------------------------                       "

# Change to script directory
cd $(dirname $0)

# Detect OS
case "$(uname -s)" in
    Linux*)     OS=Lnx && MD5BIN=md5sum && PATH_SQLBIN="../sqlite/sqlite3-linux" && echo "Looks like you are running Linux";;
    Darwin*)    OS=Mac && MD5BIN=md5 && PATH_SQLBIN="../sqlite/sqlite3-osx" && echo "Looks like you are running OSX";;
    CYGWIN*)    OS=Win && MD5BIN=md5sum && PATH_SQLBIN="../sqlite/sqlite3-win32" && echo "Looks like you are running Windows";;
    MINGW*)     OS=Win && MD5BIN=md5sum && PATH_SQLBIN="../sqlite/sqlite3-win32" && echo "Looks like you are running Windows";;
    *)          echo "Could not detect your type of operating system. Ex(c)iting..." && exit 3
esac

# Finding bash history file
PATH_HISTORY=$(echo $HISTFILE)

# Try finding the DB within user dir, else create a new one
PATH_DB="../zerstreutDB.sqlite"
if [ -f "$PATH_DB" ]; then
    echo "Found database at $PATH_DB"
else
    echo "No database found at $PATH_DB; creating new database..."
    createDatabase
fi
# Set up cronjob (TDB)
bash zerstreutWorker.sh $PATH_HISTORY $PATH_SQLBIN $PATH_DB $MD5BIN

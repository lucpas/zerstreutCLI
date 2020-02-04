#!/bin/bash

# Helper functions
createDatabase() {
    echo "Creating DB..."
    $PATH_SQLBIN $PATH_DB "
    CREATE TABLE IF NOT EXISTS commands (
        hash TEXT PRIMARY KEY,
        timestamp INTEGER,
        command TEXT NOT NULL,
        options TEXT,
        tag TEXT UNIQUE
        )"
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
    CYGWIN*)    OS=Win && MD5BIN=md5sum && PATH_SQLBIN="../sqlite/sqlite3-win32.exe" && echo "Looks like you are running Windows";;
    MINGW*)     OS=Win && MD5BIN=md5sum && PATH_SQLBIN="../sqlite/sqlite3-win32.exe" && echo "Looks like you are running Windows";;
    *)          echo "Could not detect your type of operating system. Exiting..." && exit 3
esac

# Bash specific files
PATH_HISTORY=~/.bash_history
PATH_PROFILE=~/.bash_profile
PATH_RC=~/.bashrc

# Try finding the DB within user dir, else create a new one
PATH_DB="../zerstreutDB.sqlite"
if [ -f "$PATH_DB" ]; then
    echo "Found database at $PATH_DB"
else
    echo "No database found at $PATH_DB; creating new database..."
    createDatabase
fi

# Create config
echo "Creating config..."
rm -f "../.config"
echo $PWD >> "../.config"
echo $PATH_HISTORY >> "../.config"
echo $PATH_SQLBIN >> "../.config"
echo $PATH_DB >> "../.config"
echo $MD5BIN >> "../.config"

# Write call to worker script into bash profile
echo "Writing call to worker script into bash profile..."
awk '!/zerstreutWorker/' $PATH_PROFILE > temp && mv temp $PATH_PROFILE
echo "bash $PWD/zerstreutWorker.sh" >> $PATH_PROFILE

# Add client to bashrc file
echo "Writing 'zerstreut' as alias for client script into bash rc..."
awk '!/zerstreutClient/' $PATH_RC > temp && mv temp $PATH_RC
echo "alias zerstreut='$PWD/zerstreutClient.sh'" >> $PATH_RC

# Set up cronjob
echo "Setting up cronjob..."
case $OS in
    Lnx) ;;
    Mac)
        # Store all cronjobs into temporary file
        crontab -l > mycrons
        # Remove cronjob if it already exists
        awk '!/zerstreutWorker/' mycrons > temp && mv temp mycrons
        # Write new cronjob into temp file
        echo "*/5 * * * * bash $PWD/zerstreutWorker.sh" >> mycrons
        # Feed temp file into crontab
        crontab mycrons
        # Remove temp file
        rm mycrons
        ;;
    ?)
esac

# Make worker and client executable
echo "Making client and worker executable..."
chmod u+x zerstreutClient.sh
chmod u+x zerstreutWorker.sh

# initial run
echo "Starting initial worker run..."
bash zerstreutWorker.sh

#!/bin/bash

abort() {
  echo $@
  exit 1
}

cd $(dirname "$0")

echo "1/5 - Cleaning up bash profile"
awk '!/zerstreutWorker/' ~/.bash_profile > temp && mv temp ~/.bash_profile

echo "2/5 - Cleaning up bash rc"
awk '!/zerstreutClient/' ~/.bashrc > temp && mv temp ~/.bashrc

echo "3/5 - Deleting cronjob"
case "$(uname -s)" in
    Linux*)
        crontab -l > mycrons
        awk '!/zerstreutWorker/' mycrons > temp && mv temp mycrons
        crontab mycrons
        rm mycrons
        ;;
    Darwin*)
        crontab -l > mycrons
        awk '!/zerstreutWorker/' mycrons > temp && mv temp mycrons
        crontab mycrons
        rm mycrons
        ;;
    ?)
esac

echo "4/5 - Deleting database"
rm ../zerstreutDB.sqlite

echo "5/5 - Deleting config"
rm ../.config

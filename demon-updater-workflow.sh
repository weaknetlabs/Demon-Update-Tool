#!/usr/bin/env bash
# This is the workflow of the updater It will call scripts based on the version of Demon Linux
# 2019 - WeakNet Labs - Douglas Berdeaux, DemonLinux.com ^vv^
#
source ~/.bashrc
#DUT_SCRIPT=/usr/local/sbin/$(basename "$0") # the name of this script
export DUT_SCRIPT=/var/demon/updater/code/Demon-Update-Tool/demon-updater-workflow.sh
export DUT_LEVELS=/var/demon/updater/code/Demon-Update-Tool/update_scripts/
export DUT_SCRIPT_CHECKSUM=$(md5sum $DUT_SCRIPT|awk '{print $1}') # This will generate an md5
export DUT_HIGHEST_LEVEL=$(ls $DUT_LEVELS|sort -u|tail -n 1|awk -F. '{print $1}')
export DUT_GRN="\033[1;32m"
export DUT_RST="\033[0m"
export DUT_CYN="\033[1;36m"
export DUT_YLW="\033[1;33m"
export DUT_RED="\033[1;31m"
export DUT_NOTIFY_APP="Demon Update Tool Notification"
export DUT_NOTIFY_ICON="--icon=/usr/share/demon/images/icons/updater.png"

log () { # pass to me the phrase to be logged only as a string
  printf "${DUT_GRN}[${DUT_CYN}$(basename "$0")${DUT_YLW} log${DUT_GRN}]${DUT_RST}: $1 \n"
}

setCurrentLevel () { # pass to me the version to log the update
  log "Updating $(getCurrentLevel) to level $1 in /etc/demon/version"
  echo $1 > /etc/demon/version
}

notify () {
  notify-send "$1" "$2" $DUT_NOTIFY_ICON
}

getCurrentLevel () {
  echo $(cat /etc/demon/version)
}

export -f log
export -f setCurrentLevel
export -f getCurrentLevel
export -f notify

if [[ "$1" != "$DUT_SCRIPT_CHECKSUM" ]] # ensure this file is not called alone, ity must be called with it's own checksum
  then
    printf "\n[ERROR]: This script should not be called directly.\n\tPlease use the \"demon-updater.sh\" command\n\n" 1>&2
    printf "I got: $1, but I am $DUT_SCRIPT_CHECKSUM" 1>&2
    exit 1337
else
  #log "Initializing update tool"
  #log "Current version: $(getCurrentLevel)"
  log "Highest level available: $DUT_HIGHEST_LEVEL"
  if [[ $(getCurrentLevel) -lt $DUT_HIGHEST_LEVEL ]]
    then # System requires an update!
      DUT_NEXT_LEVEL=$(getCurrentLevel) # -1
      DUT_NEXT_LEVEL=$((DUT_NEXT_LEVEL+=1)) # 0, right?
      log "${DUT_RED}Demon requires update.${DUT_RST}"
      while [ $DUT_NEXT_LEVEL -le $DUT_HIGHEST_LEVEL ]
        do # run the script:
          log "Running update level: $DUT_NEXT_LEVEL"
          DUT_LEVEL_MD5=$(md5sum ${DUT_LEVELS}/${DUT_NEXT_LEVEL}.sh|awk '{print $1}')
          chmod +x ${DUT_LEVELS}/${DUT_NEXT_LEVEL}.sh # make sure we have execute permissions
          ${DUT_LEVELS}/${DUT_NEXT_LEVEL}.sh $DUT_LEVEL_MD5
          if [[ $? -eq 0 ]]
            then
              #log "Updating /etc/demon/version file, because \$\? = $?"
              setCurrentLevel $DUT_NEXT_LEVEL # record that we (at least tried) applied the update ...
              DUT_NEXT_LEVEL=$((DUT_NEXT_LEVEL+=1)) # postfix and run again ...
          else
            printf "${DUT_RED} SOMETHING WENT WRONG WITH ${DUT_LEVELS}/${DUT_NEXT_LEVEL}.sh ${DUT_RST}\n\n" 1>&2
            exit 57
          fi
      done
      log "${DUT_GRN}System at version $(getCurrentLevel). All updates are complete.${DUT_RST}"
      notify "$DUT_NOTIFY_APP" "The Demon is now up to date."
    else
    log "${DUT_GRN}System is already up to date. Version $(getCurrentLevel)${DUT_RST}"
    notify "$DUT_NOTIFY_APP" "The Demon is up to date."
  fi # done
fi

#!/usr/bin/env bash
# Structure the script accordingly.
# UPDATE FILE
# SHOULD NOT RUN ALONE
source ~/.bashrc
DUT_GRN="\033[1;32m"
DUT_RST="\033[0m"
DUT_CYN="\033[1;36m"
DUT_YLW="\033[1;33m"
DUT_RED="\033[1;31m"
DUT_SCRIPT=/var/demon/updater/code/Demon-Update-Tool/update_scripts/$(basename "$0")
DUT_SCRIPT_CHECKSUM=$(md5sum $DUT_SCRIPT|awk '{print $1}')
DUT_FILES=/var/demon/updater/code/Demon-Update-Tool/files
DEMON_BACKUPS=/usr/share/demon/backups/
DEMON_URL=https://demonlinux.com


if [[ "$1" != "$DUT_SCRIPT_CHECKSUM" ]] # ensure this file is not called alone, ity must be called with it's own checksum
  then
    printf "\n${DUT_RED}[$(basename "$0") ERROR]: This script should not be called directly.\n\tPlease use the \"demon-updater.sh\" command.${DUT_RST}\n\n" 1>&2
    exit 57
fi
log() {
  printf "${DUT_GRN}[${DUT_CYN}$(basename "$0")${DUT_YLW} log${DUT_GRN}]${DUT_RST}: $1 \n"
}
export -f log
log "Hello. I have initialized"
### Place all custom update code below this line.
#============================================================#
#$$$ Fix the UI House of Cards issue with XFCE4:
apt update >/dev/null
apt remove thunar-data thunar -y
mkdir /tmp/updater
cd /tmp/updater && wget http://ftp.us.debian.org/debian/pool/main/t/thunar/libthunarx-2-0_1.6.11-1_amd64.deb
cd /tmp/updater && wget http://ftp.us.debian.org/debian/pool/main/t/thunar/thunar-data_1.6.11-1_all.deb
cd /tmp/updater && wget http://deb.debian.org/debian/pool/main/t/thunar/thunar_1.6.11-1.debian.tar.xz
dpkg -i thunar-data_1.6.11-1_all.deb
dpkg -i libthunarx-2-0_1.6.11-1_amd64.deb
dpkg -i thunar_1.6.11-1_amd64.deb
apt -f install
#$$$ Make a couple new Dekstop icons:
wget https://demonlinux.com/download/files/images/icons/offsec.png -O /usr/share/demon/images/icons/offsec.png
wget https://demonlinux.com/download/files/desktop/provinggrounds.desktop -O /root/Desktop/provinggrounds.desktop
cp /usr/share/applications/Demon\ App\ Store.desktop /root/Desktop
#$$$
#$$$ Done

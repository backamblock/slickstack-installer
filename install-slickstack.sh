#!/bin/bash

####################################################################################################
#### author: TecFokus IT Solutions - https://tecfokus.com ##########################################
####################################################################################################

## This script configures custom SlickStack installations
##  1. update, upgrade, clean
##  2. get the current ss-config-sample file for SlickStack
##  3. replace user and password variables with randoms, change other settings
##  4. create the needed dirs and files for the installation
##  5. set ownership root:root
##  6. and finally start the SlickStack installation
##  7. install your public key afterwards so you can still use the password in case of emergency
##  8. install WP and stuff
##  9. save all important data in a file "DOMAIN-IP.txt" on your pc inside the server-configs folder

## includes
source key-vars.sh

NOCOLOR='\033[0m'
DARKGREEN='\033[0;32m'
DARKRED='\033[0;31m'

## warning message
echo -e ""
echo -e ""
echo -e ""
echo -e "${DARKRED}Be patient - this WILL take a while! ${NOCOLOR}"
echo -e "${DARKRED}It will update your server and install SlickStack ${NOCOLOR}"
echo -e "${DARKRED}The install can take up to 15 minutes ${NOCOLOR}"
echo -e ""
echo -e "${DARKRED}ATTENTION: DO NOT CLOSE THE TERMINAL ${NOCOLOR}"
echo -e "${DARKRED}ATTENTION: DO NOT LET YOUR PC SLEEP ${NOCOLOR}"
echo -e "${DARKRED}ATTENTION: DO NOT LOSE YOUR INTERNET CONNECTION ${NOCOLOR}"
echo -e "${DARKRED}you will be locked out from your VPS and need to reinstall the OS! ${NOCOLOR}"
echo -e ""
echo -e "${DARKRED}on mac - use amphetamine app ${NOCOLOR}"
echo -e "${DARKRED}on windows - disable standby in energy options ${NOCOLOR}"
echo -e "${DARKRED}on linux - you're pro, you don't need help <3 ${NOCOLOR}"
echo -e ""
echo -e "${DARKRED}oh... and make sure your VPS runs Ubuntu ;) ${NOCOLOR}"
echo -e ""
echo -e ""
read -p "READ CAREFULLY! Press ENTER to continue or CTRL + C to cancel... " -n1 -s
echo -e ""
read -p "ARE YOU SURE? Press ENTER to continue or CTRL + C to cancel... " -n1 -s

##################################################################
##  Install SSH Keys

ssh-keygen -R ${NEW_VPS_IP}
expect -c "spawn ssh root@${NEW_VPS_IP} ;
    expect yes/no;
    send yes\r;
    expect assword;
    send ${NEW_VPS_ROOT_PW}\r;
    expect ~#;
    send {cd ~/.ssh}; send \r;
    expect ssh#;
    send {touch authorized_keys}; send \r;
    expect ssh#;
    send {echo '${MY_ID_RSA_PUB}' >> 'authorized_keys'}; send \r ; 
    expect ssh#;
    send ~.;
    interact"


##################################################################
##  Send required files

echo -e "${DARKGREEN}Upload required files ${NOCOLOR}"

scp remote-install.sh root@${NEW_VPS_IP}:/tmp/remote-install.sh
scp output-config.sh root@${NEW_VPS_IP}:/tmp/output-config.sh
scp key-vars.sh root@${NEW_VPS_IP}:/tmp/key-vars.sh

##################################################################
##  Run installation

ssh -tt root@${NEW_VPS_IP} "bash /tmp/remote-install.sh"

##################################################################
##  Receive config file

echo -e "${DARKGREEN}Download config file ${SITE_DOMAIN}-${NEW_VPS_IP}.txt ${NOCOLOR}"

scp ${SUDO_USER}@${NEW_VPS_IP}:/tmp/serverconfig.txt server-configs/${SITE_DOMAIN}-${NEW_VPS_IP}.txt

##################################################################
## FINISH VPS

echo -e "${DARKGREEN}Reboot ${NOCOLOR}"

ssh -tt ${SUDO_USER}@${NEW_VPS_IP} <<EOF
sudo su
systemctl reboot -i
EOF

##################################################################
##  FINISH message

echo -e ""
echo -e "${DARKGREEN}FINISH - CHECK CONFIGURATION BACKUP !!! ${NOCOLOR}"
echo -e ""
echo -e ""
echo -e "${DARKRED}Your VPS is now rebooting ${NOCOLOR}"
echo -e ""
echo -e ""
echo -e "${DARKGREEN}Congratulations, enjoy your install ${NOCOLOR}"
echo -e "${DARKGREEN}Go to https://${SITE_DOMAIN}/wp-admin to finish WP setup${NOCOLOR}"
echo -e "${DARKGREEN}Find the login data above in red color or in your server-configs folder${NOCOLOR}"
echo -e "${DARKGREEN}If it is not ready yet, wait for the reboot to finish ${NOCOLOR}"

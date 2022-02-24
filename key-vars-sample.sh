#!/bin/bash

#########################################################
## input the link to your config file for installing all of your custom settings
## you can NOT leave this empty, you HAVE TO use a custom config file or keep the default value (my config)
## i will keep my ss-config-sample updated. feel free to notify me about a pending update
## you should be able to use the newest slickstack official config as well, but you need to check for changes
##
## make sure to use the "raw" file of github
## make sure to have the latest slickstack changes in your config file to prevent errors
##
## WARNING: do NOT replace the @PLACEHOLDERS that have to do with users/passwords/db for security reasons!
## this script will automagically generate secure values and replace these - see the bottom of this file for exact info
## when using your own config, you need to replace ALL PLACEHOLDERS that are not explicitly in this key-vars file!
##
## WARNING: you should set SS_CLEAN_FILES_WORDPRESS_PLUGINS and SS_CLEAN_FILES_WORDPRESS_CONTENT false!
## otherwise slickstack deletes wp-rocket and other plugins you install even if you allow in the blacklist

MY_SS_CONFIG="https://raw.githubusercontent.com/backamblock/slickstack-installer/main/ss-config-sample.txt"

# if you want to use a pilot file, you can specify the link here
# the pilot file will have more features in the future
# stay updated by following the official littlebizzy/slickstack repo

SS_PILOT_FILE="https://raw.githubusercontent.com/backamblock/slickstack-installer/main/ss-config-sample.txt"



#########################################################
## input your api keys, site data and VPS IP in this file
## VPS data first
## NEW_VPS_IP - IP or hostname.domain.tld of your VPS
## NEW_VPS_ROOT_PW - password for the VPS root account
## SUDO_USER - the new sudo user that slickstack creates
## note1: the current root user will be disabled by slickstack
## note2: the new user can NOT have the name "root" 

NEW_VPS_IP="xxx.xxx.xxx.xxx"
NEW_VPS_ROOT_PW=""

SUDO_USER="newusername" # must start with letter, only lowercase letters and numbers allowed!
SITE_TLD="domain.tld"
SITE_DOMAIN="domain.tld"



#########################################################
## Wordpress Settings

WP_ADMIN_EMAIL="mail@domain.tld"
WP_MULTISITE_STATUS="false" # will install multisite with subdomains
SS_LANGUAGE="de_DE" # must be a valid wordpress language format - en_US, de_DE currently supported

# install theme and page builder
# note that elementor does NOT work with slickstack staging! 
# for this and also pure performance i highly recommend to NOT use astra and elementor!
# you can still use astra starter sites with kadence theme and gutenberg
# "kadence" with Kadence Blocks or "false" to keep default theme

INSTALL_THEME="kadence"

# when installing plugins, make sure you check the blacklist!
# all default plugins in here are already excluded in my custom blacklist (see ss-config-sample)
# fork it and edit to your needs
# list plugins with spaces one after another like "plugin1 plugin2 plugin3"
# copy the exact spelling from the link: https://wordpress.org/plugins/PLUGIN-NAME-HERE/
# for premium Plugins you have to upload them manually after install

INSTALL_PLUGINS="true"
BASIC_PLUGINS="webp-express imagemagick-engine autodescription code-snippets loco-translate easy-wp-smtp"

INSTALL_WOOCOMMERCE="true"
WOOCOMMERCE_PLUGINS="woocommerce woocommerce-germanized woo-stripe-payment" # list them with spaces one after another

# installs some fixes to make slickstack work with wp-rocket or other caching plugins
# does NOT install wp-rocket !

INSTALL_WP_ROCKET="true"



#########################################################
## cloudflare - leave empty if not using CF

CLOUDFLARE_API_KEY="1234567890"
CLOUDFLARE_API_EMAIL="mail@gdomain.tld"



#########################################################
## SSH Public Key - Recommended to fill.
## works without it but will ask for Password some times
## paste content of keyfile id_rsa.pub

MY_ID_RSA_PUB="ssh-rsa XXXXX........XXXXX.local"



#########################################################
## rclone settings if you wish to use it
## only works for Backblaze b2 now
## set your keys and interval
## the backup will run after the dump command, so you can set it the same to save IOPS
## i recommend setting your lifecycle in b2 to 30 days to auto-delete ss-config backups
## see here: https://www.backblaze.com/b2/docs/file_versions.html
## and here: https://www.backblaze.com/b2/docs/lifecycle_rules.html
## read official ss-config-sample for more info about the settings

INTERVAL_SS_DUMP_DATABASE="hourly"
INTERVAL_SS_DUMP_FILES="never"
INTERVAL_SS_REMOTE_BACKUP="never" ## [half-daily|daily|half-weekly|weekly] default = never
RCLONE_CLIENT_ID="" # account key ID or application key ID
RCLONE_CLIENT_SECRET="" # master key or application key
RCLONE_REMOTE_PATH="/backup-websites-vps/${SITE_DOMAIN}" # /b2-bucketname/website-folder
RCLONE_BACKUP_PATH="/var/www/backups/" # /var/www/backups/ together with "DUMP_FILES" recommended
RCLONE_PARALLEL_TRANSFERS="15" ## default 15



#########################################################
#########################################################
#########################################################
## MORE INFO

#########################################################
## Which @PLACEHOLDERS are automatically generated and not mentioned above?
#########################################################
## SFTP_USER
## DB_USER
## DB_NAME
## DB_PREFIX
## GUEST_USER
## ROOT_PASSWORD
## SUDO_PASSWORD
## SFTP_PASSWORD
## DB_PASSWORD_USER
## DB_PASSWORD_ROOT
## GUEST_PASSWORD
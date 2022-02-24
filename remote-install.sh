#!/bin/bash

# includes
source /tmp/key-vars.sh
NOCOLOR='\033[0m'
DARKGREEN='\033[0;32m'
DARKRED='\033[0;31m'

## wordpress details
WP_ADMIN_USER="t$(openssl rand -hex 20 | cut -c1-16)"
WP_ADMIN_PASSWORD="$(openssl rand -base64 40 | tr -d '=+/' | cut -c1-32)"

## apt alias flags ##
function apt-get {
    export DEBIAN_FRONTEND=noninteractive
    export PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
    command /usr/bin/apt-get --yes --quiet --option Dpkg::Options::=--force-confold --option Dpkg::Options::=--force-confdef "$@"
}



##################################################################
##  1. update, upgrade, clean

echo -e "${DARKGREEN}Upgrade the server ${NOCOLOR}"

apt-get update && apt-get dist-upgrade && apt-get autoremove --purge && apt-get clean && apt-get install wget curl



##################################################################
##  2. get the current ss-config-sample file for SlickStack

echo -e "${DARKGREEN}Download custom ss-config ${NOCOLOR}"

mkdir -p /var/www/
wget -O /var/www/ss-config ${MY_SS_CONFIG}



##################################################################
##  3. replace all user and password variables with randomly generated ones

echo -e "${DARKGREEN}Replace ss-config users and passes with secure randoms ${NOCOLOR}"

## Users and Names
sed -i "s/@SFTP_USER/t$(openssl rand -hex 20 | cut -c1-9)/g" /var/www/ss-config
sed -i "s/@DB_USER/t$(openssl rand -hex 20 | cut -c1-9)/g" /var/www/ss-config
sed -i "s/@DB_NAME/t$(openssl rand -hex 20 | cut -c1-9)/g" /var/www/ss-config
sed -i "s/@DB_PREFIX/t$(openssl rand -hex 20 | cut -c1-4)_/g" /var/www/ss-config
sed -i "s/@GUEST_USER/t$(openssl rand -hex 20 | cut -c1-9)/g" /var/www/ss-config

## Passwords
sed -i "s#@ROOT_PASSWORD#$(openssl rand -base64 40 | tr -d '=+/' | cut -c1-32)#g" /var/www/ss-config
sed -i "s#@SUDO_PASSWORD#$(openssl rand -base64 40 | tr -d '=+/' | cut -c1-32)#g" /var/www/ss-config
sed -i "s#@SFTP_PASSWORD#$(openssl rand -base64 40 | tr -d '=+/' | cut -c1-32)#g" /var/www/ss-config
sed -i "s#@DB_PASSWORD_USER#$(openssl rand -base64 40 | tr -d '=+/' | cut -c1-32)#g" /var/www/ss-config
sed -i "s#@DB_PASSWORD_ROOT#$(openssl rand -base64 40 | tr -d '=+/' | cut -c1-32)#g" /var/www/ss-config
sed -i "s#@GUEST_PASSWORD#$(openssl rand -base64 40 | tr -d '=+/' | cut -c1-32)#g" /var/www/ss-config

## Site specific
echo -e "${DARKGREEN}Replace ss-config cariables with your key-vars ${NOCOLOR}"

sed -i "s/@SUDO_USER/${SUDO_USER}/g" /var/www/ss-config
sed -i "s/@SS_PILOT_FILE/${SS_PILOT_FILE}/g" /var/www/ss-config
sed -i "s/@SITE_TLD/${SITE_TLD}/g" /var/www/ss-config
sed -i "s/@SITE_DOMAIN/${SITE_DOMAIN}/g" /var/www/ss-config
sed -i "s|@SS_LANGUAGE|${SS_LANGUAGE}|g" /var/www/ss-config
sed -i "s/@WP_MULTISITE_STATUS/${WP_MULTISITE_STATUS}/g" /var/www/ss-config
sed -i "s/@CLOUDFLARE_API_KEY/${CLOUDFLARE_API_KEY}/g" /var/www/ss-config
sed -i "s/@CLOUDFLARE_API_EMAIL/${CLOUDFLARE_API_EMAIL}/g" /var/www/ss-config

## Rclone 
sed -i "s|\(^INTERVAL_SS_DUMP_DATABASE=\).*|INTERVAL_SS_DUMP_DATABASE=\"${INTERVAL_SS_DUMP_DATABASE}\"|g" /var/www/ss-config
sed -i "s|\(^INTERVAL_SS_DUMP_FILES=\).*|INTERVAL_SS_DUMP_FILES=\"${INTERVAL_SS_DUMP_FILES}\"|g" /var/www/ss-config
sed -i "s|\(^INTERVAL_SS_REMOTE_BACKUP=\).*|INTERVAL_SS_REMOTE_BACKUP=\"${INTERVAL_SS_REMOTE_BACKUP}\"|g" /var/www/ss-config
sed -i "s|\(^RCLONE_CLIENT_ID=\).*|RCLONE_CLIENT_ID=\"${RCLONE_CLIENT_ID}\"|g" /var/www/ss-config
sed -i "s|\(^RCLONE_CLIENT_SECRET=\).*|RCLONE_CLIENT_SECRET=\"${RCLONE_CLIENT_SECRET}\"|g" /var/www/ss-config
sed -i "s|\(^RCLONE_REMOTE_PATH=\).*|RCLONE_REMOTE_PATH=\"${RCLONE_REMOTE_PATH}\"|g" /var/www/ss-config
sed -i "s|\(^RCLONE_BACKUP_PATH=\).*|RCLONE_BACKUP_PATH=\"${RCLONE_BACKUP_PATH}\"|g" /var/www/ss-config
sed -i "s|\(^RCLONE_PARALLEL_TRANSFERS=\).*|RCLONE_PARALLEL_TRANSFERS=\"${RCLONE_PARALLEL_TRANSFERS}\"|g" /var/www/ss-config



##################################################################
##  4. create the needed dirs and files for the installation
##  ss-install throws errors if this is not done before.

echo -e "${DARKGREEN}Create directories and permissions ${NOCOLOR}"

mkdir -p /var/www
mkdir -p /var/www/auth
mkdir -p /var/www/backups
mkdir -p /var/www/backups/config
mkdir -p /var/www/backups/html
mkdir -p /var/www/backups/mysql
mkdir -p /var/www/backups/mysql/data
mkdir -p /var/www/cache
mkdir -p /var/www/cache/nginx
mkdir -p /var/www/cache/opcache
mkdir -p /var/www/cache/system
mkdir -p /var/www/certs
mkdir -p /var/www/certs/keys
mkdir -p /var/www/crons
mkdir -p /var/www/crons/custom
mkdir -p /var/www/html
mkdir -p /var/www/html/.well-known
mkdir -p /var/www/html/.well-known/acme-challenge
mkdir -p /var/www/logs
mkdir -p /var/www/meta
mkdir -p /var/www/meta/timestamps
mkdir -p /var/www/sites
touch -a /var/www/meta/.htpasswd

##  set ownership root:root
chown root:root /var/www ## must be root:root
chown root:root /var/www/backups ## must be root:root
chown root:root /var/www/backups/config ## must be root:root
chown root:root /var/www/backups/mysql ## must be root:root
chown root:root /var/www/backups/mysql/data ## must be root:root
chown root:root /var/www/cache/system ## must be root:root
chown root:root /var/www/certs ## must be root:root
chown root:root /var/www/certs/keys ## must be root:root
chown root:root /var/www/crons ## must be root:root
chown root:root /var/www/crons/custom ## must be root:root



##################################################################
##  5. Create users and Staging site 

## if staging enabled
source /var/www/ss-config

## create sftp user ##
adduser --disabled-password --quiet --shell /bin/bash --gecos "" $SFTP_USER
# echo "$SFTP_USER:$SFTP_PASSWORD" | sudo /usr/sbin/chpasswd
sudo echo "$SFTP_USER:$SFTP_PASSWORD" | sudo /usr/sbin/chpasswd
## ensure home directory exists ##
mkhomedir_helper $SFTP_USER
## ensure wordpress group exists ##
groupadd -f wordpress
## add SFTP_USER and www-data to wordpress group + add SFTP_USER to www-data group ##
usermod -a -G wordpress "$SFTP_USER"
usermod -a -G wordpress www-data
usermod -a -G www-data "$SFTP_USER"
#make dirs and fix permissions
mkdir /var/www/html/staging
mkdir /var/www/html/staging/.well-known
mkdir /var/www/html/staging/.well-known/acme-challenge
chown -R "${SFTP_USER}":www-data /var/www/html/staging/.well-known ## accessed by server for e.g. Cerbot but also by SFTP user for things like Stripe ##
chown -R "${SFTP_USER}":www-data /var/www/html/staging/.well-known/acme-challenge ## accessed by server for e.g. Cerbot but also by SFTP user for things like Stripe ##



##################################################################
##  6. start the SlickStack installation

echo -e "${DARKGREEN}Start Slickstack install ${NOCOLOR}"

cd /tmp/ && wget -O ss https://mirrors.slickstack.io/bash/ss-install.txt && bash ss



##################################################################
##  7. install authorized ssh keys

echo -e "${DARKGREEN}Install SSH Keys ${NOCOLOR}"

touch -a /var/www/auth/authorized_keys
echo "${MY_ID_RSA_PUB}" >> "/var/www/auth/authorized_keys"



##################################################################
##  8. Run post install script
echo -e " "
echo -e " "
echo -e " "
echo -e " "
echo -e " "
echo -e " "
echo -e "${DARKGREEN}Start post-install script ${NOCOLOR}"
echo -e " "
echo -e " "
echo -e " "

source /var/www/ss-config
source /var/www/ss-functions



################
##  8.1 WP INSTALL

echo -e "${DARKGREEN}Start WP install ${NOCOLOR}"

# finish wp-core install - set up admin user
WP_CLI_COMMAND="wp core install --url=${SITE_DOMAIN} --title=TecFokus-Lightning-VPS --admin_user=${WP_ADMIN_USER} --admin_password=${WP_ADMIN_PASSWORD} --admin_email=${WP_ADMIN_EMAIL} --skip-email"
sudo -u ${SFTP_USER} -i -- ${WP_CLI_COMMAND} --path='/var/www/html'

# delete useless plugins
echo -e "${DARKGREEN}Delete useless plugins ${NOCOLOR}"
sudo -u ${SFTP_USER} -i -- wp plugin delete --all --path='/var/www/html'
sudo -u ${SFTP_USER} -i -- wp plugin delete --all --path='/var/www/html/staging'

# delete all comments
echo -e "${DARKGREEN}Delete useless comments ${NOCOLOR}"
WP_CLI_COMMAND="wp comment delete $(sudo -u ${SFTP_USER} -i -- wp comment list --format=ids --path='/var/www/html') --force"
sudo -u ${SFTP_USER} -i -- $WP_CLI_COMMAND --path='/var/www/html'

# delete all posts
echo -e "${DARKGREEN}Delete useless posts ${NOCOLOR}"
WP_CLI_COMMAND="wp post delete $(sudo -u ${SFTP_USER} -i -- wp post list --format=ids --path='/var/www/html') --force"
sudo -u ${SFTP_USER} -i -- $WP_CLI_COMMAND --path='/var/www/html'

# delete all pages
echo -e "${DARKGREEN}Delete useless pages ${NOCOLOR}"
WP_CLI_COMMAND="wp post delete $(sudo -u ${SFTP_USER} -i -- wp post list --post_type='page' --format=ids --path='/var/www/html') --force"
sudo -u ${SFTP_USER} -i -- $WP_CLI_COMMAND --path='/var/www/html'

# delete all attachments
echo -e "${DARKGREEN}Delete useless attachments ${NOCOLOR}"
WP_CLI_COMMAND="wp post delete $(sudo -u ${SFTP_USER} -i -- wp post list --post_type='attachment' --format=ids --path='/var/www/html') --force"
sudo -u ${SFTP_USER} -i -- $WP_CLI_COMMAND --path='/var/www/html'

# delete Images in uploads folder
echo -e "${DARKGREEN}Delete useless media files ${NOCOLOR}"
rm -rf /var/www/html/wp-content/uploads/*
rm -rf /var/www/html/staging/wp-content/uploads/*



################
##  8.2 WP SETTINGS
## most of this is already done by slickstack, but here you can change them easily
# sudo -u ${SFTP_USER} -i -- wp option list --path='/var/www/html'
# sudo -u ${SFTP_USER} -i -- wp option update lalala "lelele" --path='/var/www/html'

# General
echo -e "${DARKGREEN}WP Settings - General ${NOCOLOR}"
sudo -u ${SFTP_USER} -i -- wp option update blogdescription "Hol dir das wahrscheinlich schnellste E-Commerce Hosting auf https://tecfokus.com" --path='/var/www/html'
sudo -u ${SFTP_USER} -i -- wp option update comment_registration "1" --path='/var/www/html'
sudo -u ${SFTP_USER} -i -- wp option update users_can_register "0" --path='/var/www/html'
sudo -u ${SFTP_USER} -i -- wp option update timezone_string "Europe/Berlin" --path='/var/www/html'
sudo -u ${SFTP_USER} -i -- wp option update date_format "Y-m-d" --path='/var/www/html'
sudo -u ${SFTP_USER} -i -- wp option update time_format "H:i" --path='/var/www/html'
sudo -u ${SFTP_USER} -i -- wp option update start_of_week "1" --path='/var/www/html'
sudo -u ${SFTP_USER} -i -- wp option update links_updated_date_format "__('Y-m-d H:i')" --path='/var/www/html'

# Discussion
echo -e "${DARKGREEN}WP Settings - Discussion ${NOCOLOR}"
sudo -u ${SFTP_USER} -i -- wp option update default_comment_status "closed" --path='/var/www/html'
sudo -u ${SFTP_USER} -i -- wp option update comment_max_links "1" --path='/var/www/html'
sudo -u ${SFTP_USER} -i -- wp option update comment_moderation "1" --path='/var/www/html'
sudo -u ${SFTP_USER} -i -- wp option update comments_notify "1" --path='/var/www/html'
sudo -u ${SFTP_USER} -i -- wp option update default_ping_status "closed" --path='/var/www/html'
sudo -u ${SFTP_USER} -i -- wp option update default_pingback_flag "0" --path='/var/www/html'
sudo -u ${SFTP_USER} -i -- wp option update moderation_notify "1" --path='/var/www/html'
sudo -u ${SFTP_USER} -i -- wp option update require_name_email "1" --path='/var/www/html'
sudo -u ${SFTP_USER} -i -- wp option update thread_comments "0" --path='/var/www/html'
sudo -u ${SFTP_USER} -i -- wp option update show_avatars "0" --path='/var/www/html'
sudo -u ${SFTP_USER} -i -- wp option update avatar_rating "G" --path='/var/www/html'
sudo -u ${SFTP_USER} -i -- wp option update avatar_default "identicon" --path='/var/www/html'
sudo -u ${SFTP_USER} -i -- wp option update close_comments_for_old_posts "0" --path='/var/www/html'
sudo -u ${SFTP_USER} -i -- wp option update close_comments_days_old "90" --path='/var/www/html'
sudo -u ${SFTP_USER} -i -- wp option update show_comments_cookies_opt_in "1" --path='/var/www/html'
sudo -u ${SFTP_USER} -i -- wp option update page_comments "1" --path='/var/www/html'
sudo -u ${SFTP_USER} -i -- wp option update comments_per_page "50" --path='/var/www/html'
sudo -u ${SFTP_USER} -i -- wp option update default_comments_page "newest" --path='/var/www/html'
sudo -u ${SFTP_USER} -i -- wp option update comment_order "desc" --path='/var/www/html'

# Misc
echo -e "${DARKGREEN}WP Settings - Other ${NOCOLOR}"
sudo -u ${SFTP_USER} -i -- wp option update uploads_use_yearmonth_folders "1" --path='/var/www/html'
sudo -u ${SFTP_USER} -i -- wp option update permalink_structure "/%postname%" --path='/var/www/html'
sudo -u ${SFTP_USER} -i -- wp option update blog_public "1" --path='/var/www/html'
sudo -u ${SFTP_USER} -i -- wp option update rss_language "de" --path='/var/www/html'
sudo -u ${SFTP_USER} -i -- wp option update rss_use_excerpt "1" --path='/var/www/html'
sudo -u ${SFTP_USER} -i -- wp option update use_smilies "0" --path='/var/www/html'



################
##  8.3 BASIC PLUGINS
## plugins for core functionality
## settings need to be done afterwards

if [ "$INSTALL_PLUGINS" == "true" ]; then
    echo -e "${DARKGREEN}Install basic plugins ${NOCOLOR}"
    sudo -u ${SFTP_USER} -i -- wp plugin install ${BASIC_PLUGINS} --path='/var/www/html'
fi

# set WP_DEBUG to false
# create 2 minute cron to self-heal in case of ss-update
WP_CRON="sed -i \"s|define('WP_DEBUG', true)|define('WP_DEBUG', false)|g\" /var/www/html/wp-config.php"
sed -i "s;## ADD CODE HERE ##;## ADD CODE HERE ##\n$WP_CRON;" /var/www/crons/custom/01-cron-often-custom

# remove entries in SS_CLEAN_FILES to delete mainwp stuff
WP_CRON="sed -i \"s|.*mainwp.*|echo notDeleteMain-wp|g\" /var/www/ss-clean-files"
sed -i "s;## ADD CODE HERE ##;## ADD CODE HERE ##\n$WP_CRON;" /var/www/crons/custom/01-cron-often-custom

# let cron half daily run cron 2 minutes so ss-clean-files does not get updated before it runs
# do NOT change "ss-clean-files" interval other than "half-daily"
WP_CRON="bash /var/www/crons/custom/01-cron-often-custom"
sed -i "s;## ADD CODE HERE ##;## ADD CODE HERE ##\n$WP_CRON;" /var/www/crons/custom/07-cron-half-daily-custom



################
##  8.4 THEME

if [ "$INSTALL_THEME" == "kadence" ]; then
    echo -e "${DARKGREEN}Install Kadence theme and Blocks plugin ${NOCOLOR}"

    # install and activate Kadence theme
    sudo -u ${SFTP_USER} -i -- wp theme install kadence --activate --path='/var/www/html'
    sudo -u ${SFTP_USER} -i -- wp theme install kadence --activate --path='/var/www/html/staging'

    # install and activate kadence blocks plugin
    sudo -u ${SFTP_USER} -i -- wp plugin install kadence-blocks --path='/var/www/html'

    # delete all other themes
    sudo -u ${SFTP_USER} -i -- wp theme delete --all --path='/var/www/html'
    sudo -u ${SFTP_USER} -i -- wp theme delete --all --path='/var/www/html/staging'
fi



################
##  8.5 WP ROCKET

if [ "$INSTALL_WP_ROCKET" == "true" ]; then 
    echo -e "${DARKGREEN}Install WP-Rocket fixes ${NOCOLOR}"

    # enable WP_CACHE for WP Rocket
    sed -i "s|define('WP_CACHE', false)|define('WP_CACHE', true)|g" /var/www/html/wp-config.php

    # create 2 minute crons to self-heal in case of ss-update
    # set wp cache = true
    WP_CRON="sed -i \"s|define('WP_CACHE', false)|define('WP_CACHE', true)|g\" /var/www/html/wp-config.php"
    sed -i "s;## ADD CODE HERE ##;## ADD CODE HERE ##\n$WP_CRON;" /var/www/crons/custom/01-cron-often-custom

    # set wp-rocket whitelabel
    # define ('WP_ROCKET_WHITE_LABEL_FOOTPRINT', true);
    # define ('WP_ROCKET_WHITE_LABEL_ACCOUNT', true);

    ## staging
    # enable WP_CACHE for WP Rocket
    sed -i "s|define('WP_CACHE', false)|define('WP_CACHE', true)|g" /var/www/html/staging/wp-config.php
    # create cron to self-heal in case of ss-update
    # set wp cache = true
    WP_CRON="sed -i \"s|define('WP_CACHE', false)|define('WP_CACHE', true)|g\" /var/www/html/staging/wp-config.php"
    sed -i "s;## ADD CODE HERE ##;## ADD CODE HERE ##\n$WP_CRON;" /var/www/crons/custom/01-cron-often-custom
    
fi



################
##  8.3 WOOCOMMERCE
## settings need to be done afterwards

if [ "$INSTALL_WOOCOMMERCE" == "true" ]; then
    echo -e "${DARKGREEN}Install Woocommerce and plugins ${NOCOLOR}"
    sudo -u ${SFTP_USER} -i -- wp plugin install ${WOOCOMMERCE_PLUGINS} --path='/var/www/html'
fi

# define encryption key for woocommerce germanized
# we do this here as a user may later need this and it does not impact performance
NEW_WC_GZD_ENCRYPTION_KEY="$(openssl rand -hex 64 | cut -c1-64)"
sed -i "s|// include ss-constants.php|define( 'WC_GZD_ENCRYPTION_KEY', '${NEW_WC_GZD_ENCRYPTION_KEY}' );|g" /var/www/html/wp-config.php

# create 2 minute cron to self-heal in case of ss-update
WP_CRON="sed -i \"s|// include ss-constants.php|define( 'WC_GZD_ENCRYPTION_KEY', '${NEW_WC_GZD_ENCRYPTION_KEY}' );|g\" /var/www/html/wp-config.php"
sed -i "s+## ADD CODE HERE ##+## ADD CODE HERE ##\n$WP_CRON+" /var/www/crons/custom/01-cron-often-custom
 
## staging
# create 2 minute cron to self-heal in case of ss-update
WP_CRON="sed -i \"s|// include ss-constants.php|define( 'WC_GZD_ENCRYPTION_KEY', '${NEW_WC_GZD_ENCRYPTION_KEY}' );|g\" /var/www/html/staging/wp-config.php"
sed -i "s+## ADD CODE HERE ##+## ADD CODE HERE ##\n$WP_CRON+" /var/www/crons/custom/01-cron-often-custom

# enable wp debug, log and display errors for staging
# create cron to self-heal in case of ss-update
WP_CRON="sed -i \"s|define('WP_DEBUG', false)|define('WP_DEBUG', true)|g\" /var/www/html/staging/wp-config.php"
sed -i "s;## ADD CODE HERE ##;## ADD CODE HERE ##\n$WP_CRON;" /var/www/crons/custom/01-cron-often-custom
    
WP_CRON="sed -i \"s|define('WP_DEBUG_DISPLAY', false)|define('WP_DEBUG_DISPLAY', true)|g\" /var/www/html/staging/wp-config.php"
sed -i "s;## ADD CODE HERE ##;## ADD CODE HERE ##\n$WP_CRON;" /var/www/crons/custom/01-cron-often-custom




################
##  8.7 FINISH


# install WP Language
echo -e "${DARKGREEN}Switch WP Language to ${SS_LANGUAGE} ${NOCOLOR}"

# wp site switch-language should be used in the future BUT IS NOT STABLE YET WITH PLUGINS AND THEMES
sudo -u ${SFTP_USER} -i -- wp language core install ${SS_LANGUAGE} --path='/var/www/html'
sudo -u ${SFTP_USER} -i -- wp language core activate ${SS_LANGUAGE} --path='/var/www/html'

sudo -u ${SFTP_USER} -i -- wp language theme install --all ${SS_LANGUAGE} --path='/var/www/html'
sudo -u ${SFTP_USER} -i -- wp language plugin install --all ${SS_LANGUAGE} --path='/var/www/html'

# activate all plugins and run cron
echo -e "${DARKGREEN}Activate plugins and run wp-cron ${NOCOLOR}"
sudo -u ${SFTP_USER} -i -- wp plugin activate --all --path='/var/www/html'
sudo -u ${SFTP_USER} -i -- wp cron event run --all --path='/var/www/html'

# sync staging
echo -e "${DARKGREEN}Sync staging site ${NOCOLOR}"
source /var/www/ss-sync-staging
source /var/www/

# reset permissions
echo -e "${DARKGREEN}Reset permissions ${NOCOLOR}"
source /var/www/ss-perms-wordpress-core
source /var/www/ss-perms-wordpress-config

# flush cache
echo -e "${DARKGREEN}Flush all Caches ${NOCOLOR}"
source /var/www/ss-purge-nginx
source /var/www/ss-purge-opcache
source /var/www/ss-purge-redis
source /var/www/ss-purge-transients

# print wordpress login data
echo -e " "
echo -e " "
echo -e " "
echo -e "${DARKRED}WP Admin Login: https://$SITE_DOMAIN/wp-admin ${NOCOLOR}"
echo -e "${DARKRED}WP Admin user: $WP_ADMIN_USER ${NOCOLOR}"
echo -e "${DARKRED}WP Admin password: $WP_ADMIN_PASSWORD ${NOCOLOR}"
echo -e "${DARKRED}WP Admin email: $WP_ADMIN_EMAIL ${NOCOLOR}"
echo -e " "
echo -e " "
echo -e " "



##################################################################
##  9. get current configuration and save to local file

echo -e "${DARKGREEN}Create server configuration file for download ${NOCOLOR}"

source /tmp/output-config.sh > /tmp/serverconfig.txt

# cleanup
echo -e "${DARKGREEN}Delete bash history ${NOCOLOR}"

rm ~/.bash_history
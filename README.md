# What is this?
### WARNING: read everything before usage!
## This script automates slickstack even more:
  1. update, upgrade, clean the VPS packages
  2. get your custom ss-config file for SlickStack (or the default, mine)
  3. replace user and password variables with secure randoms, change other settings with your data
  6. and start the SlickStack installation as usual
  7. install your public key afterwards so you can still use the password in case of emergency
  8. some post-install like finishing WP install, plugins, theme, ... disable what you don't need
  8. save all important data in a file "DOMAIN-IP.txt" on your pc inside the server-configs folder
_____
### 1 - What do I need to start?
* Ubuntu 20.04 VPS
* VSCode and logged in to git - no VSCode? terminal works fine
* this repo cloned LOCALLY on your PC!
* DO NOT fill in your API keys publicly in GitHub Web !!!
* a working VPS
* the VPS login user MUST be exactly "root"
* your VPS root password
* your public SSH key - when not set it will ask for password some times
* make sure DNS is set up with Cloudflare according to SlickStack requirements - SSL to full
* get "Account" API Key in Cloudflare
* leave Cloudflare VARs empty if you don't want to use CF

### 2 - input your data in key-vars.sh file
* open repo in vscode
* duplicate key-vars-sample.sh
* rename key-vars-sample.sh to key-vars.sh ONLY IN YOUR LOCAL ENVIRONMENT!
* edit your key-vars.sh
### 3 - run installer script
* open terminal in the project folder
* bash install-slickstack.sh
* enter password some times if no ssh key set
* get a coffee and let it finish - might take up to 15 min
* check output for errors
* if you set no ssh key the script will ask for NEW USER password 2x at the end - scroll up to colorful info screen
* check if config file was saved to your PC correctly
* wait for reboot to finish
* finish WP setup on your new website
## FINISHED - ENJOY!
### Please tell me how it worked for you! Just open an Issue :)
_____
### No VSCode? No Problem!
* it will work from a normal terminal
* VSCode just makes editing and running easier
* download or clone this repo to a local folder
* edit the files
* cd into the root folder of this repository
* go to section 3
_____
# Post install script
* install and setup Wordpress with admin user
* if enabled it will make additional settings
* set wp-config WP_CACHE to true for wp-rocket
* set up cron to prevent updates from deleting things
* install theme and plugins
* install woocommerce and plugins
_____
# ATTENTION

* Translation in slickstack only works for few select languages!
* you need to install your shop and make first setup in english/german no matter what!
* and you need to keep the site slugs english/german, like they are created by stock wp/woo
* install woocommerce in english/german or cart pages will be cached!
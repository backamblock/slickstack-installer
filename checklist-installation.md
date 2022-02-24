# Installation Checklist
-----
## Prerequisites
* get Domain
* get VPS
* get mail hosting (using netcup here)
-----
## 1 - Cloudflare
### NS Setup
* go Cloudflare
* add domain
* choose NS setup
* change domain registrar to Custom NS
* enter CF NS
* continue CF settings
### DNS for VPS
* A @ VPS-IP proxy
* A www VPS-IP proxy
* A staging VPS-IP proxy
* A www.staging VPS-IP proxy
* AAAA @ VPS-IP proxy
* AAAA www VPS-IP proxy
* AAAA staging VPS-IP proxy
* AAAA www.staging VPS-IP proxy
### DNS for Mail on netcup
* A webmail NC-IP proxy
* A mail NC-IP noproxy
* MX domain.tld mail.domain.tld priority:10
* TXT @ v=spf1 mx a include:domain.tld include:_spf.webhosting.systems ~all

-----
## 2 - Netcup Mail setup
### Plesk account setup
* add subscription and choose mail only package
* add domain
* disable webhosting
* go to SSL/TLS-certificates
* click Add certificate
* get CF cert 
### CF mail certificate
* CF -> SSL/TLS -> Origin certificate
* create certificate
* RSA(2048) - CF signed - 15 years (max available) - click create
* copy Private Key and certificate to Plesk
* click Upload on Plesk
* click OK on CF
### Mail accounts
* create auftrag@domain.tld account for transactional mail
* create team@domain.tld account for support, admin and catchall
* admin account used for DMARK reports and WP admin
-----
## 3 - install
* open VSCode bash terminal
* insert server IP, pw, Domain into key-vars
* edit key-vars settings if applicable
* insert cloudflare api key into key-vars
* cd into directory of install-slickstack.sh
* bash install-slickstack.sh
-----
## 4 - WP setup
* up to you
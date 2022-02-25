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
* for migration enter OLD HOST data first and change later

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
* TXT @ v=spf1 mx a include:_spf.webhosting.systems ~all

### DNSSEC Setup for Hosting
* CF -> DNS -> DNSSEC
* activate DNSSEC
* go to registrar and make DNSSEC entry
* confirm on cloudflare
* check back 1h later to see it confirmed

-----
## 2 - Netcup Mail

### Plesk account setup
* add subscription and choose mail only package
* add domain
* disable webhosting
* go to SSL/TLS-certificates
* click Add certificate
* get CF cert 

### Cloudflare mail certificate
* CF -> SSL/TLS -> Origin server
* create certificate
* add mail.domain.tld and webmail.domain.tld
* RSA(2048) - CF signed - 15 years (max available) - click create
* copy Private Key and certificate to Plesk
* click Upload on Plesk
* click OK on CF
* assign to mail and webmail on plesk

### Mail accounts
* create auftrag@domain.tld account for transactional mail
* create team@domain.tld account for support, admin and catchall
* admin account used for DMARK reports and WP admin

-----
## 3 - CF Settings 

### DNS
* all the above points and DNSSEC, nothing else

### SSL/TLS
* SSL Mode: full (not strict)
* -> Edge certificates
* always HTTPS: on
* HSTS: off
* minimum TLS: 1.1
* opportunistic encryption: on
* TLS 1.3: on
* automatic HTTPS rewrites: on
* certificate transparency: off

### Firewall
* -> Bots -> Bot Fight Mode off
* -> Settings
* Security: medium
* time window: 30 min
* integrity check: on
* privacy pass: on

### Speed
* -> Optimisation
* Auto minify: CSS JS HTML - all on
* Brotli: on
* Early hints: on
* Rocket Loader: off
* AMP Url: off (for now. check back later when and if AMP is used)
* Mobile redirect: off

### Caching
* -> Tiered Cache -> Argo Tiered Cache: on
* -> Configuration
* Caching level: standard
* Browser Cache TTL: 1 day
* Crawler notify: on (check back later if error)
* always online: off

### Network
* HTTP/2: on
* HTTP/3: on
* 0-RTT: on
* IPv6: on
* gRPC: off
* websockets: on
* onion routing: on
* pseudo IPv4: off
* IP geolocation: on

### Scrape Shield
* email protect: on
* serverside excludes: on
* hotlink protect: off 

-----
## 4 - Protect WP-Admin 

### Page rule wp-login
* -> Rules -> Page Rules
* Create page rule
* URL: domain.tld/wp-login*
* Security Level: High
* Position: First

### Page rule wp-admin
* -> Rules -> Page Rules
* Create page rule
* URL: domain.tld/wp-admin*
* Security Level: High
* Position: Last (second overall)

-----
## 5 - install
* activate cloudflare developer mode
* open VSCode bash terminal
* insert server IP, pw, Domain into key-vars
* edit key-vars settings if applicable
* insert cloudflare api key into key-vars
* cd into directory of install-slickstack.sh
* bash install-slickstack.sh


















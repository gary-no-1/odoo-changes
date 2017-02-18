# odoo-digitalocean-ubuntu-lamp-install
Automated Install Script For Odoo v8 with SSH &amp; Reverse Proxy

Odoo v9 is in progress and will be based on http://openies.com/blog/install-openerp-odoo-9-on-ubuntu-server-14-04-lts/

## Basis
There are several odoo installation scripts out there, the two below was the basis for this one.
 * http://www.schenkels.nl/2015/01/install-odoo-v8-0-from-github-ubuntu-14-04-lts-formerly-openerp/
 * http://www.theopensourcerer.com/2014/09/how-to-install-openerp-odoo-8-on-ubuntu-server-14-04-lts/

This script is specific to the platform target described below. If the above scripts do not work for you, you can always try this one.

## Platform 
* Digital Ocean
 * Ubuntu 14.04 64-bit
 * LAMP Stack
 * Python (already preinstalled, but need to install modules required by Odoo)
* Odoo V8.0 (Github branch 8.0)
* Postgres 9.3

## Features
* Install & Setup server prerequisites (e.g. timezone, git, etc.)
* Securing The System
 * HTTPS & Reverse Proxy (optional)
 * Primary & Backup Domain Name (optional)
 * Access to server via SSH key with passphrase (optional)
  * SSH Key sent mailed to user (you can remove/edit this)
 * Disable Root on SSH (optional)
 * Create sudo user (for editing & running commands)
 * TBD - add fail2ban
 * TBD - whitelist remote IP
* Create odoo system user
* Install postgres
 * No password, trust localhost
 * Create an odoo postgres user and create the templatedb for the user
 * TBD - postgres master-slave replication (HA, need another instance of PG running...)
* Install Odoo via Github
* Configure xmlrpc
* Install Odoo as a service

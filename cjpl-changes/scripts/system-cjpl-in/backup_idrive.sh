#!/bin/sh

# modified by ravi - 06-03-2016
# copies file to /home/idrive/data - for uploading to www.idrive.com

###########################################################
## rsync Odoo filestore on /home/idrive/data
###########################################################

# must be run as root since need to copy files from /home/cjpl-admin to /home/idrive 
#      and both are different users

filestore_loc="/home/cjpl-admin/odoo-backups/"
dest_loc="/home/idrive/data/"

echo $filestore_loc
echo $dest_loc

rsync -avh $filestore_loc $dest_loc

# also copy all scripts used in cron jobs

script_home_loc="/home/cjpl-admin/scripts/"
script_dest_loc="/home/idrive/data/scripts/"

echo $script_home_loc
echo $script_dest_loc

rsync -avh $script_home_loc $script_dest_loc

exit 0

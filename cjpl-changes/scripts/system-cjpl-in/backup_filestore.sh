#!/bin/sh

###########################################################
## rsync Odoo filestore
###########################################################

filestore_loc="/opt/odoo/.local/share/Odoo/filestore/cjpl-prod/"
dest_loc="/home/cjpl-admin/odoo-backups/filestore/cjpl-prod/"

echo $filestore_loc
echo $dest_loc

rsync -avh $filestore_loc $dest_loc


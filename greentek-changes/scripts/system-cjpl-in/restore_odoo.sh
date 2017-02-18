#!/bin/sh

#################################################################
## OpenERP Odoo restore
#################################################################

UNTAR_FILE_NAME="odoo_data_back.tar"
UNTAR_DIR="/home/rk/odoo-backups"

# remove all dump files from current directory
rm *.dump

tar -xf $UNTAR_FILE_NAME -C $UNTAR_DIR

# after untar , zip file(*.gz) will be in original directory path
ORIGINAL_PATH="home/cjpl-admin/odoo-backups"
ORIGINAL_PATH_START="home"

mv $ORIGINAL_PATH/*.gz .

rm -rf $ORIGINAL_PATH_START

gunzip *.gz

# get name of latest backup
RESTORE_DUMP=$(ls -tr *.dump | tail -n 1)

echo $RESTORE_DUMP

sudo -u odoo dropdb cjpl-prod

sudo -u odoo createdb -T template0 cjpl-prod

sudo -u odoo pg_restore -d cjpl-prod $RESTORE_DUMP


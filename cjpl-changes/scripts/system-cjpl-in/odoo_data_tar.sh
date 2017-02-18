#!/bin/bash

# #########################################################################################
# IGNORE COMMENTS HERE - WAS PREVIOUS VERSION
# #########################################################################################
# path where odoo backups are created daily
# ODOO_DATA_BACKUP="/opt/odoo/backups/"
# path where tar file is to be stored
# TAR_DIR="/home/cjpl-admin/odoo-backups/"
# get name of latest updated  backup
## FILE=$(ls -tr $ODOO_DATA_BACKUP | tail -n 1)
## echo $ODOO_DATA_BACKUP$FILE
# copy the latest backup only
## cp   $ODOO_DATA_BACKUP$FILE $TAR_DIR.
# tar the latest backup and remove it
# #########################################################################################

##########################################################
## OpenERP Odoo Backup II
## Backup of data + filestore + add-ons - copied to 10.0.0.15
##########################################################

# name of odoo data backup tar file
ODOO_TAR_TARGET="/home/cjpl-admin/odoo-backups/odoo_data_back.tar"
# odoo data files to be tar
ODOO_TAR_DATA_FILE="/home/cjpl-admin/odoo-backups/*.gz"
tar -cvf $ODOO_TAR_TARGET $ODOO_TAR_DATA_FILE --remove-files

# name of odoo filestore data backup tar file
ODOO_TAR_TARGET="/home/cjpl-admin/odoo-backups/odoo_filestore_back.tar"
# odoo data files to be tar
ODOO_TAR_FILESTORE_FILE="/home/cjpl-admin/odoo-backups/*.tgz"
tar -cvf $ODOO_TAR_TARGET $ODOO_TAR_FILESTORE_FILE --remove-files

# now tar /opt/odoo/custom/addons
ODOO_ADDONS="/opt/odoo/custom/addons/"
# name of tar file fot addons
ODOO_ADDONS_TAR="/home/cjpl-admin/odoo-backups/odoo_addons.tgz"
# tar the addons and gzip it
tar -cvzf $ODOO_ADDONS_TAR $ODOO_ADDONS

# rsync done to 10.0.0.15 - using ssh
# refer to -
#   superuser.com/question/555799/how-to-setup-rsync-without-password-with-ssh-on-unix-linux
#   www.thegeekstuff.com/2011/07/rsync-over-ssh-without-password/

rsync -avz -e ssh /home/cjpl-admin/odoo-backups/ cjpl-admin@10.0.0.15:/home/cjpl-admin/odoo-backups/

#SSH_USER="cjpl-admin@10.0.0.15"
# should be
# rsync -avz -e ssh $TAR_DIR $SSH_USER:$TAR_DIR

exit 0

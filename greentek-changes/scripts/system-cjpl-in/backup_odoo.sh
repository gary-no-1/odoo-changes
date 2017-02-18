#!/bin/sh

##########################################################
## OpenERP Odoo Backup
## Backup databses : cjpl-prod
##########################################################

# must be run as root since need (a) stop odoo-server (b) to run pg_dump as odoo - are required

# copied from https://www.odoo.com/forum/help-1/question/how-to-setup-a-regular-postgresql-database-backup-4728
# modified by ravi - 11-02-2016

# path where tar and zip files are to be stored for transfer to another server
TAR_DIR="/home/cjpl-admin/odoo-backups/"

# Stop Odoo Server
/etc/init.d/odoo-server stop

# Dump DBs and filestore
for db in cjpl-prod
do
  date=`date +"%Y%m%d_%H%M%N"`
  filename="/opt/odoo/backups/${db}_${date}.dump"
  #pg_dump -E UTF-8 -p 5433 -F p -b -f $filename $db
  sudo -u odoo pg_dump -E UTF8 -F c -f $filename $db
  gzip $filename

  gzfilename="/opt/odoo/backups/${db}_${date}.dump.gz"
  # set user and owner to "odoo" for ability to restore to postgres/odoo
  chown odoo:odoo $gzfilename

  # keep owner permissions while copying
  cp -p $gzfilename $TAR_DIR.

  ###########################################################
  ## rsync Odoo filestore
  ###########################################################

  filestore_loc="/opt/odoo/.local/share/Odoo/filestore/${db}/"
  dest_loc="/home/cjpl-admin/odoo-backups/filestore/${db}/"

  rsync -avh $filestore_loc $dest_loc

  ###########################################################
  ## tar and zip Odoo filestore
  ###########################################################
  
  tarfilename="/opt/odoo/backups/${db}_filestore_${date}.tgz"
  tar -czf $tarfilename $filestore_loc
  chown odoo:odoo $tarfilename

  cp -p $tarfilename $TAR_DIR.
  
done

# Start Odoo Server
/etc/init.d/odoo-server start

# now  remove all files which are more than 7 days old
ODOO_BACKUPS_DIR="/opt/odoo/backups"
path="/data/backuplog"
filename=log_back_$timestamp.txt
log=$ODOO_BACKUPS_DIR/delete_log.txt

find  $ODOO_BACKUPS_DIR -name "*.*" -type f -mtime +7 -print -delete >> $log

exit 0


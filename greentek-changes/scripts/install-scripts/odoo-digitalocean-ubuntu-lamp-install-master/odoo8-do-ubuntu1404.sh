#!/bin/bash
# https://github.com/aschenkels-ictstudio/openerp-install-scripts/blob/master/odoo-v8/ubuntu-14-04/odoo_install.sh
################################################################################
# Author: Aaron Gong
#-------------------------------------------------------------------------------
#  
# Install ODOO on Digital Ocean Ubuntu 14.04 LAMPP Server
#-------------------------------------------------------------------------------
# USAGE:
# odoo-install
# EXAMPLE:
# ./odoo-install 
#
################################################################################
echo 'Auto Install For DigitalOcean Ubuntu 14.04 x64 - LAMP STACK'

# Whitelist IP - TBD
WHITE_IP='203.211.138.221'
##Enter Github version for checkout
ODOO_VERSION="8.0"
ODOO_USER="odoo"
ODOO_HOME="/opt/$ODOO_USER"
ODOO_SERVER="$ODOO_HOME/$ODOO_USER-server" # OE_HOME_EXT
ODOO_ADDON="$ODOO_SERVER/custom_addons"
ODOO_CONFIG="$ODOO_USER-server"
ODOO_SUPERADMIN="password"

SERVER_NAME='myservername'

SSH_PORT=8022
SSH_USER='sshuser';
SSH_PASSPHRASE='sshuser_password'

PROXY_WAN_IP='10.172.128.157'
PROXY_WAN_GW='10.172.128.1'
PROXY_WAN_NM='255.255.192.0'
LAN_IP='10.130.33.111'
LAN_NM='255.255.0.0'

# erp
ODOO_HOST1='odoo.erp1.com'
ODOO_HOST2='odoo.erp2.com'
ODOO_LAN_IP='192.168.33.112'
#ODOO_XMLRPC='127.0.0.1'
ODOO_XMLRPC=$ODOO_LAN_IP

# php addons
OPHP_HOST1='api.erp1.com'
OPHP_HOST2='api.erp2.com'
OPHP_LAN_IP='192.168.44.173'
OPHP_DOCROOT='/var/www/html/myapi'

# read -p "Press any key to continue..."
echo 'Install Packages & Configure Timezone (y/n)?'
read ANS
if [ "$ANS" == "y" ];
then
	# Set timezone
	sudo timedatectl set-timezone Asia/Singapore #OLD sudo dpkg-reconfigure tzdata
	sudo apt-get -y update
	sudo apt-get -y upgrade # dist-upgrade
	sudo apt-get -y install ntp
	# emailer setup
	sudo apt-get -y install sendemail libio-socket-ssl-perl ## libnet-ssleay-perl libssl-dev #for TLS
fi

echo 'Create sudo user (y/n)?'
read ANS
if [ "$ANS" == "y" ];
then
	# Create SSH User
	adduser --disabled-password --gecos "" $SSH_USER
	echo "$SSH_USER:$SSH_PASSPHRASE" | chpasswd
	gpasswd -a $SSH_USER sudo
	
	echo "$SSH_USER ALL=NOPASSWD: /usr/lib/openssh/sftp-server" >> /etc/sudoers
	## add sudo /usr/lib/openssh/sftp-server to WinSCP sftp->sftp server option

	# Create Odoo user that will own and run the application: --shell=/bin/false or /usr/sbin/nologin
	sudo adduser --system --home=$ODOO_HOME --group $ODOO_USER
	#sudo adduser --system --home=$ODOO_HOME --group $ODOO_USER --quiet --shell=/bin/bash --gecos 'ODOO'

	echo -e "\n---- Create Log directory ----"
	sudo mkdir /var/log/$ODOO_USER
	sudo chown $ODOO_USER:$ODOO_USER /var/log/$ODOO_USER
	#sudo chown $ODOO_USER:root /var/log/$ODOO_USER

	# run Odoo server as odoo system user from command line if it has no shell (in odoo home directory), exit when done:
	#sudo su - odoo -s /bin/bash
fi

echo 'Configure SSH Keys (y/n)?'
read ANS
if [ "$ANS" == "y" ];
then
	# Generate Keys - as $SSH_USER
	su - $SSH_USER -c "ssh-keygen -f $SERVER_NAME -t rsa -N \"$SSH_PASSPHRASE\""
	su - $SSH_USER -c "sendemail -f from@def.com -t to@abc.com -u subject0 -m message0 -s smtp.gmail.com:587 -o tls=yes -xu from@def.com -xp EMAIL_PASSWORD -a $SERVER_NAME"
	su - $SSH_USER -c "mkdir .ssh"
	su - $SSH_USER -c "cat ${SERVER_NAME}.pub >> .ssh/authorized_keys"
	su - $SSH_USER -c "chmod 700 .ssh"
	su - $SSH_USER -c "chmod 600 .ssh/authorized_keys"
	su - $SSH_USER -c "rm ${SERVER_NAME}"
	su - $SSH_USER -c "rm ${SERVER_NAME}.pub"
fi

echo 'Install Odoo Requirements - Python & Postgres & Git(y/n)?'
read ANS
if [ "$ANS" == "y" ];
then
	# echo -e "\n---- Install tool packages ----"
	sudo apt-get -y install git # wget subversion git bzr bzrtools

	#python support
	sudo apt-get -y install libldap2-dev libsasl2-dev libxml2-dev libxslt1-dev python-dev lib32z1-dev
	#python pip & other python stuff
	sudo apt-get -y install python-pip
	sudo apt-get -y install python-imaging python-dateutil python-pychart python-docutils python-pypdf ython-feedparser python-ldap python-libxslt1 python-lxml python-mako python-openid python-psycopg2 python-pybabel python-pydot python-pyparsing python-reportlab python-simplejson python-tz python-vatnumber python-vobject python-webdav python-werkzeug python-xlwt python-yaml python-zsi python-psutil python-mock python-unittest2 python-jinja2 python-decorator python-requests python-passlib python-pil
	sudo apt-get -y install python-unicodecsv python-geoip python-gevent python-cups python-gdata 	
	# ?? echo -e "\n---- Install python libraries ----"
	# ?? sudo pip install gdata


	#wkhtmltopdf workaround
	#NO MORE sudo wget http://downloads.sourceforge.net/project/wkhtmltopdf/archive/0.12.1/wkhtmltox-0.12.1_linux-trusty-amd64.deb
	sudo wget http://download.gna.org/wkhtmltopdf/0.12/0.12.1/wkhtmltox-0.12.1_linux-trusty-amd64.deb
	sudo apt-get -f -y install
	sudo dpkg -i wkhtmltox-0.12.1_linux-trusty-amd64.deb
	sudo cp /usr/local/bin/wkhtmltopdf /usr/bin
	sudo cp /usr/local/bin/wkhtmltoimage /usr/bin
	sudo apt-get -f -y install

	# POSTGRES
# Step 3. Install and configure the database server, PostgreSQL
	sudo apt-get -y install postgresql postgresql-contrib postgresql-server-dev-9.3
#echo -e "\n---- PostgreSQL $PG_VERSION Settings  ----"
#sudo sed -i s/"#listen_addresses = 'localhost'"/"listen_addresses = '*'"/g /etc/postgresql/9.3/main/postgresql.conf
	#data - /var/lib/postgresql/9.3/main/
	#config - /etc/postgresql/9.3/main/
	# $ python --version
	# $ psql --version
	# $ psql -U postgres --version

	# create odoo postgres user
	## Now create a new database user. This is so Odoo has access rights to connect to PostgreSQL and to create and drop databases. If use pwpromt, remember what your choice of password is here; you will need it later on:
	##su - postgres -c "createuser -s $ODOO_USER" 2> /dev/null || true
	##sudo su - postgres
	##sudo -u postgres createuser --createdb --username postgres --no-createrole --no-superuser $ODOO_USER
	##sudo -u postgres dropuser odoo
sudo su - postgres -c "createuser --createdb --username postgres --no-createrole --no-superuser $ODOO_USER"
#pg_hba.conf - http://dba.stackexchange.com/questions/8111/pgadmin-iii-how-to-connect-to-database-when-password-is-empty
sudo sed -i -e "s|::1/128                 md5|::1/128                 trust|g" /etc/postgresql/9.3/main/pg_hba.conf
sudo sed -i -e "s|127.0.0.1/32            md5|127.0.0.1/32            trust|g" /etc/postgresql/9.3/main/pg_hba.conf
sudo service postgresql restart
	#createuser --createdb --username postgres --no-createrole --no-superuser --pwprompt odoo
	# ALTERNATIVE as $ODOO_USER, run createdb
fi

echo 'Install Apache & Php (y/n)?'
read ANS
if [ "$ANS" == "y" ];
then
	#apt-get -y install apache2
	a2enmod proxy_http headers rewrite ssl
	#apt-get -y install php5 libapache2-mod-php5 php5-mcrypt php5-pgsql php5-cgi php5-common
	mkdir $OPHP_DOCROOT
	chown -R www-data:www-data /var/www/html
	mkdir /etc/apache2/ssl
	openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -sha256 -keyout /etc/apache2/ssl/server.key -out /etc/apache2/ssl/server.crt -subj "/CN=127.0.0.1"
	#check cert: openssl x509 -noout -text -in techglimpse.com.crt
	#apache2ctl configtest
	# -sha256 
fi

echo 'HTTPS SERVER - CREATE IP ALIAS (y/n)?'
read ANS
if [ "$ANS" == "y" ];
then
# DOES NOT LAST: ifconfig eth1:0 $ODOO_LAN_IP
# DOES NOT LAST: ifconfig eth1:1 $OPHP_LAN_IP
cat >> /etc/network/interfaces <<EOL
## Already Setup on Digital Ocean if you enable Private Networking
# auto eth1
# iface eth1 inet static
#        address $LAN_IP
#        netmask $LAN_NM
iface eth1:0 inet static
	address $ODOO_LAN_IP
	netmask 255.255.0.0
iface eth1:1 inet static
	address $OPHP_LAN_IP
	netmask 255.255.0.0
EOL
ifup eth1:0
ifup eth1:1
# does not work: service networking restart
# does not work: /etc/init.d/networking restart
fi


echo 'Setup Reverse Proxy (y/n)?'
read ANS
if [ "$ANS" == "y" ];
then
cat > /etc/apache2/sites-available/888-default.conf <<EOL
# REVERSE PROXY

# Redirect Odoo - First
<VirtualHost *:80>
	ServerName $ODOO_HOST1
	Redirect permanent / https://$ODOO_HOST1/
</VirtualHost>
<VirtualHost *:80>
	ServerName $ODOO_HOST2
	Redirect permanent / https://$ODOO_HOST2/
</VirtualHost>

# PHP addons
<VirtualHost $OPHP_LAN_IP:80>
	ServerName $OPHP_LAN_IP
    DocumentRoot $OPHP_DOCROOT
</VirtualHost>

# Redirect all others on port 80 to Google
<VirtualHost *:80>
   ServerName $PROXY_WAN_IP
   ServerAlias *.*.*.* *.*.* *.*
   Redirect permanent / http://www.google.com/
</VirtualHost>

<VirtualHost *:443>
   ServerName $ODOO_HOST1
   ServerAlias $ODOO_HOST2
#ServerAdmin admin@localhost
#<Proxy *>
#	Order deny,allow
#	Deny from all
#	Allow from $WHITE_IP
#</Proxy>
#<Location /web/database>
#    Order deny,allow
#    Deny from all
#    Allow from $WHITE_IP
#</Location>
   SSLEngine on
   SSLProxyEngine on
   SSLCertificateFile /etc/apache2/ssl/server.crt
   SSLCertificateKeyFile /etc/apache2/ssl/server.key
   ProxyPreserveHost On
   ProxyPass / http://$ODOO_LAN_IP:8069/
   ProxyPassReverse / http://$ODOO_LAN_IP:8069/
#  ProxyPass /tab http://$OPHP_LAN_IP/
#  ProxyPassReverse /tab http://$OPHP_LAN_IP/
#  ProxyRequests Off
#  ProxyErrorOverride off
#Fix IE problem (httpapache proxy dav error 408/409)
#SetEnv proxy-nokeepalive 1
#   RequestHeader set "X-Forwarded-Proto" "https"   
</VirtualHost>

<VirtualHost *:443>
   ServerName $OPHP_HOST1
   ServerAlias $OPHP_HOST2
   SSLEngine on
   SSLProxyEngine on
   SSLCertificateFile /etc/apache2/ssl/server.crt
   SSLCertificateKeyFile /etc/apache2/ssl/server.key
   ProxyPreserveHost On
   ProxyPass / http://$OPHP_LAN_IP/
   ProxyPassReverse / http://$OPHP_LAN_IP/
</VirtualHost>

EOL
	a2dissite 000-default
	a2ensite 888-default
	#apachectl configtest
	service apache2 reload
	#service apache2 restart
fi

echo 'Install Odoo (y/n)?'
read ANS
if [ "$ANS" == "y" ];
then
	# ALTERNATIVE RUN AS ODOO USER sudo su - $ODOO_USER -s /bin/bash
	#$OE_VERSION https://www.github.com/odoo/odoo $OE_HOME_EXT/
	# NO NEED mkdir $ODOO_HOME - already created when odoo user is created
	# NO NEED mkdir $ODOO_SERVER - below will also create the folder $ODOO_SERVER
	git clone https://www.github.com/odoo/odoo --depth 1 --branch $ODOO_VERSION --single-branch $ODOO_SERVER
# may not need requirements.txt???
	pip install -r $ODOO_SERVER/requirements.txt

	mkdir $ODOO_ADDON
	chown -R $ODOO_USER:$ODOO_USER $ODOO_SERVER
	chown -R $ODOO_USER:$ODOO_USER $ODOO_ADDON

	# read -p "Edit Odoo Configuration. Press any key to continue..."
	sed -i -e "s|; admin_passwd.*|admin_passwd = $ODOO_SUPERADMIN|g" $ODOO_SERVER/debian/openerp-server.conf
	sed -i -e "s|db_user = odoo|db_user = $ODOO_USER|g" $ODOO_SERVER/debian/openerp-server.conf
	# if you use password for postgres instead of trust based authentication, then need to set db_password
	sed -i -e "s|addons_path.*|addons_path = $ODOO_SERVER/addons,$ODOO_ADDON|g" $ODOO_SERVER/debian/openerp-server.conf
	echo "xmlrpc_interface = $ODOO_XMLRPC" >> $ODOO_SERVER/debian/openerp-server.conf
	echo "logfile = /var/log/$ODOO_USER/$ODOO_CONFIG.log" >> $ODOO_SERVER/debian/openerp-server.conf

	#OPTION run odoo manually
	#su - $ODOO_USER -c -s /bin/bash "nohup /opt/odoo/odoo.py >/dev/null 2>&1 &"

	# copy config file
	cp $ODOO_SERVER/debian/openerp-server.conf /etc/$ODOO_CONFIG.conf
	chown $ODOO_USER:$ODOO_USER /etc/$ODOO_CONFIG.conf
	#chown $ODOO_USER: /etc/$ODOO_CONFIG.conf
	chmod 640 /etc/$ODOO_CONFIG.conf

	# create startup file
	#sudo su - odoo -s /bin/bash
	#sudo su root -c "echo '#!/bin/sh' >> $ODOO_SERVER/start.sh"
	#sudo su root -c "echo 'sudo -u $ODOO_USER $ODOO_SERVER/openerp-server --config=/etc/$ODOO_CONFIG.conf' >> $ODOO_SERVER/start.sh"
	echo '#!/bin/sh' >> $ODOO_SERVER/start.sh
	#echo 'sudo -u $ODOO_USER $ODOO_SERVER/openerp-server --config=/etc/$ODOO_CONFIG.conf' >> $ODOO_SERVER/start.sh
	echo "su -u $ODOO_USER -s /bin/bash -c \"$ODOO_USER $ODOO_SERVER/openerp-server --config=/etc/$ODOO_CONFIG.conf\"" >> $ODOO_SERVER/start.sh
	chmod 755 $ODOO_SERVER/start.sh
fi


echo 'Create Odoo Service File (y/n)?'
read ANS
if [ "$ANS" == "y" ];
then
cat > ~/$ODOO_CONFIG <<EOL
#!/bin/sh

### BEGIN INIT INFO
# Provides:             \$ODOO_CONFIG
# Required-Start:       \$remote_fs \$syslog
# Required-Stop:        \$remote_fs \$syslog
# Should-Start:         \$network
# Should-Stop:          \$network
# Default-Start:        2 3 4 5
# Default-Stop:         0 1 6
# Short-Description:    Complete Business Application software
# Description:          Odoo is a complete suite of business tools.
### END INIT INFO

PATH=/bin:/sbin:/usr/bin
DAEMON=$ODOO_SERVER/openerp-server
NAME=$ODOO_CONFIG
DESC=$ODOO_CONFIG

# Specify the user name (Default: odoo).
USER=$ODOO_USER

# Specify an alternate config file (Default: /etc/odoo-server.conf).
CONFIGFILE="/etc/$ODOO_CONFIG.conf"

# pidfile
PIDFILE=/var/run/$NAME.pid

# Additional options that are passed to the Daemon.
DAEMON_OPTS="-c \$CONFIGFILE"

[ -x \$DAEMON ] || exit 0
[ -f \$CONFIGFILE ] || exit 0

checkpid() {
    [ -f \$PIDFILE ] || return 1
    pid=\`cat \$PIDFILE\`
    [ -d /proc/\$pid ] && return 0
    return 1
}

case "\${1}" in
        start)
                echo -n "Starting \${DESC}: "
                start-stop-daemon --start --quiet --pidfile \${PIDFILE} --chuid \${USER} --background --make-pidfile --exec \${DAEMON} -- \${DAEMON_OPTS}
                echo "\${NAME}."
                ;;
        stop)
                echo -n "Stopping \${DESC}: "
                start-stop-daemon --stop --quiet --pidfile \${PIDFILE} --oknodo
                echo "\${NAME}."
                ;;
        restart|force-reload)
                echo -n "Restarting \${DESC}: "
                start-stop-daemon --stop --quiet --pidfile \${PIDFILE} --oknodo
                sleep 1
                start-stop-daemon --start --quiet --pidfile \${PIDFILE} --chuid \${USER} --background --make-pidfile --exec \${DAEMON} -- \${DAEMON_OPTS}
                echo "\${NAME}."
                ;;
        *)
                N=/etc/init.d/\${NAME}
                echo "Usage: \${NAME} {start|stop|restart|force-reload}" >&2
                exit 1
                ;;
esac

exit 0

EOL
fi

echo 'Install Service File(y/n)?'
read ANS
if [ "$ANS" == "y" ];
then
	mv ~/$ODOO_CONFIG /etc/init.d/$ODOO_CONFIG
	chmod 755 /etc/init.d/$ODOO_CONFIG
	chown root: /etc/init.d/$ODOO_CONFIG
	update-rc.d $ODOO_CONFIG defaults
	#update-rc.d -f $ODOO_CONFIG remove
	#sudo service $ODOO_CONFIG start
fi


# LASTLY
echo 'Configure Firewall (y/n)?'
read ANS
if [ "$ANS" == "y" ];
then
	#Firewall 
	ufw allow $SSH_PORT/tcp #SSH
	ufw allow 80/tcp #HTTP TO TRY AND CLOSE THIS UP - CURRENTLY CRASH IF CLOSED
	ufw allow 443/tcp #HTTPS - DMZ reverse proxy
	#noneed, outgoing allowed by default: ufw allow 25/tcp #SMTP
	#noneed, outgoing allowed by default: OK ufw allow 123/udp #NTP
	ufw --force enable

	# SSH Change Port
	sed -i -e "s|Port 22|Port $SSH_PORT|g" /etc/ssh/sshd_config
	#SSH Remove Root - Can only log in as user...
	sed -i -e "s|PermitRootLogin yes|PermitRootLogin no|g" /etc/ssh/sshd_config # disable root user on SSH
	sed -i -e "s|#PasswordAuthentication yes|PasswordAuthentication no|g" /etc/ssh/sshd_config # disable pw auth
	#sed -i -e "s|#UsePAM yes|UsePAM no|g" /etc/ssh/sshd_config # disable pam
	##RSAAuthentication yes, PubkeyAuthentication yes, ChallengeResponseAuthentication no
	##UsePAM no
	##AllowTcpForwarding no, X11Forwarding no
	##AllowUsers Fred Wilma
	##DenyUsers Dino Pebbles
	service ssh restart
	echo SSHD restarted
fi

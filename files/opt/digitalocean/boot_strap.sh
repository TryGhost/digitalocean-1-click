#!/bin/bash

export TERM=xterm-256color

# Commented out because exec stops this being interactive
# Logs please...
# log_f="${LOG_F:-/var/log/do-1click.log}"
# touch ${log_f}
# chmod 0600 ${log_f}
## Send the output from this file to stdout AND logs
# exec &> >(tee -a "$log_f")

# prevent locale warnings
touch /var/lib/cloud/instance/locale-check.skip

# Generate MySQL passwords
root_mysql_pass=$(openssl rand -hex 24)
ghost_mysql_pass=$(openssl rand -hex 24)
debian_sys_maint_mysql_pass=$(openssl rand -hex 24)
myip=$(hostname -I | awk '{print$1}')

mysqladmin -u root -h localhost create ghost_production 2>/dev/null 
mysqladmin -u root -h localhost password ${root_mysql_pass} 2>/dev/null 

# Create the Ghost MySQL user and grant permissions to them
mysql -uroot -p${root_mysql_pass} \
      -e "CREATE USER 'ghost'@'localhost' IDENTIFIED BY '${ghost_mysql_pass}'" 2>/dev/null 

mysql -uroot -p${root_mysql_pass} \
      -e "GRANT ALL PRIVILEGES ON ghost_production.* TO ghost@localhost" 2>/dev/null 

# Save the passwords
cat > /root/.digitalocean_password <<EOM
root_mysql_pass="${root_mysql_pass}"
ghost_mysql_pass="${ghost_mysql_pass}"
EOM

# Set up Postfix defaults
hostname=$(hostname)
sed -i "s/myhostname \= ghost/myhostname = $hostname/g" /etc/postfix/main.cf;
sed -i "s/inet_interfaces = all/inet_interfaces = loopback-only/g" /etc/postfix/main.cf;
systemctl restart postfix &

mysql -uroot -p${root_mysql_pass} \
      -e "ALTER USER 'debian-sys-maint'@'localhost' IDENTIFIED BY '${debian_sys_maint_mysql_pass}'" 2>/dev/null 

cat > /etc/mysql/debian.cnf <<EOM
# Automatically generated for Debian scripts. DO NOT TOUCH!
[client]
host     = localhost
user     = debian-sys-maint
password = ${debian_sys_maint_mysql_pass}
socket   = /var/run/mysqld/mysqld.sock
[mysql_upgrade]
host     = localhost
user     = debian-sys-maint
password = ${debian_sys_maint_mysql_pass}
socket   = /var/run/mysqld/mysqld.sock
EOM

# This is where the magic starts

# Upgrade Ghost-CLI
echo "Ensuring Ghost-CLI is up-to-date..."
su ghost-mgr -c "bash -x <<EOM
sudo npm i -g ghost-cli@latest
EOM"


echo "
Ghost will prompt you for two details:

1. Your domain
 - Add an A Record -> $(tput setaf 6)${myip}$(tput sgr0) & ensure the DNS has fully propagated
 - Or alternatively enter $(tput setaf 6)http://${myip}$(tput sgr0)
2. Your email address (only used for SSL)

$(tput setaf 2)Press enter when you're ready to get started!$(tput sgr0)
"

# Make sure the user is ready to install Ghost
read wait

# Install Ghost
sudo -iu ghost-mgr ghost install --auto \
  --db=mysql \
  --dbhost=localhost \
  --dbname=ghost_production \
  --dbuser=ghost \
  --dbpass=${ghost_mysql_pass} \
  --dir=/var/www/ghost \
  --start


# Final cleanup
cp /opt/digitalocean/99-one-click /etc/update-motd.d/99-one-click
chmod 0755 /etc/update-motd.d/99-one-click

# Remove nginx default site
rm -f /etc/nginx/sites-enabled/default
systemctl restart nginx

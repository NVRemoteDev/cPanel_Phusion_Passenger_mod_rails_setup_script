#!/bin/bash
# Script will setup ruby rails permissions when running phusion passenger on cPanel

echo -e "Setup your Ruby on Rails permissions on a cPanel server"
echo -e "Tested on Phusion Passenger/mod_rails and cPanel 11"
echo -e ""

echo -e "This script will add 2 lines to the end of your Gemfile (gem 'therubyracer' and gem 'execjs', as well as run a bundle install/bundle package"
echo -e "Please enter no at the next question if this is not OK"
echo -e ""

# Ensure user has setup a rails app already
echo "Have you already created your rails application (rails new app) [yes/no]?"
read answer
if [ "$answer" == "yes" ]; then
	echo "Continuing..."
else
	echo -e "run 'rails new your_app_name' in your desired directory (generally /home/username) before running this"
	exit
fi

# Get paths and login
echo -e "Enter your cPanel username (the username you use to login to cPanel): "
read cpanelLogin

echo -e "Enter your domain as it appears in cPanel (no http or www) i.e.: mydomain.com"
read domain

echo -e "Enter the FULL path to your Ruby application (no trailing slash) i.e.: /home/$cpanelLogin/railsapp"
read appPath

echo -e ""
echo -e "Enter public_html folder name (will be created) - no leading slash (i.e.: enter myrailsapp for http://www.$domain/myrailsapp) - Leave blank if whole domain will be a rails app *CAUTION*"
echo -e "No support for nested paths"
read urlPath

# Ensure correct information from user before continuing
echo -e "cPanel Login: $cpanelLogin ; Rails Application Path: $appPath ; URL Path: /home/$cpanelLogin/public_html/$urlPath ; Domain: $domain"
echo -e "Continue? [yes/no]:"
read answer
if [ "$answer" = "yes" ]; then
	echo "Continuing..."
else
	exit
fi

echo ""

# Add a symbolic link from public folder in rails app to URL path
echo -e "Adding symbolic link from $appPath to /home/$cpanelLogin/public_html/$urlPath"

ln -s $appPath/public/ /home/$cpanelLogin/public_html/$urlPath

# Add apache include file for domain
echo "Adding Apache include config"

# Randomize conf name if urlPath is blank, else just assign randomName to urlPath
if [ -z "$urlPath" ]; then
	randomName=`tr -dc "[:alpha:]" < /dev/urandom | head -c 8`
else
	randomName=$urlPath
fi

mkdir -p /usr/local/apache/conf/userdata/std/2/$cpanelLogin/$domain/

echo "RailsBaseURI /$urlPath" >> /usr/local/apache/conf/userdata/std/2/$cpanelLogin/$domain/$randomName.conf
echo "<Directory $appPath/public>" >> /usr/local/apache/conf/userdata/std/2/$cpanelLogin/$domain/$randomName.conf
echo "	Allow from all" >> /usr/local/apache/conf/userdata/std/2/$cpanelLogin/$domain/$randomName.conf
echo "	Options -MultiViews" >> /usr/local/apache/conf/userdata/std/2/$cpanelLogin/$domain/$randomName.conf
echo "</Directory>" >> /usr/local/apache/conf/userdata/std/2/$cpanelLogin/$domain/$randomName.conf

# Rebuild Apache confs
echo -e "Rebuilding Apache configurations.  This may take a minute."

/scripts/ensure_vhost_includes --user=$cpanelLogin
/usr/local/cpanel/bin/apache_conf_distiller --update
/usr/local/cpanel/bin/build_apache_conf
service httpd restart

# Set permissions
echo -e "Setting directory permissions to $cpanelLogin else 500 error will happen"
echo -e ""

chown -h $cpanelLogin:$cpanelLogin $appPath
chown -h $cpanelLogin:nobody /home/$cpanelLogin/$urlPath
chown -hR $cpanelLogin:nobody $appPath/*

# Add to gem file
echo -e "Adding gem lines"
echo \'gem therubyracer\' >> $appPath/Gemfile
echo \'gem execjs\' >> $appPath/Gemfile

# Installing Gems
echo -e "Installing gems. This may take a minute"
cd $appPath
bundle install --path vendor
echo -e ""
bundle package

echo -e "Restarting rails app..."
touch $appPath/tmp/restart.txt

echo -e ""
echo -e "Finished!  Implement routing and controllers manually"

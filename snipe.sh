#!/bin/bash

# Set your desired database credentials for Snipe-IT
db_user="snipeituser"
db_password="root"

# Set the MySQL root password
mysql_root_password="root"
export DEBIAN_FRONTEND=noninteractive
# Update the package list and upgrade installed packages
sudo apt update
sudo apt upgrade -y
# Install required dependencies
sudo apt install -y apache2  mariadb-server mariadb-client  php php-mysql php-gd php-ldap php-xml php-mbstring php-zip php-imap php-curl php-bcmath composer unzip

curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

sudo a2enmod rewrite

# Enable and start Apache and Mysql services
sudo systemctl enable apache2 
sudo systemctl enable mariadb 
sudo systemctl start apache2 
sudo systemctl start mariadb 

# Create a database for Snipe-IT and user
sudo mysql -u root -e "CREATE DATABASE snipeit;"
sudo mysql -u root -e "CREATE USER 'snipeituser'@'localhost' IDENTIFIED BY 'root';"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON snipeit.* TO 'snipeituser'@'localhost';"
sudo mysql -u root -e "FLUSH PRIVILEGES;"

# Restart Apache
sudo systemctl restart apache2 

# Download and install Snipe-IT

cd /var/www/

# C:/Users/sai/.ssh/1699108428_0625095.pub
#!/bin/bash

# Set the SSH private key file path (replace with the actual path to your private key)
ssh_key=" C:/Users/sai/.ssh/1699108428_0625095.pub"

# Set your Git repository URL (replace with your repository URL)
git_repo="git@github.com:PearlThoughtsInternship/snipe-it.git"

# Destination directory where the repository will be cloned
destination_dir="/tmp/script.sh"

# Configure SSH to use your private key for authentication
ssh-agent bash -c "ssh-add $ssh_key; git clone $git_repo $destination_dir"

# sudo git clone git@github.com:PearlThoughtsInternship/snipe-it.git
#cd snipe-it

# Configure your .env file with your database settings and app key
sudo cp .env.example .env
sudo sed -i "s/DB_DATABASE=.*/DB_DATABASE=snipeit/" .env
sudo sed -i "s/DB_USERNAME=.*/DB_USERNAME=snipeituser/" .env
sudo sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=root/" .env
sudo sed -i "s/APP_URL=.*/APP_URL=/" .env

# Set the appropriate permissions
sudo chown -R www-data:www-data /var/www/snipe-it
sudo chmod -R 755 /var/www/snipe-it

# install composer dependencies
COMPOSER_ALLOW_SUPERUSER=1 sudo composer install -n --no-dev --no-plugins --no-scripts

yes | sudo php artisan key:generate

# Migrate the database
yes | sudo php artisan migrate

# Configure Apache for Snipe-IT

sudo a2dissite 000-default.conf
sudo systemctl reload apache2

# Create an Apache virtual host configuration for Snipe-IT
sudo cat <<EOL | sudo tee /etc/apache2/sites-available/snipe-it.conf
<VirtualHost *:80>
ServerName snipe-it.syncbricks.com
DocumentRoot /var/www/snipe-it/public
<Directory /var/www/snipe-it/public>
Options Indexes FollowSymLinks MultiViews
AllowOverride All
Order allow,deny
allow from all
</Directory>
</VirtualHost>
EOL

sudo a2ensite snipe-it.conf

sudo systemctl reload apache2

sudo chown -R www-data:www-data ./storage
sudo chmod -R 755 ./storage

sudo systemctl restart apache2 

# Optionally, open the firewall ports if necessary
sudo ufw allow 80,443/tcp
unset DEBIAN_FRONTEND
echo "Snipe-IT installation is complete. Access your Snipe-IT instance in your web browser."
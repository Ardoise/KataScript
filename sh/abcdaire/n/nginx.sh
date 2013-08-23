#
sudo apt-get install -y nginx

# Site Configuration
# Download an example site config:

sudo cp lib/support/nginx/gitlab /etc/nginx/sites-available/gitlab
sudo ln -s /etc/nginx/sites-available/gitlab /etc/nginx/sites-enabled/gitlab

# Make sure to edit the config file to match your setup:

# Change YOUR_SERVER_FQDN to the fully-qualified
# domain name of your host serving GitLab.
sudo editor /etc/nginx/sites-available/gitlab

# Restart
sudo service nginx restart

# Create a git user for Gitlab:
sudo adduser --disabled-login --gecos 'GitLab' git

# GitLab Shell is a ssh access and repository management software developed specially for GitLab.

# Go to home directory
cd /home/git

# Clone gitlab shell
sudo -u git -H git clone https://github.com/gitlabhq/gitlab-shell.git

cd gitlab-shell

# switch to right version
sudo -u git -H git checkout v1.7.0

sudo -u git -H cp config.yml.example config.yml

# Edit config and replace gitlab_url
# with something like 'http://domain.com/'
sudo -u git -H editor config.yml

# Do setup
sudo -u git -H ./bin/install


# We'll install GitLab into home directory of the user "git"
cd /home/git

# Clone the Source

# Clone GitLab repository
sudo -u git -H git clone https://github.com/gitlabhq/gitlabhq.git gitlab

# Go to gitlab dir
cd /home/git/gitlab

# Checkout to stable release
sudo -u git -H git checkout 6-0-stable


### Configure it

cd /home/git/gitlab

# Copy the example GitLab config
sudo -u git -H cp config/gitlab.yml.example config/gitlab.yml

# Make sure to change "localhost" to the fully-qualified domain name of your
# host serving GitLab where necessary
sudo -u git -H editor config/gitlab.yml

# Make sure GitLab can write to the log/ and tmp/ directories
sudo chown -R git log/
sudo chown -R git tmp/
sudo chmod -R u+rwX  log/
sudo chmod -R u+rwX  tmp/

# Create directory for satellites
sudo -u git -H mkdir /home/git/gitlab-satellites

# Create directories for sockets/pids and make sure GitLab can write to them
sudo -u git -H mkdir tmp/pids/
sudo -u git -H mkdir tmp/sockets/
sudo chmod -R u+rwX  tmp/pids/
sudo chmod -R u+rwX  tmp/sockets/

# Create public/uploads directory otherwise backup will fail
sudo -u git -H mkdir public/uploads
sudo chmod -R u+rwX  public/uploads

# Copy the example Unicorn config
sudo -u git -H cp config/unicorn.rb.example config/unicorn.rb

# Enable cluster mode if you expect to have a high load instance
# Ex. change amount of workers to 3 for 2GB RAM server
sudo -u git -H editor config/unicorn.rb

# Configure Git global settings for git user, useful when editing via web
# Edit user.email according to what is set in gitlab.yml
sudo -u git -H git config --global user.name "GitLab"
sudo -u git -H git config --global user.email "gitlab@localhost"
sudo -u git -H git config --global core.autocrlf input


### Configure GitLab DB settings

# Mysql
sudo -u git cp config/database.yml.mysql config/database.yml

or

# PostgreSQL
sudo -u git cp config/database.yml.postgresql config/database.yml

# Make sure to update username/password in config/database.yml.
# You only need to adapt the production settings (first part).
# If you followed the database guide then please do as follows:
# Change 'root' to 'gitlab'
# Change 'secure password' with the value you have given to $password
# You can keep the double quotes around the password
sudo -u git -H editor config/database.yml

# Make config/database.yml readable to git only
sudo -u git -H chmod o-rwx config/database.yml

# Install Gems

cd /home/git/gitlab

sudo gem install charlock_holmes --version '0.6.9.4'

# For MySQL (note, the option says "without ... postgres")
sudo -u git -H bundle install --deployment --without development test postgres aws

# Or for PostgreSQL (note, the option says "without ... mysql")
sudo -u git -H bundle install --deployment --without development test mysql aws


# Install Init Script

# Download the init script (will be /etc/init.d/gitlab):
sudo cp lib/support/init.d/gitlab /etc/init.d/gitlab
sudo chmod +x /etc/init.d/gitlab

# Make GitLab start on boot:
sudo update-rc.d gitlab defaults 21

# Start Your GitLab Instance
sudo service gitlab start
# or
sudo /etc/init.d/gitlab restart


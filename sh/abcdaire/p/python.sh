# run as root!
apt-get update -y
apt-get upgrade -y
apt-get install sudo -y

# Install vim and set as default editor
sudo apt-get install -y vim
sudo update-alternatives --set editor /usr/bin/vim.basic

# Install the required packages
sudo apt-get install -y build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libncurses5-dev libffi-dev curl git-core openssh-server redis-server checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev

# Make sure you have the right version of Python installed.
# Install Python
sudo apt-get install -y python

# Make sure that Python is 2.5+ (3.x is not supported at the moment)
python --version

# If it's Python 3 you might need to install Python 2 separately
sudo apt-get install python2.7

# Make sure you can access Python via python2
python2 --version

# If you get a "command not found" error create a link to the python binary
sudo ln -s /usr/bin/python /usr/bin/python2

# For reStructuredText markup language support install required package:
sudo apt-get install python-docutils

# Note: In order to receive mail notifications, make sure to install a mail server. 
# By default, Debian is shipped with exim4 whereas Ubuntu does not ship with one. 
# The recommended mail server is postfix and you can install it with:
sudo apt-get install -y postfix 



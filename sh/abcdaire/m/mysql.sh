# Install the database packages
sudo apt-get install -y mysql-server mysql-client libmysqlclient-dev

# Pick a database root password (can be anything), type it and press enter
# Retype the database root password and press enter

# Login to MySQL
mysql -u root -p

# Type the database root password

# Create a user for GitLab
# do not type the 'mysql>', this is part of the prompt
# change $password in the command below to a real password you pick
mysql> CREATE USER 'gitlab'@'localhost' IDENTIFIED BY '$password';

# Create the GitLab production database
mysql> CREATE DATABASE IF NOT EXISTS `gitlabhq_production` DEFAULT CHARACTER SET `utf8` COLLATE `utf8_unicode_ci`;

# Grant the GitLab user necessary permissions on the table.
mysql> GRANT SELECT, LOCK TABLES, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `gitlabhq_production`.* TO 'gitlab'@'localhost';

# Quit the database session
mysql> \q

# Try connecting to the new database with the new user
sudo -u git -H mysql -u gitlab -p -D gitlabhq_production

# Type the password you replaced $password with earlier

# You should now see a 'mysql>' prompt

# Quit the database session
mysql> \q

# You are done installing the database and can go back to the rest of the installation.

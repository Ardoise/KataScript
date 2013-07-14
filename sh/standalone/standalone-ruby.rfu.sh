#!/bin/sh

### BEGIN INIT INFO
# Provides: RubyVM: Rubies
# Short-Description: DEPLOY SERVER:
# Author: created by: https://github.com/Ardoise
# Update: last-update: 20130612
### END INIT INFO

# Description: SERVICE : Rubies
# - deploy ruby v2.0.0
# - deploy jruby v1.8.7
# - deploy rails vx.x.x
# - deploy puma vx.x.x
#
# Requires : you need root privileges tu run this script
# Requires : curl
#
# CONFIG:   [ "/etc/ruby", "/etc/ruby/test" ]
# BINARIES: [ "/opt/ruby/", "/usr/share/ruby/" ]
# LOG:      [ "/var/log/ruby/" ]
# RUN:      [ "/var/ruby/ruby.pid" ]
# INIT:     [ "/etc/init.d/ruby" ]
# PLUGINS:  [ "/usr/share/ruby/bin/plugin" ]

set -e

NAME=rvm
DESC="Ruby VM"
DEFAULT=/etc/default/$NAME

if [ `id -u` -ne 0 ]; then
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: You need root privileges to run this script"
  exit 1
fi

[ -d "/etc/ruby/test" ] || mkdir -p "/etc/ruby/test";
[ -d "/opt/ruby/" ] || mkdir -p "/opt/ruby";
[ -d "/var/log/ruby/" ] || mkdir -p "/var/log/ruby";

m=RVM;
case $m in
RVM|rvm)
  cat <<-'ZEOF' >standalone-ruby.getbin.sh
  #!/usr/bin/env bash

  # Install git
  curl -L https://get-git.rvm.io | sudo bash

  # Install RVM
  # https://rvm.io/rvm/install
  # rvm 1.20.13 (stable)
  # curl -0l https://get.rvm.io | sudo bash -s stable
  # rvm + ruby-2.0.0-p195
  curl -L https://get.rvm.io | bash -s stable --ruby
  # rvm + JRuby, Rails, Puma
  curl -L https://get.rvm.io | bash -s stable --ruby=jruby --gems=rails,puma
  
  curl -L https://get.rvm.io | bash -s stable --ruby=jruby --gems=Platform,open4,POpen4,i18n,multi_json,activesupport,addressable,builder,launchy,liquid,syntax,maruku,rack,sass,rack-protection,tilt,sinatra,watch,yui-compressor,bonsai,hpricot,mustache,rdiscount,ronn

  # * Platform (0.4.0)
  # * open4 (1.3.0)
  # * POpen4 (0.1.4)
  # * i18n (0.6.4)
  # * multi_json (1.7.3)
  # * activesupport (3.2.12)
  # * addressable (2.3.4)
  # * builder (3.2.0)
  # * launchy (2.3.0)
  # * liquid (2.5.0)
  # * syntax (1.0.0)
  # * maruku (0.6.1)
  # * rack (1.5.2)
  # * sass (3.2.8)
  # * rack-protection (1.5.0)
  # * tilt (1.4.0)
  # * sinatra (1.4.2)
  # * watch (0.1.0)
  # * yui-compressor (0.9.6)
  # * bonsai (1.4.8)
  # * hpricot (0.8.6)
  # * mustache (0.99.4)
  # * rdiscount (2.0.7.2)
  # * ronn (0.7.3)

  # Install some Rubies
  source "~/.rvm/scripts/rvm"
  # command rvm install 1.9.2,rbx,jruby
  # rvm install 1.9.2 ; rvm use 1.9.2 --default ; ruby -v ; which ruby
  
  rvm notes
  rvm list known
  rvm list
  
  echo progress-bar >> ~/.curlrc
  
ZEOF
chmod +x standalone-ruby.getbin.sh

;;
SRC|src)
  # SOURCE
  curl -0l ftp://ftp.ruby-lang.org/pub/ruby/2.0/ruby-2.0.0-p195.tar.gz
  # curl -0l http://rubyonrails.org/download
  gunzip ruby-2.0.0-p195.tar.gz
  tar xvf ruby-2.0.0-p195.tar
  cd ruby-2.0.0-p195
  ./configure --prefix=/usr/local --enable-shared
  make
  make install
  echo "Check if your ruby on rails package was successfully installed"
  echo "in /usr/local/bin/ and /usr/local/lib/ruby/"

  # Rubygems
  curl -0l http://production.cf.rubygems.org/rubygems/rubygems-2.0.3.tgz
  tar xvfz rubygems-2.0.3.tgz
  cd rubygems-2.0.3
  ruby setup.rb --help
  ruby setup.rb

;;
*)
 : 
;;
esac


exit 0

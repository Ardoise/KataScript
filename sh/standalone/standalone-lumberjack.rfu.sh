#!/bin/bash

# require : standalone-ruby.rfu.sh

#Installing 10 gems installed for fpm-0.4.37
gem install fpm
  
#Lumberjack
git clone https://github.com/jordansissel/lumberjack.git
cd lumberjack
make
make deb
make rpm


exit 0;

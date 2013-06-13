#!/bin/sh

m=RVM;
case $m in
RVM|rvm)
  cat <<-'ZEOF' >standalone-ruby.getbin.sh
  #!/usr/bin/env bash

  # Install git
  curl -Ol https://get-git.rvm.io | sudo bash

  # Install RVM
  # https://rvm.io/rvm/install
  # rvm 1.20.13 (stable)
  # curl -0l https://get.rvm.io | sudo bash -s stable
  # rvm + ruby-2.0.0-p195
  curl -L https://get.rvm.io | bash -s stable --ruby
  # rvm + JRuby, Rails, Puma
  curl -L https://get.rvm.io | bash -s stable --ruby=jruby --gems=rails,puma
  
  # Install some Rubies
  source "/usr/local/rvm/scripts/rvm"
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
;;
*)
 : 
;;
esac


exit 0

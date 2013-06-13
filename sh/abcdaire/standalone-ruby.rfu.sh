#!/bin/sh

m=SRC;
case $m in
SRC|src)
  # Installation of RVM in /usr/local/rvm/ is almost complete:
  # rvm 1.20.13 (stable)
  # ruby-2.0.0-p195
  curl -L https://get.rvm.io | bash -s stable --ruby
  
  
;;
BUG)
  yum check-update
  yum update
  yum -y install yum-utils
  yum list ruby

  cat <<EOF >/etc/yum.repos.d/ruby.repo
[ruby]
name=ruby
baseurl=http://repo.premiumhelp.eu/ruby/
gpgcheck=0
enabled=0
EOF
yum --enablerepo=ruby install ruby

yum install ruby-rdoc
yum install rubygem-state_machine-doc.noarch
git clone https://github.com/rdoc/rdoc

yum install ruby ruby-libs ruby-mode ruby-rdoc ruby-irb ruby-ri ruby-docs
yum install rdoc ri zlib zlib-devel

#rubygems.org
gem update --system
gem install rubygems-update
gem install rubygems-update --no-rdoc --no-ri
# gem install rdoc

# 
curl -Ol http://production.cf.rubygems.org/rubygems/rubygems-2.0.3.tgz
tar xvfz rubygems-2.0.3.tgz
cd rubygems-2.0.3
ruby setup.rb --help
ruby setup.rb --no-rdoc --no-ri
gem system update
gem build foo.gemspec
    #Build your gem
gem push foo-1.0.0.gem
    #Deploy your gem instantly
    
cd rubygems
ruby setup.rb


/usr/bin/gem update --system
#Updating RubyGems
#Updating rubygems-update
#Successfully installed rubygems-update-2.0.3
#Updating RubyGems to 2.0.3
#Installing RubyGems 2.0.3
#RubyGems 2.0.3 installed

;;
*)
 : 
;;
esac


exit 0

#!/usr/bin/env bash

[test1]
# Some description

echo "<%= name %>"

[test2]

echo "test2"

#######################################
[echo]

echo "Hello world!"


#######################################
[ubuntu_update]

sudo apt-get update


#######################################
[prepare_linux]
# Updates linux core packages

sudo apt-get update

sudo apt-get install -y curl
sudo apt-get install -y g++
sudo apt-get install -y subversion
sudo apt-get install -y git

# to support rvm

sudo apt-get install -y libreadline6-dev
sudo apt-get install -y zlib1g-dev
sudo apt-get install -y libssl-dev
sudo apt-get install -y libyaml-dev
sudo apt-get install -y libsqlite3-dev
sudo apt-get install -y sqlite3
sudo apt-get install -y autoconf
sudo apt-get install -y libgdbm-dev
sudo apt-get install -y libncurses5-dev
sudo apt-get install -y automake
sudo apt-get install -y libtool
sudo apt-get install -y bison
sudo apt-get install -y pkg-config
sudo apt-get install -y libffi-dev


#######################################
[rvm]
# Installs rvm

curl -L https://get.rvm.io | bash

#sudo chown -R vagrant /opt/vagrant_ruby


#######################################
[ruby]
# Installs ruby

source /usr/local/rvm/scripts/rvm

rvm install ruby-2.2.3


#######################################
[node]
# Installs node

sudo apt-get install -y node


#######################################
[rbenv]
# Installs node

sudo apt-get install -y rbenv
git clone git://github.com/jf/rbenv-gemset.git $HOME/.rbenv/plugins/rbenv-gemset


#######################################
[prepare]
# to support nokogiri
sudo apt-get install -y libgmp-dev

# to support capybara-webkit
sudo apt-get install -y libqt4-dev
sudo apt-get install -y libqtwebkit-dev

# to support headless
sudo apt-get install -y xvfb

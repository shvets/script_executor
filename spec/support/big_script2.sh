#!/bin/sh

#######################################
[chrome]

wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -

sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'

sudo apt-get update

sudo apt-get install -y google-chrome-stable


#######################################
[chromedriver]

sudo apt-get install -y unzip

wget -N http://chromedriver.storage.googleapis.com/2.20/chromedriver_linux64.zip -P ~/Downloads

unzip ~/Downloads/chromedriver_linux64.zip -d ~/Downloads

chmod +x ~/Downloads/chromedriver

sudo mv -f ~/Downloads/chromedriver /usr/local/share/chromedriver

sudo ln -s /usr/local/share/chromedriver /usr/local/bin/chromedriver

sudo ln -s /usr/local/share/chromedriver /usr/bin/chromedriver


#######################################
[ffmpeg]

sudo apt-get install -y ffmpeg
sudo apt-get install -y libav-tools


##############################
[firefox]

sudo apt-get install -y firefox


##############################
[project]
# Installs project

sudo sh -c 'echo "source /usr/local/rvm/scripts/rvm" >> ~/.bash_login'
sudo sh -c 'echo "cd acceptance_demo" >> ~/.bash_login'
sudo sh -c 'echo "rvm use @acceptance_demo" >> ~/.bash_login'

APP_HOME="#{project.home}"

cd $APP_HOME

source /usr/local/rvm/scripts/rvm

rvm use #{project.ruby_version}@#{project.gemset} --create

gem install --no-rdoc --no-ri bundler
gem install --no-rdoc --no-ri rake

bundle


##############################
[start]
# Starts tests

USER_HOME="#{node.home}"

APP_HOME="#{project.home}"

cd $APP_HOME

source /usr/local/rvm/scripts/rvm

rvm use #{project.ruby_version}@#{project.gemset}

rake

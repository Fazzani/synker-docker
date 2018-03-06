#!/bin/bash

set -euox

#---------------------------
# Variables
#---------------------------
webgrabDir="/app/wg++"
configDir="/config"
logfilename="webgrab.log"
repo_git_name="webgrab-configs"
repo_git_url="https://github.com/Fazzani/webgrab-configs.git"

#---------------------------
# Install all needed tools
#---------------------------
function install_necessary_packages {

  if wget --version >/dev/null 2>&1; then
    echo "wget Found"
  else
     /usr/bin/apt-get install -y git wget
  fi
}

#--------------------------
# Pushing to git
# params : git repo name
#--------------------------
function push_to_git
{
  # coping output file to git folder
  cp -f guide.tar.gz ./$repo_git_name/
  echo "push to git"
  cd $1

  git add --all
  now=$(date +"%c")
  git commit -m "new guide $now"
  git push
  cd ..
  return 0
}

#--------------------------
# Getting last version from git
# params : git repo url
# params : git repo name
#--------------------------
function latest_from_git
{
  echo "Getting latest version from repo git: $1 will be founded in $2" 
  if [[ ! -d $2 && ! -d $2/.git ]]; then
    echo "The repo $1 not exist so we clone it in $2"
    git clone $1
  fi

  cd $2
  git pull
  cp -f *.config.xml ../
  cd ..
  return 0
}

#--------------------------------------------- main ----------------------------------------------------
cd /config

install_necessary_packages

latest_from_git $repo_git_url $repo_git_name

for webGrab in ./*.config.xml; do

  echo "Processing webgrab file => $webGrab"
  echo "Moving $webGrab to WebGrab++.config.xml"
  cp -f $webGrab "$configDir/WebGrab++.config.xml"

  echo "Launching webgrab"
  wget https://api.pushover.net/1/messages.json \
    --post-data="token=a1zc9d81aw14ezws414n7uvsnz2xio&user=uxepp2gjx5ch4eveufj8fo8jmcm6we&device=sm-g935f&title=WebGrabber+message&message=WebGrabber+extrating+xmltv+file+launched.+Working+directory+:+$webGrab" \
    -qO-
  mono "$webgrabDir/bin/WebGrab+Plus.exe" $configDir
  message=$(tail -n2 $logfilename)
  wget https://api.pushover.net/1/messages.json \
    --post-data="token=a1zc9d81aw14ezws414n7uvsnz2xio&user=uxepp2gjx5ch4eveufj8fo8jmcm6we&device=sm-g935f&title=WebGrabber+message&message=$message." \
   -qO-

done

echo "End of grabbing"
echo "Compressing all xmltv"
tar -czf guide.tar.gz *.xmltv

#pushing to git
push_to_git $repo_git_url 

exit 0
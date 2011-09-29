#!/bin/bash

#---------------------------------------------------------------------
# ~/bin/ssh_first.sh
#
# @author: nagaoka_katsutoshi
# @since : 2011/09
# @usage : sh ./ssh_fiest.sh <host> [<option>]
#---------------------------------------------------------------------

# config
USER="nagaoka_katsutoshi"
HOME="/home/share/${USER}"
KEY="${HOME}/.ssh/id_rsa.pub"

# args
HOST=$1
OPTION=$2

# check parameter
if [ "x${HOST}" = "x" ]; then
  echo "Usage: $0 <host> [<option>]"
  exit 1
fi

# check host
ping -c 1 ${HOST} > /dev/null 2>&1
if [ $? != 0 ]; then
  echo "error: could not connect to server: ${HOST}"
  LIST=`cat ${HOME}/.ssh/known_hosts | cut -d" " -f1 | cut -d"," -f1 | grep "${HOST}"`
  if [ "${LIST}" != "" ]; then
    echo "server list extracted from known_hosts file: ${HOST}"
    for SERVER in ${LIST}; do
      echo "[*] ${SERVER}"
    done
  fi
  exit 1
fi

# ssh-keygen
while [ ! -f "${KEY}" ]; do
  echo "${KEY} is not found. create public key."
  ssh-keygen
done

# add authorized_keys
ssh ${USER}@${HOST} "grep \"`cat ${KEY}`\" ~/.ssh/authorized_keys > /dev/null 2>&1 \
|| ((test -d ~/.ssh || mkdir -p ~/.ssh) \
&& echo incert to public_key ; echo `cat ${KEY}` >> ~/.ssh/authorized_keys)"

# vimrc & plugin directory
function copyVimrc(){
  echo $@
  scp -p ~/.vimrc ${USER}@${HOST}:~/.vimrc > /dev/null 2>&1
  scp -rp ~/.vim ${USER}@${HOST}:~/.vim > /dev/null 2>&1
}

# bin directory
function copyBin(){
  echo $@
  scp -rp ~/bin ${USER}@${HOST}:~/bin > /dev/null 2>&1
}

# copy config files (overwrite mode)
if [ "${OPTION}" = "overwrite" ]; then
  copyVimrc "[overwrite] copy to vimrc & plugin directory"
  copyBin "[overwrite] copy to bin directory"

# copy config files (exist check mode)
else
  ssh ${USER}@${HOST} "test -f ~/.vimrc"
  if [ $? != 0 ]; then
    copyVimrc "copy to vimrc & plugin direcotory"
  fi
  ssh ${USER}@${HOST} "test -d ~/bin"
  if [ $? != 0 ]; then
    copyBin "copy to bin directory"
  fi
fi

# login
ssh ${USER}@${HOST}

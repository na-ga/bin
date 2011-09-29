#!/bin/bash

#---------------------------------------------------------------------
# ~/bin/ssh_first.sh
#
# @author: nagaoka_katsutoshi
# @since : 2011/09
# @usage : sh ./ssh_fiest.sh <host> [<option>]
#---------------------------------------------------------------------

# config
USER_NAME="${USER:-nagaoka_katsutoshi}"
HOME_DIR="${HOME:-/home/share/${USER_NAME}}"
PUBLIC_KEY="${HOME_DIR}/.ssh/id_rsa.pub"
KNOWN_HOSTS="${HOME_DIR}/.ssh/known_hosts"

# args
HOST_NAME=$1
OPTION=$2

# check parameter
if [ "x${HOST_NAME}" = "x" ]; then
  echo "Usage: $0 <host> [<option>]"
  exit 1
fi

# kown_hosts file check
function printServerList(){
  if [ ! -f ${KNOWN_HOSTS} ]; then
    return
  fi
  SERVER_LIST=`cat ${KNOWN_HOSTS} | cut -d" " -f1 | cut -d"," -f1 | grep "$@"`
  if [ "${SERVER_LIST}" = "" ]; then
    return
  fi
  echo "server list extracted from ${KNOWN_HOSTS}: $@"
  for SERVER in ${SERVER_LIST}; do
    echo "[*] ${SERVER}"
  done
}

# check host
ping -c 1 ${HOST_NAME} > /dev/null 2>&1
if [ $? != 0 ]; then
  echo "error: could not connect to server: ${HOST_NAME}"
  printServerList "${HOST_NAME}"
  exit 1
fi

# ssh-keygen
while [ ! -f "${PUBLIC_KEY}" ]; do
  echo "${PUBLIC_KEY} is not found. create public key."
  ssh-keygen
done

# add authorized_keys
ssh ${USER_NAME}@${HOST_NAME} "grep \"`cat ${PUBLIC_KEY}`\" ~/.ssh/authorized_keys > /dev/null 2>&1 \
|| ((test -d ~/.ssh || mkdir -p ~/.ssh) \
&& echo incert to public_key ; echo `cat ${PUBLIC_KEY}` >> ~/.ssh/authorized_keys)"

# vimrc & plugin directory
function copyVimrc(){
  echo $@
  scp -p ~/.vimrc ${USER_NAME}@${HOST_NAME}:~/.vimrc > /dev/null 2>&1
  scp -rp ~/.vim ${USER_NAME}@${HOST_NAME}:~/.vim > /dev/null 2>&1
}

# bin directory
function copyBin(){
  echo $@
  scp -rp ~/bin ${USER_NAME}@${HOST_NAME}:~/bin > /dev/null 2>&1
}

# copy config files (overwrite mode)
if [ "${OPTION}" = "overwrite" ]; then
  copyVimrc "[overwrite] copy to vimrc & plugin directory"
  copyBin "[overwrite] copy to bin directory"

# copy config files (exist check mode)
else
  ssh ${USER_NAME}@${HOST_NAME} "test -f ~/.vimrc"
  if [ $? != 0 ]; then
    copyVimrc "copy to vimrc & plugin direcotory"
  fi
  ssh ${USER_NAME}@${HOST_NAME} "test -d ~/bin"
  if [ $? != 0 ]; then
    copyBin "copy to bin directory"
  fi
fi

# remote login
if [ "$TERM" = "screen" ]; then
  screen -t "${HOST_NAME}" ssh ${USER_NAME}@${HOST_NAME}
else
  ssh ${USER_NAME}@${HOST_NAME}
fi

exit 0

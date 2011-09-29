#!/bin/sh

# config
HOST="172.22.182.169"
USER="nagaoka_katsutoshi"

# args
FILE=$1

# check parameters
if [ x"${FILE}" = "x" ]; then
  echo "Usage: ${0} <target_file>"
  exit 1
fi

# execute
function execute(){
  echo "## cmd = $@"
  $@
}

# remote copy
execute "scp -rp ${FILE} ${USER}@${HOST}:~/"

exit 0


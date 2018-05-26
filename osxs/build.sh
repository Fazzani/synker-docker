#!/bin/bash

set -o errexit
export PATH="$PATH:${HOME}/.dotnet/tools"

function debug_dotnet_core {
    set -eux
    dotnet tool list  -g
    dotnet --info
    dotnet script --version
}

function install {
    curl https://gist.githubusercontent.com/Fazzani/17e0037281a8101d87d6478631378fd0/raw/2c781c191b737ba56eac7a63c91b099e353afa99/push_to_gist.sh > gist.sh &&
    chmod 755 gist.sh &&
    sudo mv gist.sh /usr/local/bin/
}

GIST_TOKEN=$1
PB_TOKEN=$2
FILE=$3

[ -f /usr/local/bin/gist.sh ] || install

gistraw_url=$(gist.sh -t "${GIST_TOKEN}" "${FILE}")
short_url=$(curl -s "http://tinyurl.com/api-create.php?url=${gistraw_url}")

# Sent pushbullet message
dotnet script "${short_url}" -- "$PB_TOKEN" "test" "Message to test"

exit 0
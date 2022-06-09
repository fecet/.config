#!/bin/bash
# save this file to ${HOME}/.config/clash/start-clash.sh

# save pid file
echo $$ > ${HOME}/.config/clash/clash.pid
CLASH_URL="https://subscribe.y9d3.top/link/UpuNZH6guh7sZov6?clash=1"

diff ${HOME}/.config/clash/config.yaml <(curl -s ${CLASH_URL})
if [ "$0" == 0 ]
then
    /usr/bin/clash
else
    TIME=`date '+%Y-%m-%d %H:%M:%S'`
    cp ${HOME}/.config/clash/config.yaml "${HOME}/.config/clash/config.yaml.bak${TIME}"
    curl -L -o ${HOME}/.config/clash/config.yaml ${CLASH_URL}
    /usr/bin/clash
fi

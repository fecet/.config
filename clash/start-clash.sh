#!/bin/bash
# save this file to ${HOME}/.config/clash/start-clash.sh

# save pid file
echo $$ > ${HOME}/.config/clash/clash.pid
CLASH_URL="https://api.nxtlnodes.com/Subscription/Clash?sid=27160&token=TBOkMJW6onV"
# CLASH_URL="https://subscribe.y3d4.top/link/mcT54cJh23vqjfZ3?clash=1"

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

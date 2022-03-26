#!/bin/bash
# save this file to ${HOME}/.config/clash/start-clash.sh

# save pid file
echo $$ > ${HOME}/.config/clash/clash.pid
CLASH_URL="https://pub-api-1.bianyuan.xyz/sub?target=clash&url=https%3a%2f%2fsubscribe.a9b.top%2flink%2fupunzh6guh7szov6%3fclash%3d1&insert=false"

diff ${HOME}/.config/clash/config.yaml <(curl -s ${CLASH_URL})
if [ "$?" == 0 ]
then
    /usr/bin/clash
else
    # TIME=`date '+%Y-%m-%d %H:%M:%S'`
    # cp ${HOME}/.config/clash/config.yaml "${HOME}/.config/clash/config.yaml.bak${TIME}"
    # curl -L -o ${HOME}/.config/clash/config.yaml ${CLASH_URL}
    /usr/bin/clash
fi

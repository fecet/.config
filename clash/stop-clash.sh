#!/bin/bash
# save this file to ${HOME}/.config/clash/stop-clash.sh

# read pid file
PID=`cat ${HOME}/.config/clash/clash.pid`
kill -9 ${PID}
rm ${HOME}/.config/clash/clash.pid

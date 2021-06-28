#!/bin/bash
### BEGIN INIT INFO
# Provides:          otimiza
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
### END INIT INFO

while :; do

_ram_avl=`free | grep Mem | awk '{print $4/$2 * 100.0}' | awk -F'.' '{print $1}'`
if [ $_ram_avl -le 20 ]; then
sync; echo 3 > /proc/sys/vm/drop_caches
fi
sleep 3.5
done &

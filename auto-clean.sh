#!/bin/bash
### BEGIN INIT INFO
# Provides:          auto-clean
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
### END INIT INFO

while :; do
#Calculates the current percentage of free RAM available
_ram_avl=`free | grep Mem | awk '{print $4/$2 * 100.0}' | awk -F'.' '{print $1}'`
#If free percentage is less than or equal to 20% of total RAM trigger the cleanup
if [ $_ram_avl -le 20 ]; then
sync; echo 1 > /proc/sys/vm/drop_caches
fi
sleep 3.5
done &

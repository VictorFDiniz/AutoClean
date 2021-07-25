#!/bin/bash
### BEGIN INIT INFO
# Provides:          auto-clean
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
### END INIT INFO

_ram_trig=15
_cache_cln=1

while :; do
#Calculates the current percentage of free RAM available
  _ram_avl=`free | grep Mem | awk '{print $4/$2 * 100.0}' | awk -F'.' '{print $1}'`
#If free percentage is less than or equal to _ram_trig, trigger the cleanup
if [ $_ram_avl -le $_ram_trig ]; then
  sync; echo $_cache_cln > /proc/sys/vm/drop_caches
fi
  sleep 3.5
done &

#!/bin/bash

mv Install.sh /root/Install.sh > /dev/null 2>&1

#changing swap memory value(Not all providers support)
echo 60 > /proc/sys/vm/swappiness

#Checking if AutoClean is already installed
if [[ -e /etc/init.d/AutoClean.sh ]]; then
rm -rf /etc/init.d/AutoClean.sh
update-rc.d -f AutoClean.sh remove > /dev/null 2>&1
killall AutoClean.sh > /dev/null 2>&1
wget -c -P /etc/init.d https://raw.githubusercontent.com/VictorFDiniz/CacheAutoClean/main/AutoClean.sh > /dev/null 2>&1
else
wget -c -P /etc/init.d https://raw.githubusercontent.com/VictorFDiniz/CacheAutoClean/main/AutoClean.sh > /dev/null 2>&1
fi

cd /etc/init.d
chmod 775 AutoClean.sh

#Run at system startup
update-rc.d AutoClean.sh defaults > /dev/null 2>&1
./AutoClean.sh

cd /root
rm Install.sh
echo "DONE!"

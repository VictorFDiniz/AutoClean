#!/bin/bash
if [[ "$EUID" -ne 0 ]]; then
echo "Sorry, you need to run this as root"
exit 0
fi

apt-get update -y > /dev/null 2>&1
apt-get install figlet -y > /dev/null 2>&1


echo -e "\033[0;36m////////////////////////////////////////////////////////////"
figlet AutoClean
echo -e "\033[0;36m////////////////////////////////////////////////////////////"
echo ""

mv Install.sh /root/Install.sh > /dev/null 2>&1

#changing swap memory value(Not all providers support)
echo 60 > /proc/sys/vm/swappiness

#Checking if AutoClean is already installed
if [[ -e /etc/init.d/auto-clean.sh ]]; then
read -p "$(echo -e "\033[1;36mAutoClean is already installed, do you want to re-install \033[1;31m? \033[1;33m[Y/N]:\033[1;37m ")" -e -i n response
elif [[ $response = @(n|N) ]]; then
exit 0
else
rm -rf /etc/init.d/auto-clean.sh
update-rc.d -f auto-clean.sh remove > /dev/null 2>&1
killall auto-clean.sh > /dev/null 2>&1
wget -c -P /etc/init.d https://raw.githubusercontent.com/VictorFDiniz/CacheAutoClean/main/auto-clean.sh > /dev/null 2>&1
cd /etc/init.d
chmod 775 auto-clean.sh
#Run at system startup
update-rc.d auto-clean.sh defaults > /dev/null 2>&1
./auto-clean.sh
cd /root
rm Install.sh
echo "DONE!"
fi

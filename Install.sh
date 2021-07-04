#!/bin/bash
if [[ "$EUID" -ne 0 ]]; then
echo "Sorry, you need to run this as root"
exit 0
fi

fun_inst() {

echo ""
echo -e "\033[1;36minstalling..."
sleep 1.5
echo ""

wget -c -P /etc/init.d https://raw.githubusercontent.com/VictorFDiniz/CacheAutoClean/main/auto-clean.sh > /dev/null 2>&1

cd /etc/init.d
chmod 775 auto-clean.sh

#Run at system startup
update-rc.d auto-clean.sh defaults > /dev/null 2>&1
./auto-clean.sh
cd /root
rm Install.sh
echo "DONE!"

}

apt-get update -y > /dev/null 2>&1
apt-get install figlet -y > /dev/null 2>&1

clear
echo -e "\033[1;36m////////////////////////////////////////////////////////////"
figlet AutoClean
echo -e "\033[1;36m////////////////////////////////////////////////////////////"
echo ""
echo ""

mv Install.sh /root/Install.sh > /dev/null 2>&1

#changing swap memory value(Not all providers support)
echo 60 > /proc/sys/vm/swappiness

#Checking and installing
if [[ ! -e /etc/init.d/auto-clean.sh ]]; then
fun_inst
elif [[ -e /etc/init.d/auto-clean.sh ]]; then
sleep 1
read -p "$(echo -e "\033[1;36mAlready installed, want to re-install \033[1;31m? \033[1;33m[Y/N]:\033[1;37m ")" -e -i n response
[[ $response = @(n|N) ]] && sleep 0.5 && exit 0
#Re-installing
rm -rf /etc/init.d/auto-clean.sh
update-rc.d -f auto-clean.sh remove > /dev/null 2>&1
killall auto-clean.sh > /dev/null 2>&1
fun_inst
fi

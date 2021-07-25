#!/bin/bash
if [[ "$EUID" -ne 0 ]]; then
  echo "Sorry, you need to run this as root"
exit 0
fi

fun_inst() {

  echo ""
  echo -e "\033[1;36mInstalling..."
  sleep 1
  echo ""
  wget -c -P /etc/init.d https://raw.githubusercontent.com/VictorFDiniz/CacheAutoClean/main/auto-clean.sh > /dev/null 2>&1
  cd /etc/init.d; chmod 775 auto-clean.sh
#Run at system startup
  update-rc.d auto-clean.sh defaults > /dev/null 2>&1
  ./auto-clean.sh; cd /root; rm Install.sh
  echo -e "\033[1;36mInstallation completed!"
  echo ""
  read -p "$(echo -e "\033[1;36mDo you want to change the swappiness \033[1;31m? \033[1;33m[Y/N]:\033[1;37m ")" -e -i y response
  [[ $response = @(n|N) ]] && rm Install.sh && sleep 0.5 && exit 0
while read -p "$(echo -e "\033[1;36mSet a value for Swappiness \033[1;33m[0-100]: ")" _num do
if [[ $_num =~ ^[0-9]+$ ]] && (( $_num >= 0 && $_num <= 100 ))
then
  sed -i "s/.*vm.swappiness.*/vm.swappiness=$_num/" /etc/sysctl.conf
  sysctl -p /etc/sysctl.conf > /dev/null 2>&1
  echo ""
  echo -e "\033[1;31mDONE!"
exit 0
else
  echo ""
  echo -e "\033[1;33mJust numbers from 0 to 100"
fi
done
  echo ""

}

  apt-get update -y
  apt-get install figlet -y

  clear
  echo -e "\033[1;36m////////////////////////////////////////////////////////////"
  figlet AutoClean
  echo -e "\033[1;36m////////////////////////////////////////////////////////////"
  echo ""
  echo ""

  mv Install.sh /root/Install.sh > /dev/null 2>&1

#Checking and installing
if [[ ! -e /etc/init.d/auto-clean.sh ]]; then
  echo""
  read -p "$(echo -e "\033[1;36mDo you want to continue \033[1;31m? \033[1;33m[Y/N]:\033[1;37m ")" -e -i y response
  [[ $response = @(n|N) ]] && rm Install.sh && sleep 0.5 && exit 0
  fun_inst
elif [[ -e /etc/init.d/auto-clean.sh ]]; then
  read -p "$(echo -e "\033[1;36mAlready installed, want to re-install \033[1;31m? \033[1;33m[Y/N]:\033[1;37m ")" -e -i n response
  [[ $response = @(n|N) ]] && rm Install.sh && sleep 0.5 && exit 0
#Re-installing
  rm -rf /etc/init.d/auto-clean.sh
  update-rc.d -f auto-clean.sh remove > /dev/null 2>&1
  killall auto-clean.sh > /dev/null 2>&1
  fun_inst
fi

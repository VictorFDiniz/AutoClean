#!/bin/bash
if [[ "$EUID" -ne 0 ]]; then
  echo "Sorry, you need to run this as root"
exit 1
fi

fun_inst() {

  wget -c -P /etc/init.d https://raw.githubusercontent.com/VictorFDiniz/CacheAutoClean/main/auto-clean.sh > /dev/null 2>&1
  
  echo -e "
\033[1;36m1\033[1;31m) \033[1;33mAutomate PageCache clearing \033[1;31m
\033[1;36m2\033[1;31m) \033[1;33mAutomate dentries and inodes clearing \033[1;31m
\033[1;36m3\033[1;31m) \033[1;33mAutomate PageCache, dentries and inodes clearing\033[0m"
  echo ""
while true; do
  read -p "$(echo -e "\033[1;36mWhat do want to do \033[1;31m? \033[1;33m[1/2/3]:\033[1;37m ")" x
  case $x in
      1 | 01)
      sed -i "s/_cache_cln=.*/_cache_cln=1/" /etc/init.d/auto-clean.sh
      break
      ;;
      2 | 02)
      sed -i "s/_cache_cln=.*/_cache_cln=2/" /etc/init.d/auto-clean.sh
      break
      ;;
      3 | 03)
      sed -i "s/_cache_cln=.*/_cache_cln=3/" /etc/init.d/auto-clean.sh
      break
      ;;
      *)
    echo ""
    echo -e "\033[1;31mInvalid option"
    sleep 0.5
    echo ""
      ;;
  esac
done

echo -e "
\033[1;33mValues for the cache's trigger range from 5 to 90. 
Choose a value of 5 for the trigger means that 
cleaning will occur whenever RAM reaches 95% usage. 
Values above 20 are not recommended, constant cleaning may corrupt something.\033[0m"
echo ""
while read -p "$(echo -e "\033[1;36mSet a value for the cache's trigger \033[1;33m[5-90]: ")" _num ; do
if [[ $_num =~ ^[0-9]+$ ]] && (( $_num >= 5 && $_num <= 90 )); then
  sed -i "s/_ram_trig=.*/_ram_trig=$_num/" /etc/init.d/auto-clean.sh
break
else
  echo ""
  echo -e "\033[1;33mJust numbers from 5 to 90"
fi
done
  echo ""
  echo -e "\033[1;36mInstalling..."
  sleep 1
  echo ""
#Run at system startup
  update-rc.d auto-clean.sh defaults > /dev/null 2>&1
  cd /etc/init.d; chmod 775 auto-clean.sh
  ./auto-clean.sh; cd /root
  echo -e "\033[1;36mInstallation completed!"
  echo ""
  read -p "$(echo -e "\033[1;36mDo you want to change the swappiness \033[1;31m? \033[1;33m[Y/N]:\033[1;37m ")" -e -i y response
[[ $response = @(n|N) ]] && rm Install.sh && sleep 0.5 && exit 0
echo -e "
\033[1;33mValues for the Swappiness range from 0 to 100.
Choose a value of 60 for Swappiness means that 
the system can Swap once the RAM reaches 40% usage.\033[0m"
echo ""
while read -p "$(echo -e "\033[1;36mSet a value for Swappiness \033[1;33m[0-100]: ")" _num ; do
if [[ $_num =~ ^[0-9]+$ ]] && (( $_num >= 0 && $_num <= 100 )); then
sed -i "s/.*vm.swappiness.*/vm.swappiness=$_num/" /etc/sysctl.conf
  sysctl -p /etc/sysctl.conf > /dev/null 2>&1
  echo ""
  echo -e "\033[1;31mDONE!"
exit 0
else
  echo ""
  echo -e "\033[1;33mJust numbers from 0 to 100\0"
fi
done
  echo ""
  rm Install.sh
}

  echo -e "\033[1;33mRepo Upgrading :)\033[0m"
  echo ""
while true; do
for ((i = 0; i < 15; i++))
  echo -ne "\033[1;31m#"
  sleep 0.1s
done
  apt-get update -y > /dev/null 2>&1
  apt-get install figlet -y > /dev/null 2>&1
  break
done

  clear
  echo -e "\033[1;36m////////////////////////////////////////////////////////////"
  figlet AutoClean
  echo -e "\033[1;36m////////////////////////////////////////////////////////////"
  echo ""
  echo ""

  mv Install.sh /root/Install.sh > /dev/null 2>&1

#Checking and installing
if [[ ! -e /etc/init.d/auto-clean.sh ]]; then
  echo ""
  read -p "$(echo -e "\033[1;36mDo you want to continue \033[1;31m? \033[1;33m[Y/N]:\033[1;37m ")" -e -i y response
  [[ $response = @(n|N) ]] && rm Install.sh && sleep 0.5 && exit 0
  fun_inst
else
  read -p "$(echo -e "\033[1;36mAlready installed, want to re-install \033[1;31m? \033[1;33m[Y/N]:\033[1;37m ")" -e -i n response
  [[ $response = @(n|N) ]] && rm Install.sh && sleep 0.5 && exit 0
#Re-installing
  rm -rf /etc/init.d/auto-clean.sh
  update-rc.d -f auto-clean.sh remove > /dev/null 2>&1
  killall auto-clean.sh > /dev/null 2>&1
  fun_inst
fi

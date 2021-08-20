#!/bin/bash

  [[ "$EUID" -ne 0 ]] && echo "\033[1;33mSorry, you need to run this as root\033[0m" && exit 1

fun_bar () {
  
  command[0]="$1"
  command[1]="$2"
  (
  [[ -e $HOME/end ]] && rm $HOME/end
  ${command[0]} -y > /dev/null 2>&1
  ${command[1]} -y > /dev/null 2>&1
  touch $HOME/end
  ) > /dev/null 2>&1 &
while true; do
	for ((i = 0; i < 20; i++)); do
  echo -ne "\033[1;31m#"
  sleep 0.1
done
  [[ -e $HOME/end ]] && rm $HOME/end && break
  echo -e "\033[1;31m#"
  sleep 1
  tput cuu1
  tput dl1
done
}

if [[ -f /etc/redhat-release ]]; then
	release="centos"
elif cat /etc/issue | grep -q -E -i "debian"; then
	release="debian"
elif cat /etc/issue | grep -q -E -i "ubuntu"; then
  	release="ubuntu"
elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
	release="centos"
elif cat /proc/version | grep -q -E -i "debian"; then
	release="debian"
elif cat /proc/version | grep -q -E -i "ubuntu"; then
	release="ubuntu"
elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
	release="centos"
fi

  echo -e "\033[1;33mRepo Upgrading :)\033[0m"
  echo ""
if [[ $release = "centos" ]]; then
  fun_bar 'yum install epel-release' 'yum repolist'
  fun_bar 'yum update' 'yum install figlet'
elif [[ $release = "debian" ]] || [[ $release = "ubuntu" ]]; then
  fun_bar 'apt-get update' 'apt-get install figlet'
else
  echo ""
  echo -e
"\033[1;31mCentOS, Debian or Ubuntu not detected,
maybe the script doesn't work correctly\033[0m."
fi

  clear
  echo -e "\033[1;36m////////////////////////////////////////////////////////////"
  figlet AutoClean
  echo -e "\033[1;36m////////////////////////////////////////////////////////////"
  echo ""
  echo ""
  
  mv Install.sh /$HOME > /dev/null 2>&1


fun_startup() {

#booting and setting to run at system startup
if [[ $release = centos ]]; then
  chkconfig --add auto-clean.sh
  chkconfig --level 3 auto-clean.sh on
  cd /etc/init.d; chmod 775 auto-clean.sh
  ./auto-clean.sh; cd /$HOME
elif [[ $release = debian ]] || [[ $release = ubuntu ]]; then
  update-rc.d auto-clean.sh defaults > /dev/null 2>&1
  cd /etc/init.d; chmod 775 auto-clean.sh
  ./auto-clean.sh; cd /$HOME
fi
}

fun_rm() {

if [[ $release = centos ]]; then
 service auto-clean.sh stop > /dev/null 2>&1
 chkconfig --del auto-clean.sh > /dev/null 2>&1
 rm -rf /etc/init.d/auto-clean.sh
 killall auto-clean.sh > /dev/null 2>&1
elif [[ $release = debian ]] || [[ $release = ubuntu ]]; then
  update-rc.d -f auto-clean.sh remove > /dev/null 2>&1
  rm -rf /etc/init.d/auto-clean.sh
  killall auto-clean.sh > /dev/null 2>&1
fi
}

fun_inst() {

  wget -c -P /etc/init.d https://raw.githubusercontent.com/VictorFDiniz/CacheAutoClean/main/auto-clean.sh > /dev/null 2>&1
  
  echo -e "
\033[1;36m1\033[1;31m) \033[1;33mAutomate PageCache clearing
\033[1;36m2\033[1;31m) \033[1;33mAutomate dentries and inodes clearing
\033[1;36m3\033[1;31m) \033[1;33mAutomate PageCache, dentries and inodes clearing
\033[1;36m4\033[1;31m) Skip\033[0m"
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
      4 | 04)
      _skip=true
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

if [[ $_skip != true ]]; then
  echo -e "
\033[1;33mValues for the cache's trigger range from 5 to 90. 
Choose a value of 5 for the trigger means that 
cleaning will occur whenever RAM reaches 95% usage. 
Values above 30 are not recommended, constant cleaning may corrupt something.\033[0m"
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
  fun_startup
  echo -e "\033[1;36mInstallation completed!"
else
  echo ""
  echo -e "\033[1;31mSkipped"
fi
  
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
  sleep 0.5
  echo -e "\033[1;31mDONE!\033[0m"
exit 0
else
  echo ""
  echo -e "\033[1;33mJust numbers from 0 to 100"
fi
done
  echo ""
  rm -rf Install.sh
}

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
  fun_rm
  fun_inst
fi

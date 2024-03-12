#!/bin/bash

[[ $EUID -ne 0 ]] && echo -e "\033[1;33mSorry, you need to run this as root\033[0m" && exit 1

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

detect_linux_distribution() {
    if [[ -f /etc/redhat-release ]]; then
        _release="centos"
    elif grep -qiE "debian|ubuntu" /etc/issue; then
        _release="debian"
    elif grep -qiE "centos|red hat|redhat" /etc/issue; then
        _release="centos"
    elif grep -qiE "debian|ubuntu" /proc/version; then
        _release="debian"
    elif grep -qiE "centos|red hat|redhat" /proc/version; then
        _release="centos"
    else
        echo -e "\033[1;31mCentOS, Debian or Ubuntu not detected,"
        echo -e "maybe the script doesn't work correctly\033[0m."
        exit 1
    fi
}

repo_upgrade() {
	echo ""
    echo -e "\033[1;33mRepo Upgrading :)\033[0m"
    echo ""
    case $_release in
        "centos")
            fun_bar 'yum install epel-release' 'yum repolist'
            fun_bar 'yum update' 'yum install figlet' 'yum install psmisc'
            ;;
        "debian" | "ubuntu")
            fun_bar 'apt-get update' 'apt-get install figlet' 'apt-get install psmisc'
            ;;
    esac
}

clear
echo -e "\033[1;36m////////////////////////////////////////////////////////////"
figlet AutoClean
echo -e "\033[1;36m////////////////////////////////////////////////////////////"
echo ""

script_startup() {
    case $_release in
        "centos")
            chkconfig --add auto-clean.sh
            chkconfig --level 3 auto-clean.sh on
            chmod 775 /etc/init.d/auto-clean.sh
            /bin/bash /etc/init.d/auto-clean.sh
            ;;
        "debian" | "ubuntu")
            update-rc.d auto-clean.sh defaults > /dev/null 2>&1
            chmod 775 /etc/init.d/auto-clean.sh
            /bin/bash /etc/init.d/auto-clean.sh
            ;;
    esac
}

script_rm() {
    case $_release in
        "centos")
            service auto-clean.sh stop > /dev/null 2>&1
            chkconfig --del auto-clean.sh > /dev/null 2>&1
            ;;
        "debian" | "ubuntu")
            update-rc.d -f auto-clean.sh remove > /dev/null 2>&1
            ;;
    esac
    rm -rf /etc/init.d/auto-clean.sh /bin/*-auto
    pkill auto-clean.sh > /dev/null 2>&1
}

script_down() {
    wget -c -P /etc/init.d https://raw.githubusercontent.com/VictorFDiniz/CacheAutoClean/main/auto-clean.sh > /dev/null 2>&1
    wget -c -P /bin https://raw.githubusercontent.com/VictorFDiniz/CacheAutoClean/main/start-auto > /dev/null 2>&1
    wget -c -P /bin https://raw.githubusercontent.com/VictorFDiniz/CacheAutoClean/main/stop-auto > /dev/null 2>&1
    wget -c -P /bin https://raw.githubusercontent.com/VictorFDiniz/CacheAutoClean/main/rm-auto > /dev/null 2>&1
    chmod 775 /bin/rm-auto; chmod 775 /bin/start-auto; chmod 775 /bin/stop-auto
}

configure_cache_cleanup() {
	echo ""
	echo ""
    echo -e "\033[1;36m1\033[1;31m) \033[1;33mAutomate PageCache clearing"
    echo -e "\033[1;36m2\033[1;31m) \033[1;33mAutomate dentries and inodes clearing"
    echo -e "\033[1;36m3\033[1;31m) \033[1;33mAutomate PageCache, dentries and inodes clearing"
    echo -e "\033[1;36m4\033[1;31m) Skip\033[0m"
    echo ""
    while true; do
        read -p "$(echo -e "\033[1;36mWhat do want to do \033[1;31m? \033[1;33m[1/2/3/4]:\033[1;37m ")" x
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
cleaning will occur whenever RAM reaches 95% usage.\033[0m"
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
        script_startup
        echo -e "\033[1;36mInstallation completed!"
    else
        echo ""
        echo -e "\033[1;31mSkipped"
    fi
    echo ""
}

configure_swappiness() {
    read -p "$(echo -e "\033[1;36mDo you want to change the swappiness \033[1;31m? \033[1;33m[Y/N]:\033[1;37m ")" -e -i y response
    [[ $response = @(n|N) ]] && rm -rf Install.sh && sleep 0.5 && exit 0
    echo -e "
\033[1;33mValues for the Swappiness range from 0 to 100.
Choose a value of 60 for Swappiness means that 
the system can Swap once the RAM reaches 40% usage.\033[0m"
    echo ""
    while read -p "$(echo -e "\033[1;36mSet a value for Swappiness \033[1;33m[0-100]: ")" _num ; do
        if [[ $_num =~ ^[0-9]+$ ]] && (( $_num >= 0 && $_num <= 100 )); then
            if ! grep -q "^vm.swappiness" /etc/sysctl.conf; then
                echo "vm.swappiness=$_num" >> /etc/sysctl.conf
            else
                sed -i "s/.*vm.swappiness.*/vm.swappiness=$_num/" /etc/sysctl.conf
            fi
            sysctl -p /etc/sysctl.conf > /dev/null 2>&1
            echo ""
            sleep 0.5
            echo -e "\033[1;31mDONE!\033[0m"
            rm -rf Install.sh
            exit 0
        else
            echo ""
            echo -e "\033[1;33mJust numbers from 0 to 100"
        fi
    done
    echo ""
}

#Checking and installing
if [[ ! -e /etc/init.d/auto-clean.sh ]]; then
    echo ""
    read -p "$(echo -e "\033[1;36mDo you want to continue \033[1;31m? \033[1;33m[Y/N]:\033[1;37m ")" -e -i y response
    [[ $response = @(n|N) ]] && rm -rf Install.sh && sleep 0.5 && exit 0
    detect_linux_distribution
    repo_upgrade
    script_down
    configure_cache_cleanup
    configure_swappiness
else
    read -p "$(echo -e "\033[1;36mAlready installed, want to re-install \033[1;31m? \033[1;33m[Y/N]:\033[1;37m ")" -e -i n response
    [[ $response = @(n|N) ]] && rm -rf Install.sh && sleep 0.5 && exit 0
#Re-installing
    detect_linux_distribution
    script_rm
    script_down
    configure_cache_cleanup
    configure_swappiness
fi

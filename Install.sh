#!/bin/bash

# Color variables
YELLOW='\033[1;33m'
RED='\033[1;31m'
CYAN='\033[1;36m'
RESET='\033[0m'

# Check if the script is running as root
[[ $EUID -ne 0 ]] && echo -e "${YELLOW}Sorry, you need to run this as root${RESET}" && exit 1

# Function to display a progress bar
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
            echo -ne "${RED}#"
            sleep 0.1
        done
        [[ -e $HOME/end ]] && rm $HOME/end && break
        echo -e "${RED}#"
        sleep 1
        tput cuu1
        tput dl1
    done
}

# Detect Linux distribution
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
        echo -e "${RED}CentOS, Debian, or Ubuntu not detected. The script may not work correctly.${RESET}"
        exit 1
    fi
}

# Upgrade repository and install necessary packages
repo_upgrade() {
    echo ""
    echo -e "${YELLOW}Updating repositories...${RESET}"
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

# Main script starts here

# Clear screen and display script header
clear
echo -e "${CYAN}////////////////////////////////////////////////////////////"
figlet AutoClean
echo -e "////////////////////////////////////////////////////////////${RESET}"
echo ""

# Function to configure startup script
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

# Function to remove startup script
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

# Function to download necessary scripts
scripts_download() {
    wget -c -P /etc/init.d https://raw.githubusercontent.com/VictorFDiniz/CacheAutoClean/main/auto-clean.sh > /dev/null 2>&1
    wget -c -P /bin https://raw.githubusercontent.com/VictorFDiniz/CacheAutoClean/main/start-auto > /dev/null 2>&1
    wget -c -P /bin https://raw.githubusercontent.com/VictorFDiniz/CacheAutoClean/main/stop-auto > /dev/null 2>&1
    wget -c -P /bin https://raw.githubusercontent.com/VictorFDiniz/CacheAutoClean/main/rm-auto > /dev/null 2>&1
    chmod 775 /bin/rm-auto; chmod 775 /bin/start-auto; chmod 775 /bin/stop-auto
}

# Function to configure cache cleanup
configure_cache_cleanup() {
    echo ""
    echo -e "
${CYAN}1${RED}) ${YELLOW}Automate PageCache clearing
${CYAN}2${RED}) ${YELLOW}Automate dentries and inodes clearing
${CYAN}3${RED}) ${YELLOW}Automate PageCache, dentries, and inodes clearing
${CYAN}4${RED}) ${YELLOW}Skip${RESET}"
    echo ""
    while true; do
        read -p "$(echo -e "${CYAN}What do you want to do ${RED}? ${YELLOW}[1/2/3/4]:${RESET} ")" x
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
                echo -e "${RED}Invalid option${RESET}"
                sleep 0.5
                echo ""
                ;;
        esac
    done

    if [[ $_skip != true ]]; then
        echo -e "
${YELLOW}Values for the cache's trigger range from 5 to 90. 
Choose a value of 5 for the trigger means that 
cleaning will occur whenever RAM reaches 95% usage.${RESET}"
        echo ""
        while read -p "$(echo -e "${CYAN}Set a value for the cache's trigger ${YELLOW}[5-90]: ${RESET}")" _num ; do
            if [[ $_num =~ ^[0-9]+$ ]] && (( $_num >= 5 && $_num <= 90 )); then
                sed -i "s/_ram_trig=.*/_ram_trig=$_num/" /etc/init.d/auto-clean.sh
                break
            else
                echo ""
                echo -e "${YELLOW}Just numbers from 5 to 90${RESET}"
            fi
        done
        echo ""
        echo -e "${CYAN}Installing..."
        sleep 1
        echo ""
        script_startup
        echo -e "${CYAN}Installation completed!"
    else
        echo ""
        echo -e "${RED}Skipped${RESET}"
    fi
    echo ""
}

# Function to configure swappiness
configure_swappiness() {
    read -p "$(echo -e "${CYAN}Do you want to change the swappiness ${RED}? ${YELLOW}[Y/N]:${RESET} ")" -e -i y response
    [[ $response = @(n|N) ]] && rm -rf Install.sh && sleep 0.5 && exit 0
    echo -e "
${YELLOW}Values for the Swappiness range from 0 to 100.
Choose a value of 60 for Swappiness means that 
the system can Swap once the RAM reaches 40% usage.${RESET}"
    echo ""
    while read -p "$(echo -e "${CYAN}Set a value for Swappiness ${YELLOW}[0-100]: ${RESET}")" _num ; do
        if [[ $_num =~ ^[0-9]+$ ]] && (( $_num >= 0 && $_num <= 100 )); then
            if ! grep -q "^vm.swappiness" /etc/sysctl.conf; then
                echo "vm.swappiness=$_num" >> /etc/sysctl.conf
            else
                sed -i "s/.*vm.swappiness.*/vm.swappiness=$_num/" /etc/sysctl.conf
            fi
            sysctl -p /etc/sysctl.conf > /dev/null 2>&1
            echo ""
            sleep 0.5
            echo -e "${RED}DONE!${RESET}"
            rm -rf Install.sh
            exit 0
        else
            echo ""
            echo -e "${YELLOW}Just numbers from 0 to 100${RESET}"
        fi
    done
    echo ""
}

# Check if auto-clean script is already installed
if [[ ! -e /etc/init.d/auto-clean.sh ]]; then
    echo ""
    read -p "$(echo -e "${CYAN}Do you want to continue ${RED}? ${YELLOW}[Y/N]:${RESET} ")" -e -i y response
    [[ $response = @(n|N) ]] && rm -rf Install.sh && sleep 0.5 && exit 0
    detect_linux_distribution
    repo_upgrade
    scripts_download
    configure_cache_cleanup
    configure_swappiness
else
    read -p "$(echo -e "${CYAN}Already installed, want to re-install ${RED}? ${YELLOW}[Y/N]:${RESET} ")" -e -i n response
    [[ $response = @(n|N) ]] && rm -rf Install.sh && sleep 0.5 && exit 0
    #Re-installing
    detect_linux_distribution
    script_rm
    scripts_download
    configure_cache_cleanup
    configure_swappiness
fi

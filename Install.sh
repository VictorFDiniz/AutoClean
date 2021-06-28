#!/bin/bash

#Movendo
mv OtimInstall.sh /root/OtimInstall.sh > /dev/null 2>&1

#Alterando valor Swap
echo 60 > /proc/sys/vm/swappiness

#Verificando existencia dos arquivos
if [[ -e /etc/init.d/otimiza.sh && -e /etc/init.d/badvpn.sh ]]; then
rm -rf /etc/init.d/otimiza.sh
rm -rf /etc/init.d/badvpn.sh
update-rc.d -f otimiza.sh remove > /dev/null 2>&1
update-rc.d -f badvpn.sh remove > /dev/null 2>&1
killall otimiza.sh > /dev/null 2>&1
#Dowload de Arquivos
wget -c -P /etc/init.d https://www.dropbox.com/s/kf2stcmap0xbn8m/otimiza.sh > /dev/null 2>&1
wget -c -P /etc/init.d https://www.dropbox.com/s/hlbto1jrcrjnlsf/badvpn.sh > /dev/null 2>&1
else
wget -c -P /etc/init.d https://www.dropbox.com/s/kf2stcmap0xbn8m/otimiza.sh > /dev/null 2>&1
wget -c -P /etc/init.d https://www.dropbox.com/s/hlbto1jrcrjnlsf/badvpn.sh > /dev/null 2>&1
fi

#Permissão de execução
cd /etc/init.d
chmod +x otimiza.sh
chmod +x badvpn.sh

#Execução na inicialização do sistema
update-rc.d otimiza.sh defaults > /dev/null 2>&1
update-rc.d badvpn.sh defaults > /dev/null 2>&1

#Inicializando otimizador
./otimiza.sh

cd /root
rm OtimInstall.sh
echo "FEITO!"

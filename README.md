_Languages:_ <a href="https://github.com/VictorFDiniz/CacheAutoClean/blob/main/README.pt-br.md">Português-br<a/>, <a href="https://github.com/VictorFDiniz/CacheAutoClean/edit/main/README.md">English</a>

![auto](https://user-images.githubusercontent.com/86570043/132133920-1b91914e-0043-4f92-950f-e66faf8482a0.png)

## Install command for CentOS, Debian and Ubuntu
```
wget -c -P $HOME https://raw.githubusercontent.com/VictorFDiniz/CacheAutoClean/main/Install.sh; cd $HOME; chmod +x Install.sh; ./Install.sh
```

## About this script
If you have a server that not has enough RAM, crashes frequently and you don't have the budget for an upgrade. This script can help you :) You can set a limit RAM usage value. If the value is reached, the script automatically clears the cache on RAM in order to avoid a crash. Also it's possible to configure the Swap memory via Swappiness to alleviate the RAM memory if it reaches a certain value.

there are three cleaning options:
  
![auto02](https://user-images.githubusercontent.com/86570043/132132958-05897109-85ff-4191-9cd1-d4bbf168d426.png)
  
Clearing the cache might not be a good idea in production environments. But if you are determined to use the script. The first option(PageCache clearing) is the safest.
  
![auto03](https://user-images.githubusercontent.com/86570043/132133554-a61fd8bc-aac6-4696-a680-daa6dc4c65d5.png)

Or just skip and go straight to the swappiness configuration.

## Commands
```
stop-auto, to stop
start-auto, to start when stopped
rm-auto, to remove the script
```

_Linguagens:_ <a href="https://github.com/VictorFDiniz/CacheAutoClean/edit/main/README.md">English</a>, <a href="https://github.com/VictorFDiniz/CacheAutoClean/blob/main/README.pt-br.md">Português-br<a/>

![auto](https://user-images.githubusercontent.com/86570043/124396536-8eb5db80-dce0-11eb-891b-86b993047dd1.png)

## Comando de instalação para CentOS, Debian and Ubuntu
```
wget -c -P $HOME https://raw.githubusercontent.com/VictorFDiniz/CacheAutoClean/main/Install.sh; cd $HOME; chmod +x Install.sh; ./Install.sh
```

## Sobre o script
Se tem um servidor que não tem RAM suficiente, trava com frequencia e você não tem grana para fazer um upgrade. Esse script pode te ajudar! Você pode definir um valor limite de uso de RAM. Se o valor for atingido, o script limpa o cache alocado na RAM automaticamente afim de evitar que o servidor trave. Também é possivel configurar a memoria Swap via Swappinnes para aliviar a RAM, caso ela atinja certo valor.

## Comandos
```
stop-auto, para parar
start-auto, para iniciar quando parado
rm-auto, para remover o script
```

_Linguagens:_ <a href="https://github.com/VictorFDiniz/CacheAutoClean/edit/main/README.md">English</a>, <a href="https://github.com/VictorFDiniz/CacheAutoClean/blob/main/README.pt-br.md">Português-br<a/>

![auto](https://user-images.githubusercontent.com/86570043/132133920-1b91914e-0043-4f92-950f-e66faf8482a0.png)

## Comando de instalação para CentOS, Debian and Ubuntu
```
wget -c -P $HOME https://raw.githubusercontent.com/VictorFDiniz/CacheAutoClean/main/Install.sh; cd $HOME; chmod +x Install.sh; ./Install.sh
```

## Sobre o script
Se tem um servidor que não tem RAM suficiente, trava com frequencia e você não tem grana para fazer um upgrade. Esse script pode te ajudar! Você pode definir um valor limite de uso de RAM. Se o valor for atingido, o script limpa o cache alocado na RAM automaticamente afim de evitar que o servidor trave. Também é possivel configurar a memoria Swap via Swappinnes para aliviar a RAM, caso ela atinja certo valor.
  
Há três opções de limpeza:

![auto02](https://user-images.githubusercontent.com/86570043/132132958-05897109-85ff-4191-9cd1-d4bbf168d426.png)
  
Fazer a limpeza do cache em ambientes de produção pode não ser uma boia ideia. Mas se mesmo assim decidir utilizar o script no seu ambiente de produção, a primeira opção(PageCache clearing) é a mais segura.
  
![auto03](https://user-images.githubusercontent.com/86570043/132133554-a61fd8bc-aac6-4696-a680-daa6dc4c65d5.png)
  
Ou pule essa opção e vá direto para a configuração do swappiness.

## Comandos
```
stop-auto, para parar
start-auto, para iniciar quando parado
rm-auto, para remover o script
```

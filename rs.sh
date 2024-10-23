#!/bin/bash

# instalar repositorios Celepar e SSH

if [ ! $(/usr/bin/whoami) = 'root' ]; then
   echo "Por favor execute com SuperUsuário root!"
   exit 1
fi

if [ ! -e "/etc/linuxmint/info" ]; then
    echo "Maquina Linux fora do padrao"
    if [ -e "/var/mstech/updates/" ]; then
       echo "c3"
    else
       exit 1
    fi
fi


export deuRedePrdSerah=''
function estahNaRedePRD() {
   ping -c1 -w2 10.209.218.1 >> /dev/null 2>&1
   if [ $? -eq 0 ]; then
      # assumindo super raridade de rede particular ter uso deste ip prd
      export deuRedePrdSerah='sim'
   fi

   ping -c1 -w2 10.209.192.1 >> /dev/null 2>&1
   if [ $? -eq 0 ]; then
      # assumindo super raridade de rede particular ter uso deste ip prd
      export deuRedePrdSerah="sim$deuRedePrdSerah"
   fi

   ping -c1 -w2 10.209.210.1 >> /dev/null 2>&1
   if [ $? -eq 0 ]; then
      # assumindo super raridade de rede particular ter uso deste ip prd
      export deuRedePrdSerah="sim$deuRedePrdSerah"
   fi

   ping -c1 -w2 10.209.160.1 >> /dev/null 2>&1
   if [ $? -eq 0 ]; then
      # assumindo super raridade de rede particular ter uso deste ip prd
      export deuRedePrdSerah="sim$deuRedePrdSerah"
   fi

   tmpdeuRedePrdSerah=$(echo $deuRedePrdSerah | sed 's/simsim//')
   if [ "$deuRedePrdSerah" = "$tmpdeuRedePrdSerah" ]; then
      ping -c1 -w2 10.132.214.1 >> /dev/null 2>&1
      if [ $? -eq 0 ]; then
         if [ $(route -n | egrep "10.132.214.1[ \t]"| wc -l) -gt 0 ]; then
            export deuRedePrdSerah="simsim"
         fi
      fi
      return
   else
      export deuRedePrdSerah="simsim"
   fi
}

if [ -e /etc/apt/sources.list.d/ubuntu-parana.list ] && [ $(egrep ^deb /etc/apt/sources.list.d/ubuntu-parana.list | wc -l) -gt 2 ] && [ $(grep celepar /etc/apt/sources.list.d/ubuntu-parana.list | wc -l) -gt 3 ]; then
    # Jah Configurado rep Celepar
    sed -i -e 's/^deb/###deb/' /etc/apt/sources.list.d/official-package-repositories.list
    sed -i -e 's/^deb/###deb/' /etc/apt/sources.list
    apt-get  update
    if [ -e "/var/mstech/updates/" ] && [ -e "/home/ccs-client/" ] ; then
       echo 'parece um c3'
    else
       if [ ! -e /etc/apt/sources.list.d/vscode_celepar.list ]; then
          apt-get -y install  code-repo
       fi
       if [ -e "/etc/apt/sources.list.d/vscode.list" ]; then
          sed -i -e 's/^deb/###deb/' "/etc/apt/sources.list.d/vscode.list" 
       fi
    fi

else

   estahNaRedePRD
   if [[ "$deuRedePrdSerah" = "simsim" ]]; then
      echo "Rede Estado, trocando repositorios daeh .."
      cd /tmp
      rm repositorios.deb 2>> /dev/null
      wget http://ubuntu.celepar.parana/repositorios.deb
      if [ -e "repositorios.deb" ]; then
         dpkg -i repositorios.deb
         sed -i -e 's/^deb/###deb/' /etc/apt/sources.list.d/official-package-repositories.list
         sed -i -e 's/^deb/###deb/' /etc/apt/sources.list
         apt-get  update
         if [ -e "/var/mstech/updates/" ] && [ -e "/home/ccs-client/" ] ; then
            echo 'parece um c3'
         else
            apt-get -y install  code-repo
            if [ -e "/etc/apt/sources.list.d/vscode.list" ]; then
               sed -i -e 's/^deb/###deb/' "/etc/apt/sources.list.d/vscode.list" 
            fi
         fi
      else
         echo "ERRO AO BAIXAR repositorios"
      fi
   else
      echo "Num tah na rede PRD"
      if [ ! -e "/etc/apt/sources.list.d/google-chrome.list" ]; then
         echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' >> /etc/apt/sources.list.d/google-chrome.list
      fi

   fi
fi

apt-get  update
if [ "$(ps aux | grep sshd | grep sbin | wc -l)" -eq 0 ]; then
   apt-get -y install ssh
fi
echo "fim"

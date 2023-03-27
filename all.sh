cp -f /usr/share/zoneinfo/Europe/Moscow /etc/localtime
echo -en "192.168.1.3 client\n192.168.1.4 backup\n\n" | sudo tee -a /etc/hosts
dnf install -y epel-release
dnf -y config-manager --set-enabled powertools
dnf install -y borgbackup
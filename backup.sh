#!/bin/bash
# 4) На сервере backup создаем пользователя и каталог /var/backup
# (в домашнем задании нужно будет создать диск ~2Gb и примонтировать его)
# и назначаем на него права пользователя borg
parted /dev/sdb --script mklabel gpt
parted /dev/sdb --script mkpart primary 0% 100%
mkfs.ext4 /dev/sdb1
useradd -m borg
mkdir /var/backup
echo "UUID=$(blkid -o value /dev/sdb1 | head -1) /var/backup ext4 defaults 0 0" >> /etc/fstab
mount -a
chown borg:borg -R /var/backup/
sudo rm -rf /var/backup/*

# 5) На сервер backup создаем каталог ~/.ssh/authorized_keys в каталоге /home/borg
sudo -u borg mkdir /home/borg/.ssh
sudo -u borg touch /home/borg/.ssh/authorized_keys
sudo -u borg chmod 700 /home/borg/.ssh
sudo -u borg chmod 600 /home/borg/.ssh/authorized_keys
sudo -u borg cat /vagrant/id_rsa.pub >> /home/borg/.ssh/authorized_keys
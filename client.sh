#!/bin/bash
# 6) На client генерируем ssh-ключ и добавляем его на сервер backup  в файл authorized_keys созданным на прошлом шаге
cp /vagrant/id_rsa /home/vagrant/.ssh
cp /vagrant/id_rsa.pub /home/vagrant/.ssh
chown vagrant:vagrant /home/vagrant/.ssh/id_rsa.pub /home/vagrant/.ssh/id_rsa
chmod 700 /home/vagrant/.ssh/id_rsa.pub /home/vagrant/.ssh/id_rsa

mkdir /root/.ssh
cp /vagrant/id_rsa /root/.ssh
cp /vagrant/id_rsa.pub /root/.ssh
chmod -R 700 /root/.ssh

# 7) Инициализируем репозиторий borg на backup сервере с client сервера
# использован пароль Otus1234
# sudo -u vagrant borg init --encryption=repokey borg@192.168.1.4:/var/backup/

# 8) Запускаем для проверки создания бэкапа
#borg create --stats --list borg@192.168.1.4:/var/backup/::"etc-{now:%Y-%m-%d_%H:%M:%S}" /etc

# 9) Смотрим, что у нас получилось
# borg list borg@192.168.1.4:/var/backup/

# 10) Смотрим список файлов
# borg list borg@192.168.1.4:/var/backup/::etc-2023-03-24_14:22:27

# 11) Достаем файл из бекапа
# borg extract borg@192.168.1.4:/var/backup/::etc-2023-03-24_14:22:27 etc/hostname

# 12) Автоматизируем создание бэкапов с помощью systemd
# Создаем сервис и таймер в каталоге /etc/systemd/system/

# Для запуска таймера+автозапуска:
# systemctl enable borg-backup.timer --now

# отслеживание таймеров
# systemctl list-timers --all



cat <<'EOT' > /etc/systemd/system/borg-backup.service
# /etc/systemd/system/borg-backup.service
[Unit]
Description=Borg Backup

[Service]
Type=oneshot

# Парольная фраза
Environment="BORG_PASSPHRASE=Otus1234"
# Репозиторий
Environment=REPO=borg@192.168.1.4:/var/backup/

# Что бэкапим
Environment=BACKUP_TARGET=/etc

# Создание бэкапа
ExecStart=/bin/borg create \
  --stats ${REPO}::etc-{now:%%Y-%%m-%%d_%%H:%%M:%%S} \
  ${BACKUP_TARGET}

# Проверка бэкапа
ExecStart=/bin/borg check ${REPO}

# Очистка старых бэкапов
ExecStart=/bin/borg prune \
  --keep-daily 90 \
  --keep-monthly 12 \
  --keep-yearly 1 \
  ${REPO}

EOT

cat <<'EOT' > /etc/systemd/system/borg-backup.timer
# /etc/systemd/system/borg-backup.timer
[Unit]
Description=Borg Backup
Requires=borg-backup.service

[Timer]
OnUnitActiveSec=5min

[Install]
WantedBy=timers.target

EOT


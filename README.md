1-4 шаги - all.sh
5-6 шаги - backup.sh
7-15 шаги - client.sh

Логи процесса бэкапа попадают в /var/log/messages на клиенте

пароль для работы с бэкапами
Otus1234


Восстановление поврежденного каталога /etc:

Перед тем как потерять директорию /etc на client экспортирую ключ бэкап-репозитория
borg key export borg@192.168.1.4:/var/backup/ ./borg_key
и либо сохраняю его в отдельном месте либо вытаскиваю его и используюя однопользовательский режим уже потом.

Подключаюсь с другой машины, где все работает, к бэкап-репозиторию:
Подкидываю ключи для sshd взятые с client либо генерирую-настраиваю новые.
borg key import borg@192.168.1.4:/var/backup/ ./borg_key

Смотрю, что есть в репозитории
borg list borg@192.168.1.4:/var/backup/
Беру подходящий мне бэкап
borg extract borg@192.168.1.4:/var/backup/::etc-2023-03-25_23:56:09 etc

Вхожу на машину client в однолпользовательском режиме,
загрузившись с прописанным параметрами загрузки у ядра rw rd.break.
Подкидываю восстановленную директорию /etc с usb-флешки, к примеру.
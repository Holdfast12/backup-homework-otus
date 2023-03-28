cp /vagrant/id_rsa /home/vagrant/.ssh
cp /vagrant/id_rsa.pub /home/vagrant/.ssh
chown vagrant:vagrant /home/vagrant/.ssh/id_rsa.pub /home/vagrant/.ssh/id_rsa
chmod 700 /home/vagrant/.ssh/id_rsa.pub /home/vagrant/.ssh/id_rsa
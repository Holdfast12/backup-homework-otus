# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {
  :client => {
        :box_name => "centos/7",
    :disks => {
        :sata1 => {
            :dfile => './sata1.vdi',
            :size => 2048,
            :port => 1
        }
     }
  },
  :backup => {
        :box_name => "centos/7",
    :disks => {
        :sata1 => {
            :dfile => './sata2.vdi',
            :size => 4096,
            :port => 1
        }
     }
  },
 }
 Vagrant.configure("2") do |config|
    MACHINES.each do |boxname, boxconfig|
        config.vm.define boxname do |box|
            box.vm.box = boxconfig[:box_name]
            box.vm.host_name = boxname.to_s
             box.vm.provider :virtualbox do |vb|
                     vb.customize ["modifyvm", :id, "--memory", "256"]
                     needsController = false
             boxconfig[:disks].each do |dname, dconf|
                 unless File.exist?(dconf[:dfile])
                   vb.customize ['createhd', '--filename', dconf[:dfile], '--variant', 'Fixed', '--size', dconf[:size]]
                                   needsController = true
                             end
             end
                      if needsController == true
                         vb.customize ["storagectl", :id, "--name", "SATA", "--add", "sata"]
                         boxconfig[:disks].each do |dname, dconf|
                             vb.customize ['storageattach', :id, '--storagectl', 'SATA', '--port', dconf[:port], '--device', 0, '--type',
 'hdd', '--medium', dconf[:dfile]]
                         end
                      end
             end
       box.vm.provision "shell", inline: <<-SHELL
            # Подключаем EPEL репозиторий с дополнительными пакетами
            sudo yum install -y epel-release
            # Устанавливаем на client и backup сервере borgbackup
            sudo yum install -y borgbackup
        SHELL
        end
    end
  end
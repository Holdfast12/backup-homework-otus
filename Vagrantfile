# -*- mode: ruby -*-
# vi: set ft=ruby :

# Для работы файла в Windows необходимо добавить путь C:\Program Files\Oracle\VirtualBox\ в переменную Path
require 'open3'
require 'fileutils'

def get_vm_name(id)
  out, err = Open3.capture2e('VBoxManage list vms')
  raise out unless err.exitstatus.zero?

  path = File.dirname(__FILE__).split('/').last
  name = out.split(/\n/)
            .select { |x| x.start_with? "\"#{path}_#{id}" }
            .map { |x| x.tr('"', '') }
            .map { |x| x.split(' ')[0].strip }
            .first
end


def controller_exists(name, controller_name)
  return false if name.nil?

  out, err = Open3.capture2e("VBoxManage showvminfo #{name}")
  raise out unless err.exitstatus.zero?

  out.split(/\n/)
     .select { |x| x.start_with? 'Storage Controller Name' }
     .map { |x| x.split(':')[1].strip }
     .any? { |x| x == controller_name }
end


# add NVME disks
def create_nvme_disks(vbox, name)
  unless controller_exists(name, 'NVME Controller')
    vbox.customize ['storagectl', :id,
                    '--name', 'NVME Controller',
                    '--add', 'pcie']
  end

  dir = "../vdisks"
  FileUtils.mkdir_p dir unless File.directory?(dir)

  # Можно добавить сразу несколько дисков disks = (0..4).map { |x| ["nvmedisk#{x}", '1024'] }
  disks = (0..4).map { |x| ["nvmedisk#{x}", '1024'] }

  disks.each_with_index do |(name, size), i|
    file_to_disk = "#{dir}/#{name}.vdi"
    port = (i ).to_s

    unless File.exist?(file_to_disk)
      vbox.customize ['createmedium',
                      'disk',
                      '--filename',
                      file_to_disk,
                      '--size',
                      size,
                      '--format',
                      'VDI',
                      '--variant',
                      'standard']
    end

    vbox.customize ['storageattach', :id,
                    '--storagectl', 'NVME Controller',
                    '--port', port,
                    '--type', 'hdd',
                    '--medium', file_to_disk,
                    '--device', '0']

  end
end


def create_disks(vbox, name, box)
  if not controller_exists(name, 'SATA Controller') and not box.include?('almalinux')
    vbox.customize ['storagectl', :id,
                    '--name', 'SATA Controller',
                    '--add', 'sata']
  end

  dir = "../vdisks"
  FileUtils.mkdir_p dir unless File.directory?(dir)

  # можно добавить сразу несколько дисков - disks = (1..6).map { |x| ["disk#{x}", '1024'] }
  disks = (1..1).map { |x| ["disk#{x}", '2048'] }

  disks.each_with_index do |(name, size), i|
    file_to_disk = "#{dir}/#{name}.vdi"
    port = (i + 1).to_s

    unless File.exist?(file_to_disk)
      vbox.customize ['createmedium',
                      'disk',
                      '--filename',
                      file_to_disk,
                      '--size',
                      size,
                      '--format',
                      'VDI',
                      '--variant',
                      'standard']
    end

    vbox.customize ['storageattach', :id,
                    '--storagectl', 'SATA Controller',
                    '--port', port,
                    '--type', 'hdd',
                    '--medium', file_to_disk,
                    '--device', '0']

    vbox.customize ['setextradata', :id,
                    "VBoxInternal/Devices/ahci/0/Config/Port#{port}/SerialNumber",
                    name.ljust(20, '0')]
  end
end


Vagrant.configure("2") do |config|

  config.vm.define "client" do |server|
    #config.vm.box = 'centos/8'
    config.vm.box = 'almalinux/8'
    #config.vm.box_version = "2011.0"
    server.vm.host_name = 'client'
    server.vm.network "private_network", ip: '192.168.1.3', netmask: "255.255.255.0", virtualbox__intnet: "otus"

    server.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      name = get_vm_name('client')
    end
    server.vm.provision "shell", privileged: true, path: 'all.sh'
    server.vm.provision "shell", privileged: true, path: 'client.sh'
  end

  config.vm.define "backup" do |server|
    #config.vm.box = 'centos/8'
    config.vm.box = 'almalinux/8'
    #config.vm.box_version = "2011.0"
    server.vm.host_name = 'backup'
    server.vm.network "private_network", ip: '192.168.1.4', netmask: "255.255.255.0", virtualbox__intnet: "otus"
  
    server.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      name = get_vm_name('backup')
      create_disks(vb, name, config.vm.box)
    end
    server.vm.provision "shell", privileged: true, path: 'all.sh'
    server.vm.provision "shell", privileged: true, path: 'backup.sh'
  end
  
  config.vm.define "newclient" do |server|
    #config.vm.box = 'centos/8'
    config.vm.box = 'almalinux/8'
    #config.vm.box_version = "2011.0"
    server.vm.host_name = 'newclient'
    server.vm.network "private_network", ip: '192.168.1.5', netmask: "255.255.255.0", virtualbox__intnet: "otus"

    server.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      name = get_vm_name('newclient')
    end
    server.vm.provision "shell", privileged: true, path: 'all.sh'
    server.vm.provision "shell", privileged: true, path: 'newclient.sh'
  end

end

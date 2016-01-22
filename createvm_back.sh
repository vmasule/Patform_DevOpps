#! /bin/bash -ex

echo "Start"
vmname="CentOS-7"
#vmname="ubuntu14server"

isofile="D:\git-mastek\DevOps_Platform_Ansible\createvmwindows\vbox\iso_files\CentOS\CentOS-7-x86_64-Minimal-1511.iso"
#isofile="ubuntu-14.04.3-server-amd64.iso"
hddfile="D:\git-mastek\DevOps_Platform_Ansible\createvmwindows\vbox\iso_files\vm_files\CentOS\$vmname.vdi"
ostype="Debian_64"
#ostype="Ubuntu_64"
hddsize="20480" 
vrdeport="5041-5049"
adapter1="vboxnet0"
adapter2="vboxnet1"
clear

# Public network vboxnet0 (10.1.0.0/16)
#VBoxManage hostonlyif create
#VBoxManage hostonlyif ipconfig $adapter1 --ip 10.1.0.254 --netmask 255.255.0.0

# Private network vboxnet1 (10.2.0.0/16)
#VBoxManage hostonlyif create
#VBoxManage hostonlyif ipconfig $adapter2 --ip 10.2.0.254 --netmask 255.255.0.0

# Create VM
vboxmanage createvm --name $vmname --ostype $ostype --register

# Modify VM
vboxmanage modifyvm $vmname --memory "2048" --vram="32" --acpi on --ioapic on --cpus 1 --cpuexecutioncap 75 --rtcuseutc on --cpuhotplug on --pae on --hwvirtex on
#VBoxManage modifyvm $vmname --cpus 1 --cpuexecutioncap 80 --memory 2048

vboxmanage modifyvm $vmname --nic1 natnetwork #--bridgeadapter1 eth0 --cableconnected1 on
#VBoxManage modifyvm $vmname --nic1 nat \
#    --nic2 hostonly --hostonlyadapter2 $adapter1 \
#    --nic3 hostonly --hostonlyadapter3 $adapter2
vboxmanage modifyvm $vmname --audio none
vboxmanage modifyvm $vmname --vrde on --vrdeport $vrdeport --vrdeauthtype null

echo "Creating HD"
# VirtualBox DVD
VBoxManage storagectl $vmname --name "IDE Controller" \
    --add ide --controller PIIX4 --hostiocache on --bootable on
VBoxManage storageattach $vmname --storagectl "IDE Controller" \
    --type dvddrive --port 0 --device 0 --medium $isofile

# VirtualBox HDD
VBoxManage createhd --filename $hddfile --size $hddsize
VBoxManage storagectl $vmname --name "SATA Controller" \
    --add sata --controller IntelAHCI --hostiocache on --bootable on
VBoxManage storageattach $vmname --storagectl "SATA Controller" \
    --type hdd --port 0 --device 0 --medium $hddfile

VBoxManage startvm $vmname --type headless	
#vboxmanage createhd --filename "ubuntu14server.vdi" --size 20480
#vboxmanage storagectl $vmname --name "SATA controller" --add sata --controller IntelAHCI --hostiocache on --bootable on
#vboxmanage storageattach $vmname --storagectl "SATA controller" --port 0 --device 0 --type hdd --medium ubuntu14server.vdi

# Create IDE controller and attach DVD
#vboxmanage storagectl $vmname --name "IDE controller" --add ide
#vboxmanage storageattach $vmname --storagectl "IDE controller"  --port 0 --device 0 --type dvddrive --medium ubuntu-14.04.3-server-amd64.iso
echo "Finished"
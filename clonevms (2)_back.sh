#! /bin/bash -ex

echo "Start"

hddfile="/home/osboxes/Desktop/Ansible/VirtualBox-Ubuntu-14.10-amd64/ubuntu-14.10-server-amd64.vdi"
#ostype="Debian_64"
ostype="Ubuntu_64"
hddsize="20480" 

#clear

# Public network vboxnet0 (10.1.0.0/16)
#VBoxManage hostonlyif create
#VBoxManage hostonlyif ipconfig $adapter1 --ip 10.1.0.254 --netmask 255.255.0.0

# Private network vboxnet1 (10.2.0.0/16)
#VBoxManage hostonlyif create
#VBoxManage hostonlyif ipconfig $adapter2 --ip 10.2.0.254 --netmask 255.255.0.0

create_vms(){

	vmname=$1
	storagectl_name=$2
	adapter=$3
	vm_ip=$4
	
	echo "Creating VM $vmname....."
	
	# Public network vboxnet0 (10.1.0.0/16)
	#VBoxManage hostonlyif create
	#VBoxManage hostonlyif ipconfig $adapter --ip $vm_ip --netmask 255.255.0.0

	#Clone hard disk from base image
	vboxmanage clonehd $hddfile $vmname.vdi

	# Create empty VM
	vboxmanage createvm --name $vmname --ostype $ostype --register

	# Modify VM
	vboxmanage modifyvm $vmname --memory "2048" --vram="32" --acpi on --ioapic on --cpus 1 --cpuexecutioncap 75 --rtcuseutc on --cpuhotplug on --pae on --hwvirtex on
	#VBoxManage modifyvm $vmname --cpus 1 --cpuexecutioncap 80 --memory 2048

	vboxmanage modifyvm $vmname --nic1 natnetwork #--bridgeadapter1 "Ralink RT3290 802.11bgn Wi-Fi Adapter #3" #--cableconnected1 on
	#vboxmanage modifyvm $vmname --nic2 bridged #--bridgeadapter1 "Ralink RT3290 802.11bgn Wi-Fi Adapter #3"
	#vboxmanage modifyvm $vmname --nic2 hostonly --hostonlyadapter1 $adapter
	vboxmanage storagectl $vmname --name $storagectl_name --add sata
	VBoxManage storageattach $vmname --storagectl $storagectl_name --port 0 --device 0 --type hdd --medium $vmname.vdi --mtype multiattach

	VBoxManage startvm $vmname #--type headless	

	echo "VM $vmname created successfully!!"
}

create_vms "ubuntu14testserver" "SATA_controller1" #"VirtualBox Host-Only Network #12" "192.168.66.5"
create_vms "ubuntu14devserver" "SATA_controller2" #"VirtualBox Host-Only Network #3" "192.168.67.1"

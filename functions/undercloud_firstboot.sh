undercloud_firstboot ()
{
    # since I use a lot of firstboot scripts and I can't run more then one in
    # a specific order, I split it to this script and the nodes firstboot is
    # configures elsewhere. This script is reserved for undecloud stuff only.
    NODE_NAME="$1"
    cat > undercloud_boot <<EOF
#!/bin/bash
cp \$0 /root/

LOGFILE=/root/undercloud_boot.log
set -e

if [ -r undercloud-backup.tar ]
then
    RESTORE=true
else
    RESTORE=false
fi

echo "If restoring from a backup, use the backed up repos and networks." >> \$LOGFILE
if \$RESTORE
then
    echo "Restoring from undercloud-backup.tar" >> >> \$LOGFILE
    rm -rf /etc/yum.repos.d
    tar -xC / -f undercloud-backup.tar etc/yum.repos.d
    tar -xC / -f undercloud-backup.tar etc/sysconfig/network-scripts/*
else
    # NIC configuration folder                                                                                                                                                                     |
    NETCFG_DIR="/etc/sysconfig/network-scripts"
    echo "Creating a configuration file for each NIC." &>> \$LOGFILE                                                                                                                               |
    NICS=${#NETWORKS[@]}                                                                                                                                                                           |
    for nic in \$(seq 0 \$NICS)                                                                                                                                                                    |
    do                                                                                                                                                                                             |
        echo "DEVICE=eth\$nic                                                                                                                                                                      |
        ONBOOT=yes                                                                                                                                                                                     |
        NM_CONTROLLED=no                                                                                                                                                                               |
        USERCTL=yes                                                                                                                                                                                    |
        PEERDNS=yes                                                                                                                                                                                    |
        TYPE=Ethernet" > \$NETCFG_DIR/ifcfg-eth\$nic
    done

    echo "Starting DHCP client on the NIC connected to the default network." >> \$LOGFILE
    dhclient eth\$NICS &>> \$LOGFILE

    echo "Setting static data from what dhclient discovered for us." >> \$LOGFILE
    echo "DEVICE=eth\$NICS
    BOOTPROTO=static
    IPADDR=\$(ifconfig eth\$NICS | grep "inet " | awk '{print \$2}')
    DNS1=\$(grep nameserver /etc/resolv.conf | head -n 1 | cut -d " " -f 2)
    GATEWAY=\$(grep nameserver /etc/resolv.conf | head -n 1 | cut -d " " -f 2)
    HWADDR=\$(ifconfig eth\$NICS | grep ether | awk '{print \$2}')
    NETMASK=255.255.255.0
    PEERDNS=no
    ONBOOT=yes
    USERCTL=yes" > \$NETCFG_DIR/ifcfg-eth\$NICS

    echo "No need for dhclient anymore." >> \$LOGFILE
    pkill -9 dhclient &>> \$LOGFILE

    echo "Starting DHCP client on the NIC connected to the External network." >> \$LOGFILE
    EXT_NET=$(( ${#NETWORKS[@]} - 1 ))
    dhclient eth\$EXT_NET &>> \$LOGFILE

    echo "Setting static data from what dhclient discovered for us." >> \$LOGFILE
    echo "DEVICE=eth\$EXT_NET
    BOOTPROTO=static
    IPADDR=\$(ifconfig eth\$EXT_NET | grep "inet " | awk '{print \$2}')
    HWADDR=\$(ifconfig eth\$EXT_NET | grep ether | awk '{print \$2}')
    NETMASK=255.255.255.0
    ONBOOT=yes
    USERCTL=yes" > \$NETCFG_DIR/ifcfg-eth\$EXT_NET

    echo "No need for dhclient anymore."
    pkill -9 dhclient &>> \$LOGFILE
fi

echo "Changing the default hostname to something meaningful." >> \$LOGFILE
echo "${NODE_NAME}.redhat.com" > /etc/hostname
hostnamectl set-hostname ${NODE_NAME}.redhat.com &>> \$LOGFILE

echo "Restarting the networking service." >> \$LOGFILE
systemctl restart network &>> \$LOGFILE


echo "Gathering facts and saving to a hello file." >> \$LOGFILE
IP=\$(ifconfig eth\$NICS | grep "inet " | awk '{print \$2}')
MAC=\$(ifconfig eth\$NICS | grep "ether " | awk '{print \$2}')
SHORT_HOST=\$(hostname | cut -d "." -f 1)
HELLO=/root/\${SHORT_HOST}.hello
echo HOST=\${SHORT_HOST} > \$HELLO
echo IP=\$IP >> \$HELLO
echo MAC=\$MAC >> \$HELLO

echo "Sending hello file to the host." >> \$LOGFILE
sshpass -p $HOST_PASS scp -q \$HELLO root@$HOST_IP:$WORK_DIR/
EOF
    chmod +x undercloud_boot
    try virt-customize $CUST_ARGS -a $VIRT_IMG/${NODE_NAME}.raw --firstboot ./undercloud_boot || failure
}

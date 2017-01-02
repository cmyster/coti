undercloud_firstboot ()
{
    # since I use a lot of firstboot scripts and I can't run more then one in
    # a specific order, I split it to this script and the nodes firstboot is
    # configures elsewhere. This script is reserved for undecloud stuff only.
    NODE_NAME="$1"
    cat > undercloud_boot <<EOF
#!/bin/bash
cp \$0 /root/

# NIC configuration folder
NETCFG_DIR="/etc/sysconfig/network-scripts"

# Changing the default hostname to something meaningful.
echo "${NODE_NAME}.redhat.com" > /etc/hostname
hostnamectl set-hostname ${NODE_NAME}.redhat.com

# Creating a condifuration file for each NIC.
NICS=${#NETWORKS[@]}
for nic in \$(seq 0 \$NICS)
do
    echo "DEVICE=eth\$nic
DEVICE=eth\$nic
ONBOOT=yes
NM_CONTROLLED=no
USERCTL=yes
PEERDNS=yes
TYPE=Ethernet" > \$NETCFG_DIR/ifcfg-eth\$nic
done

# Adding DHCP to N-1 network which in this case is the External network.
echo BOOTPROTO=dhcp >> \$NETCFG_DIR/ifcfg-eth$(( NICS - 1))

# Creating a specific configuration for the final network which is connected
# to the default libvirt network with its own DHCP and settings.
echo "DEVICE=eth$NICS
BOOTPROTO=dhcp
BOOTPROTOv6=dhcp
ONBOOT=yes
TYPE=Ethernet
USERCTL=yes
PEERDNS=yes
IPV6INIT=yes
PERSISTENT_DHCLIENT=1" > /etc/sysconfig/network-scripts/ifcfg-eth$NICS

# Starting DHCP client on the NIC connected to the default network.
dhclient eth\$NICS

# If restoring from a backup, use the backed up repos.
if [ -r undercloud-backup.tar ]
then
    rm -rf /etc/yum.repos.d
    tar -xC / -f undercloud-backup.tar etc/yum.repos.d
fi

# Gathering facts and saving to a hello file.
IP=\$(ifconfig eth\$NICS | grep "inet " | awk '{print \$2}')
MAC=\$(ifconfig eth\$NICS | grep "ether " | awk '{print \$2}')
SHORT_HOST=\$(hostname | cut -d "." -f 1)
HELLO=/root/\${SHORT_HOST}.hello
echo HOST=\${SHORT_HOST} > \$HELLO
echo IP=\$IP >> \$HELLO
echo MAC=\$MAC >> \$HELLO

# Sending hello file to the host.
sshpass -p $HOST_PASS scp -q \$HELLO root@$HOST_IP:$WORK_DIR/
EOF
    chmod +x undercloud_boot
    try virt-customize $CUST_ARGS -a $VIRT_IMG/${NODE_NAME}.raw --firstboot ./undercloud_boot || failure
}

undercloud_firstboot ()
{
    # since I use a lot of firstboot scripts and I can't run more then one in
    # a specific order, I split it to this script and the nodes firstboot is
    # configures elsewhere. This script is reserved for undecloud stuff only.
    UNDER_NODE_NAME="$1"
    cat > undercloud_boot <<EOF
#!/bin/bash
echo "copying the script to homedir"
cp \$0 /root/

echo "assigning a new hostname"
echo "${UNDER_NODE_NAME}.redhat.com" > /etc/hostname
hostnamectl set-hostname ${UNDER_NODE_NAME}.redhat.com

NICS=${#NETWORKS[@]}
for nic in \$(seq 0 \$NICS)
do
    echo "setting up "
    echo DEVICE=eth\$nic > /etc/sysconfig/network-scripts/ifcfg-eth\$nic
    echo ONBOOT=yes >> /etc/sysconfig/network-scripts/ifcfg-eth\$nic
    echo NM_CONTROLLED=no >> /etc/sysconfig/network-scripts/ifcfg-eth\$nic
done

echo "the last nic will have a connection to libvirt's DHCP for accessing it"
echo "DEVICE=eth$NICS
BOOTPROTO=dhcp
BOOTPROTOv6=dhcp
ONBOOT=yes
TYPE=Ethernet
USERCTL=yes
PEERDNS=yes
IPV6INIT=yes
PERSISTENT_DHCLIENT=1" > /etc/sysconfig/network-scripts/ifcfg-eth$NICS

echo "starting dhclient on eth\$NICS"
dhclient eth\$NICS

# If restoring from a backup, use the backed up repos
if [ -r undercloud-backup.tar ]
then
    rm -rf /etc/yum.repos.d
    tar -xC / -f undercloud-backup.tar etc/yum.repos.d
fi

echo "gathering facts and sending to a hello file"
IP=\$(ifconfig eth\$NICS | grep "inet " | awk '{print \$2}')
MAC=\$(ifconfig eth\$NICS | grep "ether " | awk '{print \$2}')
SHORT_HOST=\$(hostname | cut -d "." -f 1)
HELLO=/root/\${SHORT_HOST}.hello
echo HOST=\${SHORT_HOST} > \$HELLO
echo IP=\$IP >> \$HELLO
echo MAC=\$MAC >> \$HELLO

sshpass -p $HOST_PASS scp -q \$HELLO root@$HOST_IP:$WORK_DIR/
EOF
    chmod +x undercloud_boot
    try virt-customize -m 4096 --smp 4 -q -a $VIRT_IMG/${UNDER_NODE_NAME}.raw --firstboot ./undercloud_boot || failure
}

undercloud_firstboot ()
{
    # since I use a lot of firstboot scripts and I can't run more then one in
    # a specific order, I split it to this script and the nodes firstboot is
    # configures elsewhere. This script is reserved for undecloud stuff only.
    NODE_NAME="$1"
    cat > undercloud_boot <<EOF
#!/bin/bash
cp \$0 /root/
BACKUP_FILE=\$(find /root/ -type f -name "*backup.tar")
LOGFILE=/root/undercloud_boot.log
NETCFG_DIR="/etc/sysconfig/network-scripts"

set -e

static_ip ()
{
    echo "Creating static ip for nic eth\${1}." >> \$LOGFILE
    echo "Starting dchclient on eth\$1 to discover network settings." >> \$LOGFILE
    dhclient eth\$1 &>> \$LOGFILE

    IP=\$(ifconfig eth\$1 | grep "inet " | awk '{print \$2}')
    NAMESRV=\$(grep nameserver /etc/resolv.conf | head -n 1 | cut -d " " -f 2)
    MAC=\$(ifconfig eth\$1 | grep ether | awk '{print \$2}')

    echo "NIC eth\$1 has this IP: \$IP and this MAC: \$MAC." >> \$LOGFILE

    echo "DEVICE=eth\$1
    BOOTPROTO=static
    IPADDR=\$IP
    DNS1=\$NAMESRV
    GATEWAY=\$NAMESRV
    HWADDR=\$MAC
    NETMASK=255.255.255.0
    PEERDNS=no
    ONBOOT=yes
    USERCTL=yes" > \$NETCFG_DIR/ifcfg-eth\$1

    echo "No more need for dhclient." >> \$LOGFILE
    for dhc_pid in \$(ps -ef | grep dhclient | grep -v grep | awk '{print \$2}')
    do
        kill -9 \$dhc_pid &>> \$LOGFILE
    done
}

if [ ! -z \$BACKUP_FILE ]
then
    echo "Restoring from \$BACKUP_FILE" >> \$LOGFILE
    rm -rf /etc/yum.repos.d
    tar -xC / -f \$BACKUP_FILE etc/yum.repos.d
fi

echo "Creating a configuration file for each NIC." &>> \$LOGFILE
NICS=${#NETWORKS[@]}
for nic in \$(seq 0 \$NICS)
do
    echo "DEVICE=eth\$nic
    ONBOOT=yes
    NM_CONTROLLED=no
    USERCTL=yes
    PEERDNS=yes
    TYPE=Ethernet" > \$NETCFG_DIR/ifcfg-eth\$nic
done

static_ip \$NICS
static_ip \$(( \$NICS - 1 ))

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

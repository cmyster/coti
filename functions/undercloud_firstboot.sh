undercloud_firstboot ()
{
    NODE_NAME="$1"
    RR_CMD=$(cat rr_cmd)
    cat > undercloud_boot <<EOF
#!/bin/bash
BACKUP_FILE=\$(find /root/ -type f -name "*backup.tar")
LOG_FILE=/root/undercloud_boot.log
NETCFG_DIR="/etc/sysconfig/network-scripts"

set -e

if [ ! -z \$BACKUP_FILE ]
then
    echo "Restoring from \$BACKUP_FILE" >> \$LOG_FILE
    rm -rf /etc/yum.repos.d
    tar -xC / -f \$BACKUP_FILE etc/yum.repos.d
else
    rhos-release $RR_CMD || exit 1
fi

echo "Creating a configuration file for each NIC." &>> \$LOG_FILE
for nic in 0 1
do
    echo "DEVICE=eth\$nic
    ONBOOT=yes
    NM_CONTROLLED=no
    USERCTL=yes
    PEERDNS=yes
    TYPE=Ethernet" > \$NETCFG_DIR/ifcfg-eth\$nic
done

echo "Creating static ip for nic eth1." >> \$LOG_FILE
echo "Starting dchclient on eth1 to discover network settings." >> \$LOG_FILE
dhclient eth1 &>> \$LOG_FILE

IP=\$(ifconfig eth1 | grep "inet " | awk '{print \$2}')
NAMESRV=\$(grep nameserver /etc/resolv.conf | head -n 1 | cut -d " " -f 2)
MAC=\$(ifconfig eth1 | grep ether | awk '{print \$2}')

echo "NIC eth1 has this IP: \$IP and this MAC: \$MAC." >> \$LOG_FILE

echo "DEVICE=eth1
BOOTPROTO=static
IPADDR=\$IP
DNS1=\$NAMESRV
GATEWAY=\$NAMESRV
HWADDR=\$MAC
NETMASK=255.255.255.0
PEERDNS=no
ONBOOT=yes
USERCTL=yes" > \$NETCFG_DIR/ifcfg-eth1

echo "No more need for dhclient." >> \$LOG_FILE
for dhc_pid in \$(ps -ef | grep dhclient | grep -v grep | awk '{print \$2}')
do
    echo "Killing \$dhc_pid" &>> \$LOG_FILE
    kill -9 \$dhc_pid &>> \$LOG_FILE
done
# Running it twice because even with -9 it might need a 2nd attempt.
sleep 1
for dhc_pid in \$(ps -ef | grep dhclient | grep -v grep | awk '{print \$2}')
do
    echo "Killing \$dhc_pid" &>> \$LOG_FILE
    kill -9 \$dhc_pid &>> \$LOG_FILE
done

echo "Changing the default hostname to something meaningful." >> \$LOG_FILE
echo "${NODE_NAME}.redhat.com" > /etc/hostname
hostnamectl set-hostname ${NODE_NAME}.redhat.com &>> \$LOG_FILE

echo "Restarting the networking service." >> \$LOG_FILE
systemctl restart network &>> \$LOG_FILE

echo "Gathering facts and saving to a hello file." >> \$LOG_FILE
IP=\$(ifconfig eth1 | grep "inet " | awk '{print \$2}')
MAC=\$(ifconfig eth1 | grep "ether " | awk '{print \$2}')
SHORT_HOST=\$(hostname | cut -d "." -f 1)
HELLO=/root/\${SHORT_HOST}.hello
echo HOST=\${SHORT_HOST} > \$HELLO
echo IP=\$IP >> \$HELLO
echo MAC=\$MAC >> \$HELLO

echo "Sending hello file to the host." >> \$LOG_FILE
sshpass -p $HOST_PASS scp -q \$HELLO root@$HOST_IP:$WORK_DIR/
EOF
    chmod +x undercloud_boot
    try virt-customize "$VIRSH_CUST" -a "$VIRT_IMG/${NODE_NAME}"_0.raw --firstboot ./undercloud_boot || failure
}

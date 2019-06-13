undercloud_firstboot ()
{
    NODE_NAME="$1"
    RR_CMD=$(cat rr_cmd)
    cat > undercloud_boot <<EOF
#!/bin/bash
set -e
BACKUP_FILE=\$(find /root/ -type f -name "*backup.tar")
LOG_FILE=/root/undercloud_boot.log

if [ ! -z \$BACKUP_FILE ]
then
    echo "Restoring from \$BACKUP_FILE" >> \$LOG_FILE
    rm -rf /etc/yum.repos.d
    tar -xC / -f \$BACKUP_FILE etc/yum.repos.d
else
    rhos-release $RR_CMD || exit 1
    ### TODO: Delete this after trunk is stable:
    sed "s|RHOS_TRUNK-15-trunk|RHOS_TRUNK-15|g" -i /etc/yum.repos.d/rhos-release-15-trunk.repo
fi

IF=$(( ${#NETWORKS[@]} - 1 ))
IP=\$(ip a | grep -A1 eth$IF | grep "inet " | awk '{print \$2}' | cut -d "/" -f 1)
NAMESRV=\$(grep nameserver /etc/resolv.conf | head -n 1 | cut -d " " -f 2)
MAC=\$(ip a | grep -A1 eth$IF | grep ether | awk '{print \$2}')

echo "Changing the default hostname to something meaningful." >> \$LOG_FILE
echo "${NODE_NAME}.redhat.com" > /etc/hostname
hostnamectl set-hostname ${NODE_NAME}.redhat.com &>> \$LOG_FILE

echo "Gathering facts and saving to a hello file." >> \$LOG_FILE
SHORT_HOST=\$(hostname | cut -d "." -f 1)
HELLO=/root/\${SHORT_HOST}.hello
echo HOST=\${SHORT_HOST} > \$HELLO
echo IP=\$IP >> \$HELLO
echo MAC=\$MAC >> \$HELLO

echo "Sending hello file to the host." >> \$LOG_FILE
sshpass -p $HOST_PASS scp -q \$HELLO root@$HOST_IP:$WORK_DIR/
EOF
    chmod +x undercloud_boot
    virt-sysprep -q -a "$VIRT_IMG/${NODE_NAME}_0.raw" \
        --upload "$WORK_DIR"/undercloud_boot:/root \
        --selinux-relabel
}

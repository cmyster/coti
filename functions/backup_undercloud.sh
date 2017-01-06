backup_undercloud ()
{
    HOST_NAME=$1
    cat > backup_undercloud <<EOF
### because of https://bugzilla.redhat.com/show_bug.cgi?id=1058526 I need to exit cleanly
rm -rf /root/backup /root/undercloud-backup.tar /root/undercloud-all-databases.sql
mkdir /root/backup
cd /root/backup
mkdir -p etc/my.cnf.d/ 
mysqldump --opt --all-databases > /root/undercloud-all-databases.sql
tar -cf /root/${HOST_NAME}_backup.tar  \
    /etc/yum.repos.d \
    /root/undercloud-all-databases.sql \
    /etc/my.cnf.d/server.cnf \
    /var/lib/glance/images \
    /srv/node \
    /home/stack \
    /etc/keystone/ssl \
    /etc/sysconfig/network-scripts/ifcfg-eth* \
    /opt/stack || exit 0
exit 0
EOF

    run_script_file backup_undercloud root $HOST_NAME /root/
    try scp -q root@${HOST_NAME}:/root/${HOST_NAME}_backup.tar .
}

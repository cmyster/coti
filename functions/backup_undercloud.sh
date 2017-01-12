backup_undercloud ()
{
    HOST=$1
    cat > backup_undercloud <<EOF
### Because of BZ 1058526 I need to exit cleanly.
mkdir /root/backup
cd /root/backup
mkdir -p etc/my.cnf.d/ 
mysqldump --opt --all-databases > /root/undercloud-all-databases.sql
tar -cf /root/${HOST}_backup.tar  \
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

    run_script_file backup_undercloud root $HOST /root/
    try scp -q root@${HOST}:/root/${HOST}_backup.tar .
}

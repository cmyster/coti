backup_undercloud ()
{
    cat > backup_undercloud <<EOF
### because of https://bugzilla.redhat.com/show_bug.cgi?id=1058526 I need to exit cleanly
rm -rf /root/backup /root/undercloud-backup.tar /root/undercloud-all-databases.sql
mkdir /root/backup
cd /root/backup
mkdir -p etc/my.cnf.d/ 
mysqldump --opt --all-databases > /root/undercloud-all-databases.sql
tar -cf /root/undercloud-backup.tar  \
    /etc/yum.repos.d \
    /root/undercloud-all-databases.sql \
    /etc/my.cnf.d/server.cnf \
    /var/lib/glance/images \
    /srv/node \
    /home/stack \
    /etc/keystone/ssl \
    /opt/stack || exit 0
exit 0
EOF

    run_script_file backup_undercloud root undercloud-0 /root/
    try scp -q root@undercloud-0:/root/undercloud-backup.tar .
}

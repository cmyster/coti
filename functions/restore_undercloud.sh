restore_undercloud ()
{
    cat > restore <<EOF
cd /root

echo "Unpacking DB backup."
tar -xC / -f undercloud-backup.tar etc/my.cnf.d/server.cnf
tar -xC / -f undercloud-backup.tar root/undercloud-all-databases.sql
sed -e '/bind-address/ s/^#*/#/' -i /etc/my.cnf.d/server.cnf

echo "Editing mysqld configuration to handle large data."
crudini --set /etc/my.cnf.d/server.cnf mysqld key_buffer 64M
crudini --set /etc/my.cnf.d/server.cnf mysqld max_allowed_packet 64M
crudini --set /etc/my.cnf.d/server.cnf mysqld thread_stack 192K
crudini --set /etc/my.cnf.d/server.cnf mysqld thread_cache_size 2
crudini --set /etc/my.cnf.d/server.cnf mysqld query_cache_limit 1M
crudini --set /etc/my.cnf.d/server.cnf mysqld query_cache_size 64M

echo "Restoring DB."
systemctl start mariadb
cat /root/undercloud-all-databases.sql | mysql

for i in ceilometer glance heat ironic keystone neutron nova tuskar
do
    echo "Dropping user \${i}."
    mysql -e "drop user \${i}"
done
mysql -e 'flush privileges'

echo "Restoring stack's home directory."
tar -xC / -f undercloud-backup.tar home/stack

echo "Restoring glance and swift data."
tar -xC / -f undercloud-backup.tar srv/node var/lib/glance/images
chown -R swift: /srv/node
chown -R glance: /var/lib/glance/images

echo "Restoring keystone SSL data."
tar -xC / -f undercloud-backup.tar etc/keystone/ssl
if [ -d /etc/keystone/ssl ]
then
    semanage fcontext -a -t etc_t "/etc/keystone/ssl(/.*)?"
    restorecon -R /etc/keystone/ssl
fi
EOF
    run_script_file restore root $1 /root/
}

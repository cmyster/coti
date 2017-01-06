undercloud_install ()
{
    HOST=$1
    echo "installing openstack undercloud"
    scp -q $CWD/undercloud.conf stack@$HOST:
    cat > install <<EOF
cd /home/stack/
if [[ "$UNDER_SEL" != "enforcing" ]]
then
    /usr/bin/sudo /usr/bin/sed -i "s/SELINUX=.*/SELINUX=$UNDER_SEL/" /etc/selinux/config
    /usr/bin/sudo /usr/sbin/setenforce 0
fi
wget -q -nv -nd -np -r -A tar ${TAR_PATH}/ || exit 1
tar xf images.tar
sudo rhos-release $RR_CMD || exit 1
openstack undercloud install || exit 1
EOF
    run_script_file install stack $HOST /home/stack/
}

undercloud_install ()
{
    HOST=$1
    echo "Installing openstack undercloud."
    scp -q $CWD/undercloud.conf stack@$HOST:
    cat > install <<EOF
cd /home/stack/
if [[ "$UNDER_SEL" != "enforcing" ]]
then
    /usr/bin/sudo /usr/bin/sed -i "s/SELINUX=.*/SELINUX=$UNDER_SEL/" /etc/selinux/config
    /usr/bin/sudo /usr/sbin/setenforce 0
    sed -i '/hieradata_override/d' /home/stack/undercloud.conf
    echo "hieradata_override = $CWD/templates/hiera_selinux.yaml" >> /home/stack/undercloud.conf
fi
wget -q -nv -nd -np -r -A tar ${TAR_PATH}/ || exit 1
tar xf images.tar
openstack undercloud install || exit 1
if [ ! -r /home/stack/stackrc ]
then
    exit 1
fi
EOF
    run_script_file install stack $HOST /home/stack/
}

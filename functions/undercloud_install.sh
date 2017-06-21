undercloud_install ()
{
    HOST=$1
    echo "Installing openstack undercloud."
    sed -i "s/enable_telemetry=.*/enable_telemetry=$USE_TELEMETRY/g" $CWD/undercloud.conf
    scp -q $CWD/undercloud.conf stack@$HOST:
    scp -q $CWD/templates/hiera_selinux.yaml stack@$HOST:
    TAR_PATH=$(cat tar_path)
    cat > install <<EOF
if [[ "$UNDER_SEL" != "enforcing" ]]
then
    /usr/bin/sudo /usr/bin/sed -i "s/SELINUX=.*/SELINUX=$UNDER_SEL/" /etc/selinux/config
    /usr/bin/sudo /usr/sbin/setenforce 0
    sed -i '/hieradata_override/d' /home/stack/undercloud.conf
    echo "hieradata_override = /home/stack/hiera_selinux.yaml" >> /home/stack/undercloud.conf
fi
wget -q -nv -nd -np -r -A tar ${TAR_PATH}/ || exit 1
tar xf images.tar
sudo yum remove -y *bigswitch*
openstack undercloud install
tail -n 20 .instack/install-undercloud.log | grep "install complete" &> /dev/null

if [ $? -ne 0 ]
then
    echo "Installation did not report complete."
    exit 1
fi

if [ ! -r /home/stack/stackrc ]
then
    echo "No stackrc file was generated."
    exit 1
fi
EOF
    run_script_file install stack $HOST /home/stack
}

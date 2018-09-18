undercloud_install ()
{
    HOST=$1
    echo "Installing openstack undercloud."
    TAR_PATH=$(cat tar_path)
    cat > install <<EOF
cd /home/stack
sudo $PKG_CUST remove *bigswitch*
openstack undercloud install
if tail -n 20 ./install-undercloud.log | grep "successfully installed" &> /dev/null
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
    run_script_file install stack "$HOST" /home/stack
}

install_tempest ()
{
    HOST=$1
    cat > install_tempest <<EOF
cd /home/stack
source overcloudrc
git clone https://github.com/redhat-openstack/tempest.git
sudo easy_install pip
sudo pip install ./tempest
cd ./tempest
tools/config_tempest.py --deployer-input ~/tempest-deployer-input.conf --debug --create identity.uri \$OS_AUTH_URL identity.admin_password \$OS_PASSWORD
EOF

run_script_file install_tempest stack $HOST /home/stack/
}

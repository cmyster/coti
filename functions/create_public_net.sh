create_public_net ()
{
    HOST_NAME=$1
    cat > public_net <<EOF
cd /home/stack
source overcloudrc
openstack network create public --external
openstack subnet create public-subnet --ip-version 4 --gateway 192.168.190.254  --subnet-range 192.168.190.0/24 --no-dhcp --network public
EOF

run_script_file public_net stack $HOST_NAME /home/stack/
}

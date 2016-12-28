overcloud_predeploy ()
{
    HOST_NAME=$1
    cat > predeploy <<EOF
set -e
cd /home/stack/
source stackrc

echo "setting the EC2Meta property"
BR_NAME=\$(grep inspection_interface undercloud.conf | awk '{print \$NF}' | tr -d "\"")
BR_IP=\$(/usr/sbin/ifconfig \$BR_NAME | grep "inet " | awk '{print \$2}')
sed -i "s/FINDEC2/\$BR_IP/g" ./templates/overrides.yaml

echo "copying ssh id to the default gateway"
sshpass -p stack ssh-copy-id $DEFAULT_GATEWAY

echo "testing passwordless ssh"
ssh $DEFAULT_GATEWAY "echo hello"

echo "adding the default DNS to the default subnet"
SUBNET=\$(neutron subnet-list | grep start | cut -d" " -f 2)
neutron subnet-update \$SUBNET --dns-nameserver $DNS

echo "getting puddle images"
tar xf images.tar

echo "uploading images"
openstack overcloud image upload

echo "importing json file"
openstack baremetal import --json instackenv.json

for node in \$(ironic node-list | grep -i control | cut -d " " -f 2)
do
    ironic node-update \$node add properties/capabilities=profile:control,boot_option:local
done

for node in \$(ironic node-list | grep -i compute | cut -d " " -f 2)
do
    ironic node-update \$node add properties/capabilities=profile:compute,boot_option:local
done

for node in \$(ironic node-list | grep -i ceph | cut -d " " -f 2)
do
    ironic node-update \$node add properties/capabilities=profile:ceph-storage,boot_option:local
done

echo "running introspection" 
openstack baremetal configure boot
openstack baremetal introspection bulk start

echo "cleaning up"
rm -rf ironic-python-agent.* overcloud-full.* deploy-ramdisk-ironic.* images.tar
EOF
    run_script_file predeploy stack $HOST_NAME /home/stack/
}

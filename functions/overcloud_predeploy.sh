overcloud_predeploy ()
{
    HOST=$1
    cat > predeploy <<EOF
set -e
cd /home/stack/
source stackrc

# Setting the EC2Meta property.
BR_NAME=\$(grep local_interface undercloud.conf | awk '{print \$NF}' | tr -d "\"")
if [ -z "$BR_NAME" ]
then
    BR_NAME="br-ctlplane"
fi
BR_IP=\$(/usr/sbin/ifconfig \$BR_NAME | grep "inet " | awk '{print \$2}')
sed -i "s/FINDEC2/\$BR_IP/g" ./templates/overrides.yaml

# Copying ssh id to the default gateway.
sshpass -p stack ssh-copy-id $DEFAULT_GATEWAY

# Copying ssh id to EC2Meta.
sshpass -p stack ssh-copy-id \$BR_IP

# Testing passwordless ssh.
ssh $DEFAULT_GATEWAY "echo hello"
ssh \$BR_IP "echo hello"

# Adding the default DNS to the default subnet.
SUBNET=\$(neutron subnet-list | grep start | cut -d" " -f 2)
neutron subnet-update \$SUBNET --dns-nameserver $DNS

# Getting puddle images.
tar xf images.tar

# Uploading images.
openstack overcloud image upload

# Importing json file.
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

# Running introspection.
openstack baremetal configure boot
openstack baremetal introspection bulk start

# Cleaning up.
rm -rf ironic-python-agent.* overcloud-full.* deploy-ramdisk-ironic.* images.tar
EOF
    run_script_file predeploy stack $HOST /home/stack/
}

overcloud_predeploy ()
{
    HOST=$1

    cat > predeploy <<EOF
set -e
cd /home/stack/
source stackrc

# Setting the EC2Meta property.
BR_NAME="br-ctlplane"
BR_IP=\$(/usr/sbin/ifconfig \$BR_NAME | grep "inet " | awk '{print \$2}')
sed -i "s/FINDEC2/\$BR_IP/g" ./templates/overrides.yaml

# Adding the default DNS to the default subnet.
SUBNET=\$(openstack subnet list -f value -c Name -c ID | grep ctlplane | cut -d " " -f 1)
openstack subnet set \$SUBNET --dns-nameserver $DNS

# Importing json file.
openstack overcloud node import instackenv.json

# Updating capabilities to each node.
for node in \$(openstack baremetal node list -f value -c UUID -c Name | grep -i control | cut -d " " -f 1)
do
    openstack baremetal node set \$node --property capabilities='profile:control,boot_option:local'
done

for node in \$(openstack baremetal node list -f value -c UUID -c Name | grep -i compute | cut -d " " -f 1)
do
    openstack baremetal node set \$node --property capabilities='profile:compute,boot_option:local'
done

for node in \$(openstack baremetal node list -f value -c UUID -c Name | grep -i ceph | cut -d " " -f 1)
do
    openstack baremetal node set \$node --property capabilities='profile:ceph-storage,boot_option:local'
done

# Setting the boot drive (in libvirt there is only 'name' and its /dev/vda).

for node in \$(openstack baremetal node list -f value -c UUID)
do
    openstack baremetal node set \$node --property root_device='{"name": "/dev/vda"}'
done

# Running introspection.
openstack baremetal configure boot
openstack baremetal introspection bulk start

EOF
    run_script_file predeploy stack $HOST /home/stack
}

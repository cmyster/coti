overcloud_predeploy ()
{
    HOST=$1
    if [ ! -r ctlplane-addr ]                                                 
    then                                                                      
        echo "Default ctlplane IP was not saved."                             
        raise "${FUNCNAME[0]}"                                                
    fi 

    cat > predeploy <<EOF
set -e
cd /home/stack/
source stackrc

# Setting the EC2Meta property.
BR_IP=$(head -n 1 ctlplane-addr)
sed -i "s/FINDEC2/\$BR_IP/g" ./templates/overrides.yaml

# Adding the default DNS to the default subnet.
SUBNET=\$(openstack subnet list -f value -c Name -c ID | grep ctlplane | cut -d " " -f 1)
openstack subnet set \$SUBNET --dns-nameserver $DNS

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
if ! $VIA_UI
then
    openstack overcloud node introspect --provide --all-manageable
fi

EOF
    run_script_file predeploy stack "$HOST" /home/stack
}

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
BR_IP=$(cut -d " " -f 1 ctlplane-addr)
sed -i "s/FINDEC2/\$BR_IP/g" ./environments/overrides.yaml

# Adding the default DNS to the default subnet.
if [ $OS_VER -gt 11 ]
then
    SUBNET=\$(openstack subnet list -f value -c Name -c ID | grep ctlplane | cut -d " " -f 1)
    openstack subnet set --no-dns-nameservers \$SUBNET
else
    SUBNET=\$(openstack subnet list -f value -c Name -c ID)
    if openstack subnet show \$SUBNET | grep $DNS &> /dev/null
    then
        openstack subnet unset --dns-nameserver $DNS \$SUBNET
    fi
fi

openstack subnet set --dns-nameserver $DNS \$SUBNET

# Updating capabilities to each node.
for node in \$(openstack baremetal node list -f value -c UUID -c Name | grep -i controller | cut -d " " -f 1)
do
    openstack baremetal node set \$node --property capabilities='profile:controller,boot_option:local'
done

for node in \$(openstack baremetal node list -f value -c UUID -c Name | grep -i compute | cut -d " " -f 1)
do
    openstack baremetal node set \$node --property capabilities='profile:compute,boot_option:local'
done

for node in \$(openstack baremetal node list -f value -c UUID -c Name | grep -i ceph | cut -d " " -f 1)
do
    openstack baremetal node set \$node --property capabilities='profile:ceph,boot_option:local'
done

# Setting the boot drive (in libvirt there is only 'name' and its /dev/vda).

for node in \$(openstack baremetal node list -f value -c UUID)
do
    openstack baremetal node set \$node --property root_device='{"name": "/dev/vda"}'
done

# Running introspection.
if ! $VIA_UI
then
    if [ $OS_VER -gt 11 ]
    then
        openstack overcloud node introspect --provide --all-manageable
    else
        openstack baremetal configure boot
        openstack baremetal introspection bulk start
    fi
fi

EOF
    run_script_file predeploy stack "$HOST" /home/stack
}

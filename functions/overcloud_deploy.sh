overcloud_deploy ()
{
    HOST=$1


    # Starting index from 1, as 0 is Undercloud and no deployment parameters
    # are needed.
    echo "parameter_defaults:" > node_scale.yaml
    for (( index=1; index<${#NODES[@]}; index++ ))
    do
        eval NAM=\$${NODES[$index]}_NAM
        eval FLV=\$${NODES[$index]}_FLV
        eval NUM=\$${NODES[$index]}_NU

        echo "    ${NAM^}Count: $NUM" >> node_scale.yaml
        echo "    Overcloud${NAM^}Flavor: $FLV">> node_scale.yaml
    done

    # Fixing name inconsistency. 
    sed -i 's/ControlCount/ControllerCount/g' node_scale.yaml
    scp node_scale.yaml stack@$HOST:/home/stack/templates/

    echo "Running the overcloud deployment."
    cat > deploy <<EOF
cd /home/stack
source stackrc
openstack overcloud deploy \\
    --templates \\
    --libvirt-type kvm \\
    --ntp-server $NTP \\
    -e $THT/environments/ceph-ansible/ceph-ansible.yaml \\
    -e $THT/environments/services/sahara.yaml \\
    -e $THT/environments/cinder-backup.yaml \\
    -e $THT/environments/storage-environment.yaml \\
    -e $THT/environments/docker.yaml \\
    -e $THT/environments/docker-ha.yaml \\
    -e $THT/environments/net-multiple-nics.yaml \\
    -e $THT/environments/network-isolation.yaml \\
    -e ./templates/swap_env.yaml \\
    -e ./templates/node_scale.yaml \\
    -e ./templates/ceph.yaml \\
    -e ./templates/container_images.yaml \\
    -e ./templates/overrides.yaml &> overcloud_deploy.log \&
EOF
    run_script_file deploy stack $HOST /home/stack
}

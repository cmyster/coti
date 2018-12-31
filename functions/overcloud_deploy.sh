overcloud_deploy ()
{
    HOST=$1


    # Starting index from 1, as 0 is Undercloud and no deployment parameters
    # are needed.
    echo "parameter_defaults:" > node_scale.yaml
    for (( index=1; index<${#NODES[@]}; index++ ))
    do
        eval NAM="\$${NODES[$index]}"_NAM
        eval FLV="\$${NODES[$index]}"_FLV
        eval NUM="\$${NODES[$index]}"_NUM

        echo "    ${NAM^}Count: $NUM" >> node_scale.yaml
        echo "    Overcloud${NAM^}Flavor: $FLV">> node_scale.yaml
    done

    # Fixing name inconsistency. 
    sed -i 's/ControlCount/ControllerCount/g' node_scale.yaml
    sed -i 's/CephCount/CephStorageCount/g' node_scale.yaml
    sed -i 's/CephFlavor/CephStorageFlavor/g' node_scale.yaml
    try scp -q node_scale.yaml stack@"$HOST":/home/stack/environments/ || failure

    echo "Running the overcloud deployment."
    cat > deploy <<EOF
cd /home/stack
source stackrc
rm -rf deploy.log deploy_full.log
openstack overcloud deploy \\
    --templates \\
    --libvirt-type kvm \\
    --ntp-server $NTP \\
    -e /home/stack/environments/node_scale.yaml \\
EOF
    # If Ceph is used, add the relevant environments.
    CEPH_COUNT=$(grep -i Ceph node_scale.yaml | grep -i Count | awk '{print $NF}')
    if [ $CEPH_COUNT -gt 0 ]
    then
        echo "    -e /usr/share/openstack-tripleo-heat-templates/environments/ceph-ansible/ceph-ansible.yaml \\" >> deploy
        echo "    -e /home/stack/environments/ceph.yaml \\" >> deploy
        echo "    -e /home/stack/environments/ceph_devices.yaml \\" >> deploy
    fi

    cat $CWD/envs >> deploy

    echo "    --log-file deploy.log &> deploy_full.log" >> deploy
    run_script_file deploy stack "$HOST" /home/stack
}

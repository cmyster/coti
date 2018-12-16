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
    scp node_scale.yaml stack@"$HOST":/home/stack/environments/

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
    cat $CWD/envs >> deploy
    echo "    --log-file deploy.log &> deploy_full.log" >> deploy
    sed 's/CephCount/CephStorageCount/g' -i deploy
    sed 's/CephFlavor/CephStorageFlavor/g' -i deploy
    run_script_file deploy stack "$HOST" /home/stack
    #$SSH_CUST stack@$HOST "/home/stack/deploy"
}

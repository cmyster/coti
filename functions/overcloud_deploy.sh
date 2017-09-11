overcloud_deploy ()
{
    HOST=$1

    if [ $ceph_NUM -ne 0 ]
    then
        echo "Ceph is used, adding environment files for it."
        USE_CEPH="-e $THT/environments/ceph-ansible/ceph-ansible.yaml -e templates/ceph.yaml"
    fi

    # Starting index from 1, as 0 is Undercloud and no deployment parameters
    # are needed.
    for (( index=1; index<${#NODES[@]}; index++ ))
    do
        eval NAM=\$${NODES[$index]}_NAM
        eval FLV=\$${NODES[$index]}_FLV
        eval NUM=\$${NODES[$index]}_NUM

        if [ $NUM -ne 0 ]
        then
            SCALES="$SCALES --${FLV}-scale $NUM "
            FLAVORS="$FLAVORS --${FLV}-flavor $FLV "
        fi
    done

    echo "Running the overcloud deployment."
    cat > deploy <<EOF
cd /home/stack
source stackrc
openstack overcloud deploy \\
    --templates \\
    --libvirt-type kvm \\
    --ntp-server $NTP \\
    $SCALES \\
    $FLAVORS \\
    $USE_CEPH \\
    -e ./templates/swap_env.yaml \\
    -e $THT/environments/docker.yaml \\
    -e $THT/environments/docker-ha.yaml \\
    -e $THT/docker-osp12.yaml \\
    -e $THT/environments/network-isolation.yaml \\
    -e ./templates/overrides.yaml &> overcloud_deploy.log \&
EOF
    run_script_file deploy stack $HOST /home/stack
}

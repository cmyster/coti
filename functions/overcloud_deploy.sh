overcloud_deploy ()
{
    HOST=$1
    USE_CEPH=""
    USE_PANKO=""

    if [ $ceph_NUM -gt 0 ]
    then
        USE_CEPH="-e $THT/environments/storage-environment.yaml -e ./templates/ceph.yaml"
    fi

    if [ $OS_VER -gt 10 ]
    then
        USE_PANKO="-e $THT/environments/services/panko.yaml"
    fi

    # Starting index from 1, as 0 is Undercloud and no deployment parameters
    # are needed.
    for (( index=1; index<${#NODES[@]}; index++ ))
    do
        eval NAM=\$${NODES[$index]}_NAM
        eval FLV=\$${NODES[$index]}_FLV
        eval NUM=\$${NODES[$index]}_NUM

        SCALES="$SCALES --${FLV}-scale $NUM "
        FLAVORS="$FLAVORS --${FLV}-flavor $FLV "
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
    $USE_PANKO \\
    $USE_CEPH \\
    -e ./templates/swap_env.yaml \\
    -e $THT/environments/services/sahara.yaml \\
    -e $THT/environments/cinder-backup.yaml \\
    -e $THT/environments/network-environment.yaml \\
    -e $THT/environments/net-multiple-nics.yaml \\
    -e $THT/environments/network-isolation.yaml \\
    -e ./templates/overrides.yaml > overcloud_deploy.log &
EOF
    run_script_file deploy stack $HOST /home/stack/
}

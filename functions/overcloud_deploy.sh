overcloud_deploy ()
{
    HOST=$1
    USE_CEPH=""
    USE_PANKO=""

    if [ ! -z "$ceph_NUM" ] || [ $ceph_NUM -eq 0 ]
    then
        USE_CEPH="--ceph-storage-scale $ceph_NUM --ceph-storage-flavor ceph-storage -e $THT/environments/storage-environment.yaml -e ./templates/ceph.yaml"
    fi

    if [ $OS_VER -lt 11 ]
    then
        USE_PANKO="-e $THT/environments/services/panko.yaml"
    fi



    echo "Running the overcloud deployment."
    cat > deploy <<EOF
cd /home/stack
source stackrc
openstack overcloud deploy \\
    --templates \\
    --libvirt-type kvm \\
    --control-scale $controller_NUM --control-flavor control \\
    --compute-scale $compute_NUM --compute-flavor compute \\
    --ntp-server $NTP \\
    -e ./templates/swap_env.yaml \\
    -e $THT/environments/services/sahara.yaml \\
    $USE_PANKO \\
    -e $THT/environments/cinder-backup.yaml \\
    -e $THT/environments/network-environment.yaml \\
    -e $THT/environments/net-multiple-nics.yaml \\
    -e $THT/environments/network-isolation.yaml \\
    $USE_CEPH \\
    -e ./templates/overrides.yaml > overcloud_deploy.log &
EOF
    run_script_file deploy stack $HOST /home/stack/
}

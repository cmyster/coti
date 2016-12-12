overcloud_deploy ()
{
    HOST_NAME=$1
    echo "running the overcloud deployment"
    if [ -z "$ceph_NUM" ] || [ $ceph_NUM -eq 0 ]
    then
        USE_CEPH=""
    else
        USE_CEPH="--ceph-storage-scale $ceph_NUM --ceph-storage-flavor ceph-storage -e $THT/environments/storage-environment.yaml -e ./templates/ceph.yaml"
    fi
    cat > deploy <<EOF
cd /home/stack
source stackrc
openstack overcloud deploy \\
    --templates \\
    --libvirt-type kvm \\
    --control-scale $controller_NUM --control-flavor control \\
    --compute-scale $compute_NUM --compute-flavor compute \\
    --neutron-network-type $NET_TYPE \\
    --neutron-tunnel-types $NET_TYPE \\
    --ntp-server $NTP \\
    -e ./templates/swap_env.yaml \\
    -e $THT/environments/services/sahara.yaml \\
    -e $THT/environments/cinder-backup.yaml \\
    -e $THT/environments/network-environment.yaml \\
    -e $THT/environments/net-multiple-nics.yaml \\
    -e $THT/environments/network-isolation.yaml \\
    $USE_CEPH \\
    -e ./templates/overrides.yaml > overcloud_deploy.log &
EOF
    run_script_file deploy stack $HOST_NAME /home/stack/
}

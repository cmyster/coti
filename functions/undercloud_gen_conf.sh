undercloud_gen_conf ()
{
    HOST=$1
    if [ $OS_VER -gt 10 ]
    then
        cidr=$CIDR
    else
        Cidr=$CIDR_OLD
    fi
    echo "Configuring undercloud configuration."
    cat > undercloud.conf <<EOF
[DEFAULT]
enable_telemetry=true
certificate_generation_ca=local
generate_service_certificate=true
local_interface=$LOCAL_INTERFACE
local_ip=$LOCAL_IP
undercloud_public_host=$PUBLIC_HOST
undercloud_admin_host=$ADMIN_HOST
undercloud_ntp_servers=$NTP
container_images_file=/home/stack/containers-prepare-parameter.yaml
docker_insecure_registries=$RHOS_REG,$CEPH_REG
enable_tempest=false
undercloud_enable_selinux=$UNDER_SEL
[ctlplane-subnet]
local_subnet=ctlplane-subnet
cidr=${cidr}.0/24
dhcp_start=${cidr}.${DHCP_IN_START}
dhcp_end=${cidr}.${DHCP_IN_END}
gateway=${cidr}.1
inspection_iprange=${cidr}.${DHCP_INTRO_START},${cidr}.${DHCP_INTRO_END}
masquerade = true
EOF

    chmod 0644 undercloud.conf
    scp -q undercloud.conf stack@"$HOST":
}

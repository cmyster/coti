post_uc_install_wa ()
{
    # Workarounds needed after undercloud install.

    HOST=$1

    echo "Running post-undercloud install workarounds."
    # Workarounds that are needed to be run inside a node go in this script:
    if [ ! -r default_gateway ]
    then
        echo "Default gateway was not saved."
        raise "${FUNCNAME[0]}"
    fi

    DEFAULT_GATEWAY=$(cat default_gateway)
    if [ -z "$DEFAULT_GATEWAY" ]
    then
        echo "Default gateway was not set."
        raise "${FUNCNAME[0]}"
    fi

    cat > post_uc_install_wa <<EOF
### Workrounds go here
# Workaround for https://bugzilla.redhat.com/show_bug.cgi?id=1448482"
sudo sed -i 's/::Compute::/::/' /usr/share/openstack-tripleo-heat-templates/environments/docker.yaml
echo "setenforce permissive" | sudo tee -a /usr/share/openstack-tripleo-heat-templates/docker/firstboot/setup_docker_host.sh

# Adding the correct docker registries and IPs
BR_NAME="br-ctlplane"
BR_IP=\$(/usr/sbin/ifconfig \$BR_NAME | grep "inet " | awk '{print \$2}')
sudo sed -i '/INSECURE_REGISTRY/d' /etc/sysconfig/docker
echo "INSECURE_REGISTRY=--insecure-registry ${DEFAULT_GATEWAY}:8787 --insecure-registry ${BR_IP}:8787 --insecure-registry docker-registry.engineering.redhat.com:8787" | sudo tee -a /etc/sysconfig/docker
sudo systemctl stop docker
sudo systemctl start docker

### End of workarounds
EOF

    run_script_file post_uc_install_wa stack "$HOST" /home/stack

    # Workarounds that work from outside the nodes go here:
}

prepare_docker_images ()
{
    HOST=$1

    if [ ! -r ctlplane-addr ]
    then
        echo "Default ctlplane IP was not saved."
        raise "${FUNCNAME[0]}"
    fi

    PUDDLE=$(cat puddle)

    echo "Generating conatiner yamls and uploading images to local registry."
    cat > prepare_docker_images <<EOF
set -e
cd /home/stack
BR_NAME="br-ctlplane"
RHOS_REG="--insecure-registry $RHOS_REG"
CEPH_REG="--insecure-registry $CEPH_REG"
REGISTRIES="\$RHOS_REG \$CEPH_REG"
MAIN_ADDR=$(cut -d " " -f 1 ctlplane-addr)

for address in $(cat ctlplane-addr)
do
    REGISTRIES="\$REGISTRIES --insecure-registry \${address}:8787"
done

sudo sed -i '/INSECURE_REGISTRY/d' /etc/sysconfig/docker
echo "INSECURE_REGISTRY=\"\$REGISTRIES\"" | sudo tee -a /etc/sysconfig/docker
sudo systemctl stop docker
sudo systemctl start docker
cd /home/stack
source stackrc

openstack overcloud container image prepare \\
    --namespace docker-registry.engineering.redhat.com/rhosp${OS_VER} \\
    --tag-from-label {version}-{release} \\
    --prefix openstack- \\
    --set ceph_namespace=\${MAIN_ADDR}:8787 \\
    --set ceph_image=rhceph \\
    --set ceph_tag=3-6 \\
    --push-destination \${MAIN_ADDR}:8787 \\
    --output-images-file /home/stack/container_images.yaml \\
    --output-env-file /home/stack/environments/containers-default-parameters.yaml

sudo openstack overcloud container image upload --verbose --config-file /home/stack/container_images.yaml

EOF

    cat $CWD/envs >> prepare_docker_images
    echo "" >> prepare_docker_images
    echo "" >> prepare_docker_images
    run_script_file prepare_docker_images stack "$HOST" /home/stack                  
}

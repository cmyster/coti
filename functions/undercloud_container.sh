undercloud_container()
{
    HOST=$1
    TAG=$(grep " tag:" overcloud_container_image_prepare.yaml | awk '{print $NF}')
    CEPH_TAG=$(grep " ceph-tag:" overcloud_container_image_prepare.yaml | awk '{print $NF}')
    NAMESPACE=$(grep " namespace:" overcloud_container_image_prepare.yaml | awk '{print $NF}' | cut -d "/" -f 1)

    echo "Configuring undercloud container parameters."
    cat > set_container <<EOF
cd /home/stack
openstack tripleo container image prepare default \
    --output-env-file /home/stack/containers-prepare-parameter.yaml \
    --local-push-destination

sed "s|latest|$TAG|g" -i /home/stack/containers-prepare-parameter.yaml
sed "s|ceph_tag:.*|ceph_tag: $CEPH_TAG|g" -i /home/stack/containers-prepare-parameter.yaml
sed "s|registry.access.redhat.com|$NAMESPACE|g" -i /home/stack/containers-prepare-parameter.yaml
EOF
    run_script_file set_container stack "$HOST" /home/stack
}

undercloud_container()
{
    HOST=$1
    echo "Configuring undercloud container parameters."
    cat > set_container <<EOF
cd /home/stack
openstack tripleo container image prepare default \
    --output-env-file /home/stack/containers-prepare-parameter.yaml \
    --local-push-destination
EOF

    run_script_file set_container stack "$HOST" /home/stack
}

pre_oc_deploy_wa ()
{
    # Workarounds needed prior overcloud deploy.

    HOST=$1

    # Workarounds that are needed to be run inside a node go in this script:
    echo "Running pre-overcloud deploy workarounds."
    cat > pre_oc_deploy_wa <<EOF
### Workrounds go here
cd /home/stack
wget http://download-node-02.eng.bos.redhat.com/rcm-guest/puddles/OpenStack/12.0-RHEL-7/latest_containers/container_images.yaml
sudo mv container_images.yaml $THT
### End of workarounds
EOF

    run_script_file pre_oc_deploy_wa stack $HOST /home/stack

    # Workarounds that work from outside the nodes go here:
}

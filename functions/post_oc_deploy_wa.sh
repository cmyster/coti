post_oc_deploy_wa ()
{
    # Workarounds needed after undercloud deploy.

    HOST=$1

    # Workarounds that are needed to be run inside a node go in this script:
    echo "Running post-overcloud deploy workarounds."
    cat > post_oc_deploy_wa <<EOF
### Workrounds go here
### End of workarounds
EOF

    run_script_file post_oc_deploy_wa stack "$HOST" /home/stack

    # Workarounds that work from outside the nodes go here:
}

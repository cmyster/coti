post_uc_install_wa ()
{
    # Workarounds needed after undercloud install.

    HOST=$1

    echo "Running post-undercloud install workarounds."

    # Workarounds that are needed to be run inside a node go in this script:
    cat > post_uc_install_wa <<EOF
### Workrounds go here
sudo shutdown -hP -t 0 now # bz : 1440975
### End of workarounds
EOF

    run_script_file post_uc_install_wa stack $HOST /home/stack

    # Workarounds that work from outside the nodes go here:
    try vm_power $HOST stop || failure
    try vm_power $HOST start || failure
}

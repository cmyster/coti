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
exit 0
### End of workarounds
EOF

    run_script_file post_uc_install_wa stack "$HOST" /home/stack

    # Workarounds that work from outside the nodes go here:
}

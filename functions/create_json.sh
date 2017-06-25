create_json ()
{
    HOST=$1
    if [ ! -r default_gateway ]
    then
        echo "Default gateway was not saved."
        raise ${FUNCNAME[0]}
    fi

    DEFAULT_GATEWAY=$(cat default_gateway)
    if [ -z "$DEFAULT_GATEWAY" ]
    then
        echo "Default gateway was not set."
        raise ${FUNCNAME[0]}
    fi

    cat > temp.json <<EOF
{
  "ssh-user": "stack",
  "ssh-key": "PLACE",
  "power_manager": "nova.virt.baremetal.virtual_power_driver.VirtualPowerManager",
  "host-ip": "$DEFAULT_GATEWAY",
  "arch": "x86_64",
  "nodes": [
EOF
    invs=( $(ls -1 *.inv | grep -v ${NODES[0]}) )
    if [ ${#invs[@]} -gt 0 ]
    then
        for inv in ${invs[@]}
        do
            source $inv
            eval CTRL_NET=\$${NETWORKS[0]}
            echo $name | grep -i ceph &> /dev/null
            if [ $? -eq 0 ]
            then
                dsk=$(( $disk / 2 ))
            else
                dsk=$disk
            fi
            echo "adding $name to instackenv"
            cat >> temp.json <<EOF
    {
      "name": "$name",
EOF
            case "$name" in
                controller*)
                    cat >> temp.json <<EOF
      "capabilities":"profile:control,boot_option:local",
EOF
                ;;
                compute*)
                    cat >> temp.json <<EOF
      "capabilities":"profile:compute,boot_option:local",
EOF
                ;;
                ceph*)
                    cat >> temp.json <<EOF
      "capabilities":"profile:ceph-storage,boot_option:local",
EOF
                ;;
            esac

            cat >> temp.json <<EOF
      "pm_addr": "$DEFAULT_GATEWAY",
      "pm_user": "admin",
      "pm_password": "password",
      "pm_type": "pxe_ipmitool",
      "pm_port": "$pm_port",
      "mac": [
        "$CTRL_NET"
      ],
      "cpu": "$cpu",
      "memory": "$memory",
      "disk": "$dsk",
      "arch": "x86_64"
    },
EOF
        START=$(( START + 1 ))
        done
        sed -i '$ d' temp.json
        echo "    }" >> temp.json
    fi

    cat >> temp.json <<EOF
  ]
}
EOF
    try scp -q temp.json stack@${HOST}: || failure

    cat > add_key <<EOF
cat /home/stack/.ssh/id_rsa | tr "\n" "%" | sed 's/%/\\\n/g' > /home/stack/sshkey
gawk 'BEGIN { while (getline < "/home/stack/sshkey") text=text \$0 "" }
            { gsub("PLACE", text); print }' temp.json > instackenv.json
EOF
    run_script_file add_key stack ${HOST} /home/stack
}

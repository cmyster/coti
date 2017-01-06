create_json ()
{
    HOST=$1
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
      "pm_password": "PLACE",
      "pm_type": "pxe_ssh",
      "mac": [
        "$CTRL_NET"
      ],
      "cpu": "$cpu",
      "memory": "$memory",
      "disk": "$dsk",
      "arch": "x86_64",
      "pm_user": "stack"
    },
EOF
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

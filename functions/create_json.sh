create_json ()
{
    HOST=$1
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

    cat > temp.json <<EOF
{
  "ssh-user": "stack",
  "ssh-key": "PLACE",
  "power_manager": "nova.virt.baremetal.virtual_power_driver.VirtualPowerManager",
  "host-ip": "$DEFAULT_GATEWAY",
  "arch": "x86_64",
  "nodes": [
EOF
    invs=( $(ls -1 ./*.inv | grep -v "${NODES[0]}") )
    if [ ${#invs[@]} -gt 0 ]
    then
        for inv in "${invs[@]}"
        do
            source "$inv"
            eval CTRL_NET="\$${NETWORKS[0]}"
            dsk=$disk
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

            disks='"disks": ['
            for l in $(seq 0 $dsk)
            do
                disks=${disks}'"vd'
                disks=${disks}${LETTERS[$l]}
                disks=${disks}'",'
            done
            disks=${disks::-1}
            disks=${disks}'],'

            cat >> temp.json <<EOF
      "disk": "$dsk",
      $disks
EOF
            
            cat >> temp.json <<EOF
      "pm_addr": "$DEFAULT_GATEWAY",
      "pm_user": "admin",
      "pm_password": "password",
      "pm_type": "pxe_ipmitool",
      "pm_user": "stack",
      "pm_type": "pxe_ssh",
      "pm_password": "PLACE",
      "mac": [
        "$CTRL_NET"
      ],
      "cpu": "$cpu",
      "memory": "$memory",
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
    try scp -q temp.json stack@"${HOST}": || failure

    cat > add_key <<EOF
cat /home/stack/.ssh/id_rsa | tr "\n" "%" | sed 's/%/\\\n/g' > /home/stack/sshkey
gawk 'BEGIN { while (getline < "/home/stack/sshkey") text=text \$0 "" }
            { gsub("PLACE", text); print }' temp.json > instackenv.json
EOF
    run_script_file add_key stack "${HOST}" /home/stack

    if ! $VIA_UI
    then
        cat > load_json <<EOF
cd /home/stack
source stackrc
openstack overcloud node import --instance-boot-option=local instackenv.json
EOF
    run_script_file load_json stack "${HOST}" /home/stack
    fi
}

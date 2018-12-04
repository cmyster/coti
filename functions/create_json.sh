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
            echo "    {" >> temp.json
            cat >> temp.json <<EOF
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
      "disk": "$dsk",
EOF
            
            cat >> temp.json <<EOF
      "pm_addr": "$DEFAULT_GATEWAY",
      "pm_port": "$pm_port",
      "pm_user": "admin",
      "pm_password": "password",
      "pm_type": "ipmi",
      "mac": ["$CTRL_NET"],
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

    if ! $VIA_UI
    then
        cat > load_json <<EOF
cd /home/stack
source stackrc
mv temp.json instackenv.json
openstack overcloud node import --instance-boot-option=local instackenv.json
EOF
    run_script_file load_json stack "${HOST}" /home/stack
    fi
}

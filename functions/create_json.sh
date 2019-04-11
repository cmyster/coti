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

    rm -rf nodes.json head.json
    if [ $OS_VER -gt 11 ]
    then
        cat > head.json <<EOF
{
  "ssh-user": "stack",
  "ssh-key": "FINDKEY",
  "power_manager": "nova.virt.baremetal.virtual_power_driver.VirtualPowerManager",
  "host-ip": "$DEFAULT_GATEWAY",
  "arch": "x86_64",
  "nodes": [
EOF
    else
        cat > head.json <<EOF
{
    "nodes": [
EOF
    fi
    
    invs=( $(ls -1 ./*.inv | grep -v "${NODES[0]}") )
    if [ ${#invs[@]} -gt 0 ]
    then
        for inv in "${invs[@]}"
        do
            source "$inv"
            eval CTRL_NET="\$${NETWORKS[0]}"
            dsk=$disk

            if [ $OS_VER -gt 11 ]
            then
                IPMI="ipmi"
                USER="admin"
                PASSWORD="password"
            else
                IPMI="pxe_ssh"
                USER="stack"
                PASSWORD="FINDKEY"
            fi

            echo "adding $name to instackenv"
            echo "    {" >> nodes.json
            case "$name" in
                controller*)
                    cat >> nodes.json <<EOF
      "capabilities":"profile:controller",
EOF
                ;;
                compute*)
                    cat >> nodes.json <<EOF
      "capabilities":"profile:compute",
EOF
                ;;
                ceph*)
                    cat >> nodes.json <<EOF
      "capabilities":"profile:ceph",
EOF
                ;;
            esac

            cat >> nodes.json <<EOF
      "name": "$name",
      "disk": "$dsk",
      "pm_addr": "$DEFAULT_GATEWAY",
      "pm_port": "$pm_port",
      "pm_user": "$USER",
      "pm_password": "$PASSWORD",
      "pm_type": "$IPMI",
      "mac": ["$CTRL_NET"],
      "cpu": "$cpu",
      "memory": "$memory",
      "arch": "x86_64"
    },
EOF
        done
        sed -i '$ d' nodes.json
        echo "    }" >> nodes.json
    fi

    cat head.json > temp.json
    cat nodes.json >> temp.json
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

# Cleaning JIC
for i in \$(ironic node-list | grep enroll | cut -d " " -f 2)
do
    ironic node-delete \$i
done

if [ $OS_VER -lt 11 ]
then
    KEY=\$(<.ssh/id_rsa)
    KEY="\${KEY//\$'\\n'/\\\\\\\\n}"
    sed -e "s|FINDKEY|\$KEY|g" -i temp.json
fi

cp temp.json instackenv.json

if [ $OS_VER -gt 11 ]
then
    openstack overcloud node import instackenv.json
else
    sshpass -p "stack" ssh-copy-id stack@$DEFAULT_GATEWAY
    openstack baremetal import --json instackenv.json

    # Even after the commands exit successfully, ironic keeps talking to the
    # host libvirt and try stuff. I have to wait here otherwise next steps
    # will not succeed.
    sleep 200
fi


EOF
    run_script_file load_json stack "${HOST}" /home/stack
    fi
}

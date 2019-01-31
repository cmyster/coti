post_oc_deploy_ext_net()
{
    HOST=$1
    nets=${#NETWORKS[@]}
    ext_net=${NETWORKS[$(( nets - 1 ))]}
    ext_bridge=$(
    ssh -qtt undercloud-0 "grep -A50 resources $THT/net-config-static-bridge-with-external-dhcp.j2.yaml" \
        | grep -A1 "type: interface" \
        | grep -v interface \
        | awk '{print $2}' \
        | cut -d ":" -f 1 \
        | grep -v ^$
    )
    nets=${#NETWORKS[@]}
    ext_net=${NETWORKS[$(( nets - 1 ))]} 
    IP3=$(virsh net-dumpxml $ext_net | grep "ip address" | cut -d "'" -f 2 | cut -d "." -f 1-3)

    invs=$(ls -1 *.inv | grep -v "${NODES[0]}")
    for inv in $invs
    do
        . $inv
        eval int_ip="$int_ip"
        cat > get_ext_ip <<EOF
#!/bin/bash
cd /home/stack
. stackrc
$SSH_CUST heat-admin@$int_ip "/usr/sbin/ifconfig | grep $IP3" | awk '{print \$2}' > ext_ip
EOF
        run_script_file get_ext_ip stack "$HOST" /home/stack
        echo ext_ip=$($SSH_CUST $HOST "/usr/bin/cat /home/stack/ext_ip" | sed 's/\r$//g') >> $inv
        $SSH_CUST $HOST "/usr/bin/rm /home/stack/ext_ip"
    done
}

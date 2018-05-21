add_templates ()
{
    RR_CMD=$(cat rr_cmd)
    HOST=$1
    try cp -af "$CWD"/templates "$WORK_DIR"/ || failure
    try cp -af "$CWD"/environments "$WORK_DIR"/ || failure

    # Add the wanted size of SWAP area per node.
    for (( index=1; index<${#NODES[@]}; index++ ))
    do
        eval SWP="\$${NODES[$index]}"_SWP
        sed -i "s/FINDSWP/$SWP/g" ./templates/"${NODES[$index]}"_swap.yaml
    done

    # The external network is usually the last one.
    nets=${#NETWORKS[@]}
    ext_net=${NETWORKS[$(( nets - 1  ))]}
    ext_gw=$(virsh net-dumpxml "$ext_net" | grep "ip address" | tr "'" " " | awk '{print $3}')
    ext_base=$(echo "$ext_gw" | cut -d "." -f 1-3)
    namesrv="$(grep nameserver /etc/resolv.conf | head -n 1)"
    sed -i "s|FINDEXT|$ext_gw|g" ./environments/overrides.yaml
    sed -i "s|FINDCIDR|${ext_base}.0/24|g" ./environments/overrides.yaml
    sed -i "s|FINDSTRT|${ext_base}.${DHCP_IN_START}|g" ./environments/overrides.yaml
    sed -i "s|FINDEND|${ext_base}.${DHCP_IN_END}|g" ./environments/overrides.yaml
    sed -i "s|FINDVER|$RR_CMD|g" ./templates/node_tweaks.yaml
    sed -i "s|FINDNSRV|${namesrv}|g" ./environments/node_tweaks.yaml
    sed -i "s|FINDDNS|${DNS}|g" ./environments/overrides.yaml

    tar cf environments.tar environments
    tar cf templates.tar templates

    try scp -q environments.tar stack@"$HOST": || failure
    try scp -q templates.tar stack@"$HOST": || failure

    try "$SSH_CUST" stack@"${NODES[0]}"-0 "tar xf environments.tar" || failure
    try "$SSH_CUST" stack@"${NODES[0]}"-0 "tar xf templates.tar" || failure
}

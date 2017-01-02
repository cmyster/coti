add_templates ()
{
    try cp -af $CWD/templates $WORK_DIR/ || failure

    # Add the wanted size of SWAP area per node.
    for (( index=1; index<${#NODES[@]}; index++ ))
    do
        eval SWP=\$${NODES[$index]}_SWP
        sed -i "s/FINDSWP/$SWP/g" templates/${NODES[$index]}_swap.yaml
    done

    # The external network is usually the last one
    nets=${#NETWORKS[@]}
    ext_net=${NETWORKS[$(( nets - 1  ))]}
    ext_gw=$(virsh net-dumpxml $ext_net | grep "ip address" | tr "'" " " | awk '{print $3}')
    ext_base=$(echo $ext_gw | cut -d "." -f 1-3)
    namesrv="$(grep nameserver /etc/resolv.conf | head -n 1)"
    sed -i "s|FINDEXT|$ext_gw|g" ./templates/overrides.yaml
    sed -i "s|FINDCIDR|${ext_base}.0/24|g" ./templates/overrides.yaml
    sed -i "s|FINDSTRT|${ext_base}.${DHCP_IN_START}|g" ./templates/overrides.yaml
    sed -i "s|FINDEND|${ext_base}.${DHCP_IN_END}|g" ./templates/overrides.yaml
    sed -i "s|FINDVER|${RR_CMD}|g" ./templates/node_tweaks.yaml
    sed -i "s|FINDNSRV|${namesrv}|g" ./templates/node_tweaks.yaml
    sed -i "s|FINDDNS|${DNS}|g" ./templates/overrides.yaml
    tar cf templates.tar templates

    try scp -q templates.tar stack@${NODES[0]}-0: || failure
    try ssh stack@${NODES[0]}-0 "tar xf templates.tar" || failure
}

post_oc_deploy_repos ()
{
    HOST=$1
    echo "Adding repos and installing some tools on overcloud nodes."
    names=""  
    invs=$(ls -1 *.inv | grep -v "${NODES[0]}")
    for inv in $invs
    do
        . $inv
        ips+=" $int_ip"
    done
    # While here, piggy back and also change the root password.
    cat > post_oc_deploy_repos <<EOF
set -e
cd /etc
sudo tar cf yum.repos.d.tar yum.repos.d
sudo chown stack:stack /etc/yum.repos.d.tar
sudo mv /etc/yum.repos.d.tar /home/stack
cd /home/stack
. stackrc
for ip in $ips
do
    scp yum.repos.d.tar heat-admin@\${ip}:
    ssh heat-admin@\${ip} "sudo tar xf /home/heat-admin/yum.repos.d.tar -C /etc"
    ssh heat-admin@\${ip} "sudo yum install -y vim mlocate mc"
    ssh heat-admin@\${ip} "sudo updatedb"
    ssh heat-admin@\${ip} "echo $ROOT_PASS | sudo passwd --stdin root"
done
EOF
    run_script_file post_oc_deploy_repos stack "$HOST" /home/stack
}

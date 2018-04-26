post_uc_install_tweaks ()
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

    # Need to know what is the hard coded IP looks like...
    ssh undercloud-0 ls -l &> /dev/null <<EOF


EOF
    CODED_IP=$(ssh undercloud-0 "grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])' /var/www/openstack-tripleo-ui/dist/tripleo_ui_config.js | uniq | head -n 1")

    cat > post_uc_install_tweaks <<EOF
set -e
cd /home/stack/
source stackrc

# Install ceph-ansible.
sudo yum install -y ceph-ansible

# Saving the IPs set for br-ctlplane and docker0.
sudo /usr/sbin/ip a | grep -A10 "br-ctlplane:" | grep "inet " | awk '{print \$2}' | cut -d "/" -f 1 | sort > ctlplane-addr
sudo /usr/sbin/ip a | grep -A4 "docker0:" | grep "inet " | awk '{print \$2}' | cut -d "/" -f 1 | sort > docker0-addr

BR_IP=\$(head -n 1 ctlplane-addr)
DK_IP=\$(head -n 1 docker0-addr)

if [ -z $DEFAULT_GATEWAY ]; then exit 1; fi

# Copying SSH ids.
for ip in $DEFAULT_GATEWAY \$(cat ctlplane-addr) \$(cat docker0-addr)
do
    sshpass -p $HOST_PASS ssh-copy-id root@\$ip &> /dev/null
done

# Testing passwordless SSH.
for ip in $DEFAULT_GATEWAY \$(cat ctlplane-addr) \$(cat docker0-addr) 
do
    $SSH_CUST root@\$ip "echo hello"
done

# Instead of any internal IP, https will listen with the host's FQDN.
sed -E "s/$CODED_IP/$(hostnamectl --static)/" -i /var/www/openstack-tripleo-ui/dist/tripleo_ui_config.js
systemctl stop httpd
systemctl start httpd
EOF

run_script_file post_uc_install_tweaks root "$HOST" /home/stack

# Opening all connections.
systemctl disable firewalld
systemctl stop firewalld
iptables -F
iptables -P INPUT ACCEPT

# Finally, start a screen with an ssh tunnel to run in the background.
try screen -d -m ssh undercloud-0 -L 0.0.0.0:443:"$CODED_IP":443 || failure

# Save admin's password locally
$SSH_CUST stack@$HOST "source /home/stack/stackrc && sudo hiera admin_password" > admin_password
$SSH_CUST stack@$HOST "cat /home/stack/ctlplane-addr" > ctlplane-addr

}

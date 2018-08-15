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
# Install ceph-ansible.
yum install -y ceph-ansible &> /dev/null

# Saving the IPs set for br-ctlplane and docker0.
rm -rf ctlplane-addr docker0-addr
/usr/sbin/ip a | grep -A10 "br-ctlplane:" | grep "inet " | awk '{print \$2}' | cut -d "/" -f 1 | sort | tr "\\n" " "  > /home/stack/ctlplane-addr
/usr/sbin/ip a | grep -A4 "docker0:" | grep "inet " | awk '{print \$2}' | cut -d "/" -f 1 | sort | tr "\\n" " " > /home/stack/docker0-addr
chown stack:stack /home/stack/ctlplane-addr /home/stack/docker0-addr
if [ ! -f /home/stack/ctlplane-addr ]
then
    exit 1
fi
BR_IP=\$(cut -d " " -f 1 /home/stack/ctlplane-addr)
DK_IP=\$(cut -d " " -f 1 /home/stack/docker0-addr)

# Instead of any internal IP, https will listen with the host's FQDN.
if ! grep $(hostnamectl --static) /var/www/openstack-tripleo-ui/dist/tripleo_ui_config.js
then
    sudo sed -E "s/$CODED_IP/$(hostnamectl --static)/" -i /var/www/openstack-tripleo-ui/dist/tripleo_ui_config.js
fi

systemctl stop httpd
systemctl start httpd

if [ -z $DEFAULT_GATEWAY ]; then exit 1; fi

# Copying SSH ids.
for ip in $DEFAULT_GATEWAY \$(cat /home/stack/ctlplane-addr) \$(cat /home/stack/docker0-addr)
do
    sshpass -p $HOST_PASS ssh-copy-id root@\$ip &> /dev/null
done

# Testing passwordless SSH.
for ip in $DEFAULT_GATEWAY \$(cat /home/stack/ctlplane-addr) \$(cat /home/stack/docker0-addr) 
do
    $SSH_CUST root@\$ip "echo hello"
done
EOF

run_script_file post_uc_install_tweaks root "$HOST" /root

# Finally, start a screen with an ssh tunnel to run in the background.
try screen -d -m ssh undercloud-0 -L 0.0.0.0:443:"$CODED_IP":443 || failure

# Save admin's password locally
$SSH_CUST stack@$HOST "source /home/stack/stackrc && sudo hiera admin_password" > admin_password
$SSH_CUST stack@$HOST "cat /home/stack/ctlplane-addr" > ctlplane-addr
}

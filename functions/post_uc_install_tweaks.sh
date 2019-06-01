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

    # I need to swap the IP set in the UI config file to the one set in the
    # external network to be able to connect to the UI via SSH tunnel later.
    UI_CONF_FILE="/var/lib/config-data/puppet-generated/tripleo-ui/var/www/openstack-tripleo-ui/dist/tripleo_ui_config.js"

    ($SSH_CUST root@$HOST -L 0.0.0.0:443:$PUBLIC_HOST:443) &

    cat > post_uc_install_tweaks_root <<EOF
set -e

# Make sure we're up-to-date.
yum update -y

# Install ceph-ansible.
yum install -y ceph-ansible &> /dev/null

# Saving the IPs set for br-ctlplane.
rm -rf ctlplane-addr
/usr/sbin/ip a | grep -A10 "br-ctlplane:" | grep "inet " | awk '{print \$2}' | cut -d "/" -f 1 | sort | tr "\\n" " "  > /home/stack/ctlplane-addr
chown stack:stack /home/stack/ctlplane-addr
if [ ! -f /home/stack/ctlplane-addr ]
then
    exit 1
fi
BR_IP=\$(cut -d " " -f 1 /home/stack/ctlplane-addr)

if [ -z $DEFAULT_GATEWAY ]; then exit 1; fi

# If there is no ssh pub file, create it.
if [ ! -r /root/.ssh/id_rsa ]
then
    ssh-keygen -t rsa -N "" -f "/root/.ssh/id_rsa"
fi

sed '/PermitRootLogin/d' -i /etc/ssh/sshd_config
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
systemctl restart sshd

# Copying SSH ids.
for ip in $DEFAULT_GATEWAY \$(cat /home/stack/ctlplane-addr) $HOST_IP
do
    sshpass -p $HOST_PASS ssh-copy-id root@\$ip &> /dev/null
    $SSH_CUST root@\$ip "echo hello"
done
EOF

    run_script_file post_uc_install_tweaks_root root "$HOST" /root

    # stack user needs some passwordless SSH love as well.
    cat > post_uc_install_tweaks_stack <<EOF
set -e
cd /home/stack

# Copying SSH ids.
for ip in $DEFAULT_GATEWAY \$(cat /home/stack/ctlplane-addr)
do
    sshpass -p $HOST_PASS ssh-copy-id root@\$ip &> /dev/null
    $SSH_CUST root@\$ip "echo hello"
done
EOF

    run_script_file post_uc_install_tweaks_stack stack "$HOST" /home/stack

    # Save admin's password locally.
    $SSH_CUST $HOST "grep OS_PASSWORD /home/stack/stackrc" | cut -d "=" -f 2 > admin_password
    # Save ctlplane's IP locally.
    $SSH_CUST stack@$HOST "cat /home/stack/ctlplane-addr" > ctlplane-addr
}

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

BR_NAME="br-ctlplane"
BR_IP=\$(/usr/sbin/ifconfig \$BR_NAME | grep "inet " | awk '{print \$2}')
echo "\$BR_NAME ip is \$BR_IP"

DK_NET="docker0"
DK_IP=\$(/usr/sbin/ifconfig \$DK_NET | grep "inet " | awk '{print \$2}')
echo "\$DK_NET ip is \$DK_IP"

if [ -z $DEFAULT_GATEWAY ]; then exit 1; fi
if [ -z \$BR_IP ]; then exit 1; fi
if [ -z \$DK_IP ]; then exit 1; fi

# Copying SSH id to the default gateway.
for ip in $DEFAULT_GATEWAY \$BR_IP \$DK_IP
do
    sshpass -p $HOST_PASS ssh-copy-id root@\$ip &> /dev/null
done

# Testing passwordless SSH.
$SSH_CUST root@$DEFAULT_GATEWAY "echo hello"
$SSH_CUST root@\$BR_IP "echo hello"
$SSH_CUST root@\$DK_IP "echo hello"

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
}

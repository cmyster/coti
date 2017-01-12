fix_host_ssh ()
{
    echo "Creating a fresh SSH key and fixing SSH configurations."
    rm -rf /root/.ssh/id* /root/.ssh/known_hosts
    ssh-keygen -N ""<<EOF



EOF

    cat > /root/.ssh/config <<EOF
GlobalKnownHostsFile=/dev/null
Host *
    StrictHostKeyChecking no
EOF
    ln -s /dev/null /root/.ssh/known_hosts
}

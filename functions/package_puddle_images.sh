package_puddle_images ()
{
    PUDDLE=$(cat puddle)
    RR_CMD=$(cat rr_cmd)
    try tar cf images.tar ironic-python-agent.initramfs ironic-python-agent.kernel overcloud-full.qcow2 overcloud-full.initrd overcloud-full.vmlinuz || failure
    rm -rf overcloud-full* ironic-python-agent* usr
    mkdir $PUDDLE
    mv images.tar $PUDDLE
    mv $GUEST_IMAGE $PUDDLE
    echo "built on: $(date)" > $PUDDLE/version
    echo "command used: rhos-relese $RR_CMD" >> $PUDDLE/version
    echo "puddles used:" >> $PUDDLE/version
    if [ -r /var/lib/rhos-release/latest-installed ]
    then
        cat /var/lib/rhos-release/latest-installed >> $PUDDLE/version
    fi
    if [ -r /etc/rhosp-relaese ]
    then
        cp /etc/rhosp-relaese $PUDDLE
    fi

    tar cf ${PUDDLE}.tar $PUDDLE
}

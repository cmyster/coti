package_puddle_image ()
{
    PUDDLE=$(cat puddle)
    RR_CMD=$(cat rr_cmd)
    mkdir $PUDDLE
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

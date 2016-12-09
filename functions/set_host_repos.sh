set_host_repos ()
{
    # set the repo files and get core puddle version
    echo "Removing old rhos-release."
    try yum -y -q -e 0 remove rhos-release || failure

    echo "Installing latest rhos-release."
    try rpm -ivh $LATEST_RR &> /dev/null || failure

    echo "Clearing yum cache and repo files."
    rm -rf /etc/yum.repos.d/* /var/cache/yum/*

    echo "Setting repos with rhos-release."
    case "$PUDDLE_VER" in
        latest)
            VERS_URL=$(elinks --dump $REPO_PATH | grep "/$OSPD_VER" | grep -v Opt | awk '{print $NF}')
            PUDDLE=$(elinks --dump $VERS_URL| grep /20 | rev | cut -d "/" -f 2 | rev | sort | tail -n 1)
            ;;
    esac

    if [ ! -z "$PUDDLE" ]
    then
        RR_CMD="$OSPD_VER -p $PUDDLE"
    fi

    echo "Running rhos-release $RR_CMD."
    rhos-release $RR_CMD &> rr.log
    grep "#" rr.log | grep -v director | awk '{print $NF}' > puddle
    PUDDLE=$(cat puddle)
    echo "Using puddle: $PUDDLE."
}

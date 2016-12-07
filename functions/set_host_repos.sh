set_host_repos ()
{
    # set the repo files and get core puddle version
    echo "removing old rhos-release"
    try yum -y -q -e 0 remove rhos-release || failure
    echo "installing latest rhos-release"
    try rpm -ivh $LATEST_RR &> /dev/null || failure
    echo "clearing yum cache and repo files"
    rm -rf /etc/yum.repos.d/* /var/cache/yum/*
    echo "setting repos with rhos-release"
    rhos-release $RR_CMD &> /tmp/rr.log
    grep "#" /tmp/rr.log | grep -v director | awk '{print $NF}' > puddle
    PUDDLE=$(cat puddle)
    echo "using puddle: $PUDDLE"
}

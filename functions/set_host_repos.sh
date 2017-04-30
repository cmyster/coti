set_host_repos ()
{
set -x
    # set the repo files and get core puddle version
    echo "Removing old rhos-release."
    try yum -y -q -e 0 remove rhos-release || failure

    echo "Installing latest rhos-release."
    try rpm -ivh $LATEST_RR &> /dev/null || failure

    echo "Clearing yum cache and repo files."
    rm -rf /etc/yum.repos.d/* /var/cache/yum/*

    echo "Setting repos with rhos-release."
    if [ $UC_VER -lt 10 ]
    then
        URL=$REPO_PATH_OLD
        DIRECTOR="-director"
    else
        URL=$REPO_PATH
    fi

    PUDDLE=$(elinks --dump $URL | grep -e http.*201 | awk '{print $NF}' | sort | tail -n 1 | rev | cut -d "/" -f 2 | rev)

    if [ ! -z "$PUDDLE" ]
    then
        RR_CMD="${UC_VER}${DIRECTOR} -p $PUDDLE"
    fi

    echo "Running rhos-release ${RR_CMD}."
    rhos-release $RR_CMD &> rr.log
    echo "Using puddle: ${PUDDLE}."
exit
}

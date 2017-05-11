discover_puddle_version ()
{
    VERSION=$1

    echo "Removing old rhos-release."
    try yum -y -q -e 0 remove rhos-release || failure

    echo "Installing latest rhos-release."
    try rpm -ivh $LATEST_RR &> /dev/null || failure

    echo "Getting repo URL from rhos-release."
    URL=$(grep -A2 rhelosp-11.0-puddle /var/lib/rhos-release/repos/rhos-release-11.repo | grep baseurl | cut -d = -f 2 | rev | cut -d "/" -f 5- | rev)
    echo "Using repo URL: $URL"
    
    PUDDLE=$(elinks --dump $URL | grep -e http.*201 | awk '{print $NF}' | sort | tail -n 1 | rev | cut -d "/" -f 2 | rev)
    echo $PUDDLE > puddle

    if [ -z "$PUDDLE" ]
    then
        echo "Failed to set puddle."
        raise ${FUNCNAME[0]}
    else
        RR_CMD="${UC_VER} -p $PUDDLE"
        echo $RR_CMD > rr_cmd
    fi

    echo "Using puddle: ${PUDDLE}."
    echo "rhos-release will be run with: $(cat rr_cmd) "
}

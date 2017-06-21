discover_puddle_version ()
{
    VERSION=$1

    echo "Deploying rhos-release RPM."
    try rpm2cpio rhos-release-latest.noarch.rpm | cpio -idmv &> /dev/null || failure

    echo "Getting repo URL from rhos-release."
    URL=$(grep -A2 rhelosp-${OS_VER}.0-puddle var/lib/rhos-release/repos/rhos-release-${OS_VER}.repo | grep baseurl | cut -d = -f 2 | rev | cut -d "/" -f 5- | rev)
    echo "Using repo URL: $URL"
    
    PUDDLE=$(elinks --dump $URL | grep -e http.*201 | awk '{print $NF}' | sort | tail -n 1 | rev | cut -d "/" -f 2 | rev)
    echo $PUDDLE > puddle

    if [ -z "$PUDDLE" ]
    then
        echo "Failed to set puddle."
        raise ${FUNCNAME[0]}
    else
        RR_CMD="${OS_VER} -p $PUDDLE"
        echo $RR_CMD > rr_cmd
    fi

    echo "Using puddle: ${PUDDLE}."
    echo "rhos-release will be run with: $(cat rr_cmd) "

    rm -rf etc usr var
}

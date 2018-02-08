clean ()
{
    echo "Cleaning leftovers from previous runs."

    for node in $(find . -name "*.inv" | cut -d "." -f 1)
    do
        sed -i "/$node/d" /etc/hosts
    done

    rm -rf "$WORK_DIR"
    mkdir -p "$WORK_DIR"
    cd "$WORK_DIR" || exit 1

    unset DIB_LOCAL_IMAGE
    unset DIB_CLOUD_INIT_ETC_HOSTS
    unset DIB_YUM_REPO_CONF
    unset NO_SOURCE_REPOSITORIES
    unset RHOS
    unset REG_METHOD
    unset REG_HALT_UNREGISTER
    unset USE_DELOREAN_TRUNK
}

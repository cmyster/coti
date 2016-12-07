proto_extra_files ()
{
    try wget -q -nv $LATEST_RR || failure
    try wget -q -nv -r -nd -np ${EPEL}/n/ -A "nethogs-*.rpm" || failure
    try wget -q -nv -r -nd -np ${EPEL}/h/ -A "htop-*.rpm" || failure
    try wget -q -nv -r -nd -np ${EPEL}/g/ -A "glances-*.rpm" || failure
    try wget -q -nv $RHEL_GUEST || failure

    tar cf files.tar *.rpm *.conf
}

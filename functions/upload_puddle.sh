upload_puddle ()
{
    try sshpass -p $UPLOAD_PASS scp -q ${PUDDLE}.tar ${UPLOAD_USER}@$UPLOAD_URL/$OSPD_VER &> /dev/null || failure
    try sshpass -p $UPLOAD_PASS ssh ${UPLOAD_USER}@${SRV_DOMAIN} "cd $UPLOAD_DIR/$OSPD_VER && tar xf ${PUDDLE}.tar && rm -rf ${PUDDLE}.tar" &> /dev/null || failure
    rm -rf ${PUDDLE}*
}


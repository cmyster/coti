upload_puddle ()
{
    PUDDLE=$(cat puddle)
    try sshpass -p $UPLOAD_PASS scp -q ${PUDDLE}.tar ${UPLOAD_USER}@$UPLOAD_URL/$OS_VER &> /dev/null || failure
    try sshpass -p $UPLOAD_PASS $SSH ${UPLOAD_USER}@${SRV_DOMAIN} "cd $UPLOAD_DIR/$OS_VER && tar xf ${PUDDLE}.tar && rm -rf ${PUDDLE}.tar" &> /dev/null || failure
    rm -rf ${PUDDLE}*
}


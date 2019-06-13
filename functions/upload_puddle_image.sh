upload_puddle_image ()
{
    PUDDLE=$(cat puddle)
    try sshpass -p "$UPLOAD_PASS" scp -q "${PUDDLE}".tar "${UPLOAD_USER}@${SRV_DOMAIN}:" &> /dev/null || failure
    cat > set_image_path <<EOF
#!/bin/bash
set -e
cd ~
TARBALL=\$(find . -maxdepth 1 -mindepth 1 -name "*$PUDDLE*tar")

if [ ! -d $UPLOAD_DIR/$OS_VER ]
then
    mkdir -p $UPLOAD_DIR/$OS_VER
fi

mv \$TARBALL $UPLOAD_DIR/$OS_VER
cd $UPLOAD_DIR/$OS_VER
tar xf \$TARBALL
rm -rf \$TARBALL

rm -rf ~/set_image_path

EOF
    chmod +x set_image_path
    try sshpass -p "$UPLOAD_PASS" scp -q set_image_path "${UPLOAD_USER}@${SRV_DOMAIN}:" &> /dev/null || failure
    sshpass -p "$UPLOAD_PASS" $SSH_CUST "${UPLOAD_USER}@${SRV_DOMAIN}" "/home/${UPLOAD_USER}/set_image_path"
    rm -rf "${PUDDLE}"*
}

edit_predefined_images ()
{
    LIBGUESTFS_BACKEND=direct

    # getting the premade director RPMs
    try wget -q $OC_IMAGES || failure
    try wget -q $OC_IPA || failure

    # extracting
    rpm2cpio $(basename $OC_IMAGES) | cpio -idmv
    rpm2cpio $(basename $OC_IPA) | cpio -idmv

    tar xf usr/share/rhosp-director-images/overcloud-full* -C .
    tar xf usr/share/rhosp-director-images/ironic-python-agent* -C .

    # adding extra packages to the image
    try virt-sysprep -q -a overcloud-full.qcow2 --upload $WORK_DIR/files.tar:/root || failure

    # adding repos and selinux stuff
    cat > edit_image << EOF
#!/bin/bash
LOG=edit_image.log
cp \$0 /root/edit_image
/usr/sbin/setenforce 0 | tee -a \$LOG
cd /root/
yum remove -y rhos-release | tee -a \$LOG
if [ -r files.tar ]
then
    tar xf files.tar | tee -a \$LOG
    rm -rf files.tar
fi
rpm -Uvh rhos-release-latest.noarch.rpm | tee -a \$LOG
rm -rf rhos-release-latest.noarch.rpm | tee -a \$LOG
rhos-release $RR_CMD | tee -a \$LOG
yum update -y | tee -a \$LOG
yum install -y vim mc git python-psutil | tee -a \$LOG
yum remove -y *bigswitch*
for rpm in \$(ls *.rpm)
do
    rpm -Uvh \$rpm | tee -a \$LOG
    rm -rf \$rpm
done
/usr/bin/sed -i "s/SELINUX=.*/SELINUX=$OVER_SEL/" /etc/selinux/config
echo $ROOT_PASS | passwd root --stdin
touch /.autorelabel
EOF

    chmod 0755 edit_image
    mv overcloud-full.qcow2 temp.qcow2
    echo "Editing the overcloud image."
    try virt-customize $CUST_ARGS -a temp.qcow2 --run edit_image || failure
    echo "Sparsing and compressing free space to make the image smaller."
    try virt-sparsify -q --compress temp.qcow2 overcloud-full.qcow2 || failure
    rm -rf temp.qcow2
}

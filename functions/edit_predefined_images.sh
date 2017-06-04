edit_predefined_images ()
{
    LIBGUESTFS_BACKEND=direct
    RR_CMD=$(cat rr_cmd)

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
LOG_FILE=/root/predefine-image.log
/usr/sbin/setenforce 0 | tee -a \$LOG_FILE
cd /root/

if rpm -qa | grep rhos-release
then
    yum remove -y rhos-release | tee -a \$LOG_FILE
fi

if [ -r files.tar ]
then
    tar xf files.tar | tee -a \$LOG_FILE
    rm -rf files.tar
fi

rpm -Uvh rhos-release-latest.noarch.rpm | tee -a \$LOG_FILE
rm -rf rhos-release*.rpm | tee -a \$LOG_FILE

rhos-release $RR_CMD | tee -a \$LOG_FILE
yum remove -y *bigswitch*
yum update -y | tee -a \$LOG_FILE
yum install -y mlocate vim mc git wget python-psutil | tee -a \$LOG_FILE

updatedb
ln -s /usr/bin/updatedb /etc/cron.hourly

sed -i '/PS1/d' /root/.bashrc
echo "PS1='\[\033[01;31m\]\u@\h\] \w \$\[\033[00m\] '" >> /root/.bashrc

for package in \$(ls *.rpm)
do
    rpm -Uvh \$package | tee -a \$LOG_FILE
    rm -rf \$package
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

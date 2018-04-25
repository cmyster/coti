prepare_director_images ()
{
    HOST=$1
    cat > director_images <<EOF
cd /home/stack
rm -rf images
mkdir images
cd images
wget ${FILE_SERVER}/rpms/rhos${OS_VER}/rhosp-director-images-${OS_VER}-latest.rpm || exit 1
wget ${FILE_SERVER}/rpms/rhos${OS_VER}/rhosp-director-images-${OS_VER}-ipa-latest.rpm || exit 1
rpm2cpio rhosp-director-images-${OS_VER}-latest.rpm | cpio -idmv
rpm2cpio rhosp-director-images-${OS_VER}-ipa-latest.rpm | cpio -idmv
mv usr/share/rhosp-director-images/*.tar .
rm -rf usr *.rpm
for tarball in \$(/usr/bin/ls)
    do
    tar xf "\$tarball" || exit 1
done
rm -rf *.tar
cd /home/stack
mv images/* .
rm -rf images
openstack overcloud image upload
EOF

    run_script_file director_images stack "$HOST" /home/stack
}

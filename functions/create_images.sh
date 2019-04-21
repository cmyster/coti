create_images ()
{
    export DIB_LOCAL_IMAGE=$(cat guest_image)
    export DIB_CLOUD_INIT_ETC_HOSTS=false
    DIB_YUM_REPO_CONF="$(find /etc/yum.repos.d -type f | grep -v redhat | tr "\n" " ")"
    export DIB_YUM_REPO_CONF
    export NO_SOURCE_REPOSITORIES=1
    export RHOS=1
    export REG_METHOD=disable
    export REG_HALT_UNREGISTER=1
    export USE_DELOREAN_TRUNK=0

    cp -a \
        /usr/share/openstack-tripleo-common/image-yaml/overcloud-images.yaml \
        /usr/share/openstack-tripleo-common/image-yaml/overcloud-images-rhel7.yaml \
        "$CWD"/templates/overcloud-images-osp.yaml \
    "$WORK_DIR"

    try tripleo-build-images --image-config-file overcloud-images.yaml --image-config-file overcloud-images-rhel7.yaml --image-config-file overcloud-images-osp.yaml || failure

    unset DIB_LOCAL_IMAGE
    unset DIB_CLOUD_INIT_ETC_HOSTS
    unset DIB_YUM_REPO_CONF
    unset NO_SOURCE_REPOSITORIES
    unset RHOS
    unset REG_METHOD
    unset REG_HALT_UNREGISTER
    unset USE_DELOREAN_TRUNK
}

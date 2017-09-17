prepare_docker_images ()
{
    HOST=$1

    if [ ! -r puddle_dir_path ]
    then
        echo "Default puddle path URL was not saved."
        raise ${FUNCNAME[0]}
    fi

    URL=$(cat puddle_dir_path)
    if [ -z "$URL" ]
    then
        echo "Default puddle path URL was not set."
        raise ${FUNCNAME[0]}
    fi

    PUDDLE=$(cat puddle)

    echo "Running pre-overcloud deploy workarounds."
    cat > prepare_docker_images <<EOF
set -e
cd /home/stack/templates
wget $URL/latest_containers/container_images.yaml
cd /home/stack
source stackrc
openstack overcloud container image upload --verbose --config-file container_images.yaml
openstack overcloud container image prepare --namespace=docker-registry.engineering.redhat.com/rhosp${OS_VER} --env-file=rhos${OS_VER}.yaml --prefix=openstack- --suffix=-docker --tag=$PUDDLE
EOF

    run_script_file prepare_docker_images stack $HOST /home/stack                  
}

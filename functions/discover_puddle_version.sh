discover_puddle_version ()
{
    set_puddle ()
    {
        if [ -z "$1" ]
        then
            echo "Failed to set puddle."
            raise "${FUNCNAME[0]}"
        else
            echo "$1" > puddle
            RR_CMD="${OS_VER} -p $1"
            echo "$RR_CMD" > rr_cmd
            if [ $OS_VER -gt 11 ]
            then
                NAMESPACE=$(grep " namespace:" overcloud_container_image_prepare.yaml | awk '{print $NF}')
                PREFIX=$(grep " prefix:" overcloud_container_image_prepare.yaml | awk '{print $NF}')
                TAG=$(grep " tag:" overcloud_container_image_prepare.yaml | awk '{print $NF}')
                CEPH_NAMESPACE=$(grep " ceph-namespace:" overcloud_container_image_prepare.yaml | awk '{print $NF}')
                CEPH_IMAGE=$(grep " ceph-image:" overcloud_container_image_prepare.yaml | awk '{print $NF}')
                CEPH_TAG=$(grep " ceph-tag:" overcloud_container_image_prepare.yaml | awk '{print $NF}')

                cat > docker_image_params <<EOF
    --namespace $NAMESPACE \\
    --prefix $PREFIX \\
    --tag $TAG \\
    --set ceph-namespace=$CEPH_NAMESPACE \\
    --set ceph-image=$CEPH_IMAGE \\
    --set ceph-tag=$CEPH_TAG \\
EOF
            fi
        fi
    }

    find_url ()
    {
        echo "Extracting rhos-release RPM."
        try rpm2cpio rhos-release-latest.noarch.rpm | cpio -idmv &> /dev/null || failure
        echo "Getting repo URL from rhos-release."
        URL=$(grep -A2 rhelosp-"${OS_VER}".0-puddle var/lib/rhos-release/repos/rhos-release-"${OS_VER}".repo | grep baseurl | cut -d = -f 2 | rev | cut -d "/" -f 5- | rev)
        echo "$URL" > puddle_dir_path
        echo "Using repo URL: $URL"
    }

    discover ()
    {
        URL=$(cat puddle_dir_path)
        PUDDLE=$(elinks --dump $URL/passed_phase2/RH7-RHOS-"${OS_VER}".0.repo | grep baseurl | grep "basearch/os" | rev | cut -d "/" -f 4 | rev)

        if [ -z "$PUDDLE" ]                                                        
        then                                                                  
            echo "Failed to set puddle."                                      
            raise "${FUNCNAME[0]}"                                            
        fi

        if [ $OS_VER -gt 11 ]
        then
            try wget "$URL"/passed_phase2/overcloud_container_image_prepare.yaml || failure
        fi
        set_puddle "$PUDDLE"
        echo "Using puddle: ${PUDDLE}."
        echo "rhos-release will be run with: $(cat rr_cmd)"
        rm -rf etc usr var
    }

    find_url
    discover
}

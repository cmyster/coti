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
        set -x
        URL=$(cat puddle_dir_path)
        IMAGE_URL="$URL/latest_containers/container_images.yaml"
        if wget -q --spider "$IMAGE_URL"
        then
            PUDDLE=$(elinks --dump "$URL"/latest_containers/container_images.yaml | grep docker: | tr ":" " " | awk '{print $2}' | head -n 1)
        else
            PUDDLE=$(elinks --dump "$URL" | tr "]" " " | tr -d / | grep '[0-9]-[0-9][0-9]-[0-9]' | cut -d " " -f 6 | sed '/^$/d' | sort)
        fi
        set_puddle "$PUDDLE"
        echo "Using puddle: ${PUDDLE}."
        echo "rhos-release will be run with: $(cat rr_cmd) "

        rm -rf etc usr var
    }

    if [[ "$PUDDLE_VER" == "latest" ]]
    then
        find_url
        discover
    else
        find_url
        set_puddle "$PUDDLE_VER"
    fi
}


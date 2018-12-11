define_flavors ()
{
    HOST=$1
    SCRIPT="define_flavors" 
    rm -rf "$SCRIPT"
    echo "cd /home/stack" >> $SCRIPT
    echo "source stackrc" >> $SCRIPT

    for inv in $(ls ./*0.inv | grep -v -i under)
    do
        source "$inv"
        f_tmp_name=$(echo "$name" | cut -d "-" -f 1)
        case "$f_tmp_name" in
            ceph)
                f_name="ceph" ;;
            controller)
                f_name="controller" ;;
            compute)
                f_name="compute" ;;
        esac
        f_ram=$memory
        f_disk=$(( disk - 3 )) # Removing GB due to ironic bug.
        f_cpu=$cpu
        {
            echo "openstack flavor delete $f_name"
            echo "openstack flavor create $f_name --ram $f_ram --disk $f_disk --vcpus $f_cpu"
            echo 'openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="'$f_name'" '$f_name''
        } >> "$SCRIPT"
    done
    run_script_file "$SCRIPT" stack "$HOST" /home/stack
}

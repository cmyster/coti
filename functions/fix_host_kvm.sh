fix_host_kvm ()
{
    echo "Making sure KVM models are loaded."
    if grep Intel /proc/cpuinfo &> /dev/null
    then
        KVM="kvm-intel"
    else
        KVM="kvm-amd"
    fi

    if ! grep $KVM /etc/modprobe.d/dist.conf &> /dev/null
    then
        echo "options $KVM nested=y" >> /etc/modprobe.d/dist.conf
    fi

    if lsmod | grep $KVM &> /dev/null
    then
        modprobe $KVM
    fi

    if lsmod | grep vhost_net &> /dev/null
    then
        modprobe vhost_net
    fi
}

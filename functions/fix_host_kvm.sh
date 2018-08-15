fix_host_kvm ()
{
    echo "Making sure KVM models are loaded."
    if grep Intel /proc/cpuinfo &> /dev/null
    then
        KVM="kvm_intel"
    else
        KVM="kvm_amd"
    fi

    if ! grep $KVM /etc/modprobe.d/dist.conf &> /dev/null
    then
        echo "options $KVM nested=y" >> /etc/modprobe.d/dist.conf
    fi

    rmmod "$KVM"
    rmmod vhost_net
    try modprobe $KVM || failure
    try modprobe vhost_net || failure
}

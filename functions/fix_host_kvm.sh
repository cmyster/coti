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

    rmmod $KVM
    rmmod vhost_net
    modprobe $KVM preemption_timer=0
    modprobe vhost_net
}

fix_virt_access ()
{
    echo "Allowing VMs to access virt on the host server."
    if [ ! -r /etc/polkit-1/localauthority/50-local.d/50-libvirt-stack.pkla ]
    then
        if [ ! -d /etc/polkit-1/localauthority/50-local.d ]
        then
            mkdir -p /etc/polkit-1/localauthority/50-local.d
        fi
        cat > /etc/polkit-1/localauthority/50-local.d/50-libvirt-stack.pkla <<EOF
[ibvirt Management Access]
Identity=unix-user:stack
Action=org.libvirt.unix.manage
ResultAny=yes
ResultInactive=yes
ResultActive=yes
EOF
    fi
}

host_tweaks ()
{
    echo "Making sure that $VIRT_IMG exists."
    if [ ! -d "$VIRT_IMG" ]
    then
        mkdir -p "$VIRT_IMG"
    fi

    echo "Adding configurations and other tweaks for easier life."
    # Adding Xauth for simpler SSH tunneling.
    if [ ! -f ~/.Xauthority ]
    then
        touch ~/.Xauthority
        mcookie | sed -e 's/^/add :0 . /' | xauth -q &> /dev/null
    fi

    # Removing requiredtty so sudo can work from a remote script.
    if grep requiretty /etc/sudoers &> /dev/null
    then 
        sed -i '/requiretty/d' /etc/sudoers
    fi
    
    # Setting some rc files to what I use.
    cp -rf "$CWD/rcfiles/.vimrc" /etc/vimrc
    cp -rT "$CWD/rcfiles" /root

    # Aliasig for faster acceess to undercloud-0 as stack.
    if ! grep "alias uc" /root/.bashrc &> /dev/null
    then
        echo "alias uc='ssh stack@undercloud-0'"
    fi

    # Opening all ports.
    systemctl disable firewalld                                                   
    systemctl stop firewalld                                                      
    iptables -F
    iptables -X
    iptables -t nat -F
    iptables -t nat -X
    iptables -t mangle -F
    iptables -t mangle -X
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
    systemctl stop libvirtd
    systemctl start libvirtd

    # Add en_US language to environemt file if missing
    if ! grep en_US /etc/environment
    then
        cat >> /etc/environment <<EOF
LANG=en_US.utf-8
LC_ALL=en_US.utf-8
EOF
    fi

    # Createing locatedb
    /usr/bin/updatedb
    if [ ! -r /etc/cron.hourly/updatedb ]
    then
        ln -s /usr/bin/updatedb /etc/cron.hourly
    fi

    # Creating stack user on virthost.
    echo "Adding user stack."
    useradd stack
    echo stack | passwd stack --stdin
    echo "stack ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/stack
}

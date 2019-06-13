proto_firstrun ()
{
    RR_CMD=$(cat rr_cmd)
    cat > firstboot <<EOF
set -e
cd /root
if ! ps -ef | grep dhclient &> /dev/null
then
    dhclient eth0
    ping -w 3 www.google.com
fi

if [ -r files.tar ]
then
    tar xf files.tar
    rpm -Uvh *rpm --nodeps
    rm -rf *rpm
fi

echo "Setting up repos."
rm -rf /etc/yum.repos.d/* /var/cache/yum/*
rhos-release $RR_CMD &> /dev/null
sed "s|RHOS_TRUNK-15-trunk|RHOS_TRUNK-15|g" -i /etc/yum.repos.d/rhos-release-15-trunk.repo

echo "Updating the OS."
$PKG_CUST update

echo "Installing some tools."
$PKG_CUST install acpid device-mapper-multipath dosfstools gdb gdisk \\
genisoimage git gpm ipmitool iscsi-initiator-utils lsof mc mlocate nmap-ncat \\
psmisc setroubleshoot sos sysstat telnet tmux traceroute tree vim wget 
$PKG_CUST groupinstall "Development Tools"

echo "Installing TripleO client."
$PKG_CUST install python3-tripleoclient

if ls *.conf 2> /dev/null
then
    for conf in $(ls *.conf 2> /dev/null)
    do
        cp $conf /etc
    done
fi

if [ $undercloud_SWP -gt 1 ]
then
    echo "Creating SWAP file."
    dd if=/dev/zero of=/swap bs=1M count=$undercloud_SWP
    chmod 600 /swap
    mkswap /swap
    echo /swap none swap defaults 0 0 >> /etc/fstab
fi

# cleaning up and some tweaks
rm -rf /etc/yum.repos.d/* /var/cache/yum/*
echo "Some VIM settings"
cat > /etc/vimrc <<END
syntax on
set background=dark
set backspace=2
set colorcolumn=78
set completeopt=menuone,longest,preview
set encoding=utf8
set expandtab
set fileformats=unix
set hlsearch
set laststatus=2
set linebreak
set matchpairs+=(:)
set matchpairs+=<:>
set matchpairs+=[:]
set matchpairs+={:}
set nocompatible
set nonu
set nowrap
set numberwidth=1
set omnifunc=syntaxcomplete#Complete
set ruler
set shiftwidth=4
set showmatch
set softtabstop=4
set tabstop=4

filetype plugin on
filetype indent on

highlight Pmenu ctermfg=cyan ctermbg=blue
highlight PmenuSel ctermfg=black ctermbg=cyan
highlight ColorColumn ctermbg=0
END

echo "Enabling some needed services."
systemctl enable gpm
systemctl enable acpid
systemctl start acpid

echo "Enabling tty-less sudo use."
sed -i '/requiretty/d' /etc/sudoers

echo "Setting Selinux."
sed -i "s/SELINUX=.*/SELINUX=$OVER_SEL/" /etc/selinux/config
grep "SELINUX=" /etc/selinux/config

echo "Setting time."
timedatectl set-timezone $GUEST_TZ
if [ ! -d /root/.ssh ]
then
    mkdir /root/.ssh
    chmod 0700 /root/.ssh
fi

echo "Setting prompt."
sed -i '/PS1/d' /root/.bashrc
echo "PS1='\[\033[01;31m\]\u@\h\] \w \$\[\033[00m\] '" >> /root/.bashrc

echo "Updating locate db and adding it to cron."
updatedb
if [ ! -f /etc/cron.hourly/updatedb ]
then
    ln -s /usr/bin/updatedb /etc/cron.hourly
fi

echo "Allowing a more comfortable SSH connections."
cat > /etc/ssh/ssh_config <<END
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    CheckHostIp no
END

rm -rf /root/.ssh/known_hosts
ln -s /dev/null /root/.ssh/known_hosts

echo "Adding user stack."
useradd stack
echo stack | passwd stack --stdin
echo "stack ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/stack
chmod 0440 /etc/sudoers.d/stack
rm -rf /root/files.tar

echo "Shutting down now."
shutdown -hP -t 0 now

EOF
    chmod +x firstboot
    try virt-sysprep -q -a "$VIRT_IMG"/proto.qcow2 --upload "$WORK_DIR"/firstboot:/root || failure
}

proto_firstrun ()
{
    cat > firstboot <<EOF
cd /root
cp $0 /root
echo "clean_requirements_on_remove=1" >> /etc/yum.conf
systemctl stop NetowrkManager
systemctl disable NetworkManager
yum remove -y cloud-init* NetworkManager* *bigswitch*

dhclient eth0

if [ -r files.tar ]
then
    tar xf files.tar
    rpm -Uvh rhos-release*rpm || exit 1

    rm -rf rhos-release*rpm
fi

rm -rf /etc/yum.repos.d/* /var/cache/yum/*
rhos-release $RR_CMD || exit 1
yum update -y || exit 1
yum groups mark convert
yum install -y acpid ahc-tools createproto crudini device-mapper-multipath \
dosfstools elinks gdb gdisk genisoimage git gpm hdparm ipmitool \
iscsi-initiator-utils keepalived libvirt lsof mc mlocate net-tools ntp \
openstack-glance openstack-ironic-python-agent \
openstack-puppet-modules openstack-selinux \
openstack-swift openstack-utils plotnetcfg psmisc puppet pystache \
python-debtcollector python-hardware-detect python-heat-agent-ansible \
python-heat-agent-apply-config python-heat-agent-hiera python-heat-agent-puppet \
python-networking-cisco python-psutil \
python-rdomanager-oscplugin python-setuptools python-tripleoclient python-UcsSdk \
redhat-access-insights rhosp-release screen setroubleshoot sos sshpass sysstat \
telnet tmux traceroute tree vim virt-manager wget 
yum group install -y "Development Tools" || exit 1

rpm -Uvh /root/*.rpm || exit 1
cp *.conf /etc
rm -rf /root/*.tar /root/*.rpm /root/*.conf

# creating a SWAP file and zipping it otherwise image creation will fail
dd if=/dev/zero of=/swap bs=1M count=$undercloud_SWP
chmod 600 /swap
mkswap /swap
echo /swap none swap defaults 0 0 >> /etc/fstab

# cleaning up and some tweaks
rm -rf /etc/yum.repos.d/* /var/cache/yum/*
echo "syntax on
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
highlight ColorColumn ctermbg=0" > /etc/vimrc

systemctl enable gpm
enable acpid service
service acpid start
sed -i '/requiretty/d' /etc/sudoers
sed -i "s/SELINUX=.*/SELINUX=$OVER_SEL/" /etc/selinux/config
timedatectl set-timezone $GUEST_TZ
if [ ! -d /root/.ssh ]
then
    mkdir /root/.ssh
    chmod 0700 /root/.ssh
fi
echo "PS1='\[\033[01;31m\]\u@\h\] \w \$\[\033[00m\] '" >> /root/.bashrc
updatedb
ln -s /usr/bin/updatedb /etc/cron.hourly
echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config
echo "    UserKnownHostsFile /dev/null" >> /etc/ssh/ssh_config
echo "    CheckHostIp no" >> /etc/ssh/ssh_config
ln -s /dev/null /root/.ssh/known_hosts

useradd stack
echo stack | passwd stack --stdin
echo "stack ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/stack
chmod 0440 /etc/sudoers.d/stack

shutdown -hP -t 0 now

EOF
    chmod +x firstboot
    try virt-customize $CUST_ARGS -a $VIRT_IMG/proto.qcow2 --firstboot ./firstboot || failure
}

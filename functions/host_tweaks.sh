host_tweaks ()
{
    echo "Adding configurations and other tweaks for easier life."
    # Adding Xauth for simpler ssh tunneling.
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
    
    # Setting vim the way I like it.
    if ! grep augol /etc/vimrc &> /dev/null
    then
        cat > /etc/vimrc <<EOF
" edited by augol@redhat.com the way he likes it.
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
EOF
    fi

    # Removing rm -i from bashrc.
    if grep rm /root/.bashrc
    then
        sed -i '/rm/d' /root/.bashrc
    fi
}

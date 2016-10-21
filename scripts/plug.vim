let g:p = {
            \ "plug":   expand(g:env.path.vim) . "/autoload/plug.vim",
            \ "base":   expand(g:env.path.vim) . "/plugged",
            \ "url":    "https://raw.github.com/junegunn/vim-plug/master/plug.vim",
            \ "github": "https://github.com/junegunn/vim-plug",
            \ }

function! g:p.ready()
  return filereadable(self.plug)
endfunction

if g:p.ready() && g:vimrc_plugin_on
  " start to manage with vim-plug
  call plug#begin(g:p.base)

  " file and directory
  Plug 'b4b4r07/vim-shellutils'
  Plug 'b4b4r07/mru.vim'
  Plug 'junegunn/fzf'
  Plug 'junegunn/fzf.vim'
  Plug 'justinmk/vim-dirvish'
  Plug 'tweekmonster/fzf-filemru'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-endwise'
  Plug 'b4b4r07/enhancd', { 'tag': '2.2.1' }
  "Plug 'kien/ctrlp.vim'
  "Plug 'pbogut/fzf-mru.vim'
  "Plug 'lvht/fzf-mru'
  "Plug 'Shougo/unite.vim'
  "Plug 'b4b4r07/enhancd', { 'tag': '2.2.1' }
  "nnoremap <c-p> :FilesMru --tiebreak=end<cr>
  "let g:enhancd_action = 'Dirvish'
  "let g:enhancd_action = 'Ex'

  " compl
  Plug has('lua') ? 'Shougo/neocomplete.vim' : 'Shougo/neocomplcache'

  if g:env.is_gui
    Plug 'itchyny/lightline.vim'
  endif
  Plug 'Shougo/vimproc.vim',  { 'do': 'make' }
  Plug 'vim-jp/vimdoc-ja'
  Plug 'osyo-manga/vim-anzu'
  Plug 'tyru/caw.vim'
  Plug 'AndrewRadev/gapply.vim'
  Plug 'thinca/vim-quickrun'
  Plug 'mattn/vim-terminal'
  Plug 'mhinz/vim-grepper'
let g:grepper = {
    \ 'tools': ['ag', 'git'],
    \ 'open':  0,
    \ 'jump':  0,
    \ 'switch': 0,
    \ 'prompt': 1,
    \ 'highlight': 1,
    \ }

  " syntax? language support
  Plug 'fatih/vim-go', { 'for': 'go' }
  Plug 'jnwhiteh/vim-golang', { 'for': 'go' }
  "Plug 'zaiste/tmux.vim', { 'for': 'tmux' }
  Plug 'keith/tmux.vim', { 'for': 'tmux' }
  Plug 'dag/vim-fish', { 'for': 'fish' }
  Plug 'zplug/vim-zplug', { 'for': 'zplug' }
  Plug 'chase/vim-ansible-yaml'
  Plug 'evanmiller/nginx-vim-syntax', { 'for': 'nginx' }
  Plug 'cespare/vim-toml', { 'for': 'toml' }
  Plug 'elzr/vim-json', { 'for': 'json' }
  Plug 'b4b4r07/vim-ltsv', { 'for': 'ltsv' }
  Plug 'jelera/vim-javascript-syntax', { 'for': 'javascript' }
  Plug 'maksimr/vim-jsbeautify', { 'for': 'javascript' }

  " colorscheme
  Plug 'b4b4r07/solarized.vim'
  Plug 'w0ng/vim-hybrid'
  Plug 'junegunn/seoul256.vim'
  Plug 'nanotech/jellybeans.vim'
  Plug 'whatyouhide/vim-gotham'
  
  Plug 'thinca/vim-prettyprint', { 'on': 'PP' }

  Plug 'rhysd/github-complete.vim'
  Plug 'junegunn/vim-emoji'

  Plug 'b4b4r07/vim-shell-with-tmux', { 'on': 'Sh' }
  Plug 'zplug/vim-zplug', { 'for': 'zplug' }
  Plug 'tyru/open-browser.vim'
  Plug 'tyru/open-browser-github.vim'
  Plug 'chrisbra/csv.vim', { 'for': 'csv' }

  " Add plugins to &runtimepath
  call plug#end()
endif

" Add plug's plugins
let g:p.plugs = get(g:, 'plugs', {})
let g:p.list  = keys(g:p.plugs)

if !g:p.ready()
  function! g:p.init()
    let ret = system(printf("curl -fLo %s --create-dirs %s", self.plug, self.url))
    "call system(printf("git clone %s", self.github))
    if v:shell_error
      echomsg 'g:p_init: error occured'
      return 1
    endif

    " Restart vim
    "silent! !vim --cmd "let g:pluginit = 1" -c 'echomsg "Run :PlugInstall"'
    silent! !vim
    quit!
  endfunction
  command! PlugInit call g:p.init()

  if g:vimrc_suggest_neobundleinit == g:true
    autocmd! VimEnter * redraw
          \ | echohl WarningMsg
          \ | echo "You should do ':PlugInit' at first!"
          \ | echohl None
  else
    " Install vim-plug
    PlugInit
  endif
endif

function! g:p.is_installed(strict, ...)
  let list = []
  if type(a:strict) != type(0)
        call add(list, a:strict)
    endif
    let list += a:000

    for arg in list
        let name   = substitute(arg, '^vim-\|\.vim$', "", "g")
        let prefix = "vim-" . name
        let suffix = name . ".vim"

        if a:strict == 1
            let name   = arg
            let prefix = arg
            let suffix = arg
        endif

        if has_key(self.plugs, name)
                    \ ? isdirectory(self.plugs[name].dir)
                    \ : has_key(self.plugs, prefix)
                    \ ? isdirectory(self.plugs[prefix].dir)
                    \ : has_key(self.plugs, suffix)
                    \ ? isdirectory(self.plugs[suffix].dir)
                    \ : g:false
            continue
        else
            return g:false
        endif
    endfor

    return g:true
endfunction

function! g:p.is_rtp(p)
    return index(split(&rtp, ","), get(self.plugs[a:p], "dir")) != -1
endfunction

function! g:p.is_loaded(p)
    return g:p.is_installed(1, a:p) && g:p.is_rtp(a:p)
endfunction

function! g:p.check_installation()
  if empty(self.plugs)
    return
  endif

  let list = []
  for [name, spec] in items(self.plugs)
    if !isdirectory(spec.dir)
      call add(list, spec.uri)
    endif
  endfor

  if len(list) > 0
    let unplugged = map(list, 'substitute(v:val, "^.*github\.com/\\(.*/.*\\)\.git$", "\\1", "g")')

    " Ask whether installing plugs like NeoBundle
    echomsg 'Not installed plugs: ' . string(unplugged)
    if confirm('Install plugs now?', "yes\nNo", 2) == 1
      PlugInstall
      " Close window for vim-plug
      silent! close
      " Restart vim
      silent! !vim
      quit!
    endif

  endif
endfunction

if g:p.ready() && g:vimrc_plugin_on
  function! PlugList(A,L,P)
    return join(g:p.list, "\n")
  endfunction

  command! -nargs=1 -complete=custom,PlugList PlugHas
        \ if g:p.is_installed('<args>')
        \ | echo g:p.plugs['<args>'].dir
        \ | endif
endif

" __END__ {{{1
" vim:fdm=marker expandtab fdc=3:

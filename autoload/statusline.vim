"function! GitStatus()
"    let result = split(system('git status --porcelain '.shellescape(expand('%:t'))." 2>/dev/null|awk '{print $1}'"))
"    if len(result) > 0
"		if join(result) == "?"
"			let result=split("")
"		endif
"        return join(result).' '
"    else
"        return ''
"    endif
"endfunction

function! statusline#get_filename() " {{{
	if &filetype == 'help'
		let filename = expand('%:t')
	elseif &filetype == 'gitcommit'
		if expand('%') == '.git/index'
			let filename = 'git status'
		elseif expand('%:t') == 'COMMIT_EDITMSG'
			let filename = 'git commit'
		else
			let filename = 'git'
		endif
"	elseif exists("g:loaded_less") && g:loaded_less && exists(":Man") == 2
	elseif statusline#filetype() == "man" && exists(":Man") == 2
		let l:head = getline(1)
		let l:s_head=split(l:head)
		if !empty(l:s_head)
			let l:w_head=l:s_head[0]
		else
			let l:w_head="<empty>"
		endif
		let l:l_head=tolower(l:w_head)
		let filename = substitute(l:l_head,'\([^(]*\)(\(.*\))','\1.\2','g')
		"let filename = substitute(tolower(split(getline(1))[0]),'\([^(]*\)(\(.*\))','\1.\2','g')
	else
		let filename = expand('%:p:t')
		if empty(filename)
			let filename = '<empty>'
		endif
	endif
	return filename
endfunction " }}}

function! statusline#VCS_branch() " {{{
	if !exists("b:vcs_branch")
		for [l:cvcs, l:cmd] in [["git","(git branch | awk '/\*/{print $2}') 2>/dev/null"],["hg","(hg branch) 2>/dev/null"],["svn",'(svn info | awk "/^URL:/{print gensub(/.*\//,\"\",\"g\",\$2)}") 2>/dev/null']]
			let l:res = join(split(system(l:cmd)))
			if len(l:res) > 0
				let l:vcs = l:cvcs
				break
			endif
			unlet l:cvcs
			unlet l:cmd
		endfor
		if exists("l:vcs")
			if l:vcs == "git"
				let b:vcs_branch = "%#VCSI_".l:vcs."#".nr2char(177)."%#FileName#:".l:res
			elseif l:vcs == "hg"
				let b:vcs_branch = "%#VCSI_".l:vcs."#".nr2char(9791)."%#FileName#:".l:res
			elseif l:vcs == "svn"
				let b:vcs_branch = "%#VCSI_".l:vcs."#"."S"."%#FileName#:".l:res
			else
				let b:vcs_branch = ""
			endif
		endif
		let b:vcs_branch = ""
	endif
	return b:vcs_branch
endfunction " }}}

function! statusline#PercentPosition()
  return (line(".") * 100) / line("$")
endfunction

let g:last_mode = ''

function! statusline#filetype() " {{{
	if !exists("b:filetype")
		if !len(&filetype) == 0
			let b:filetype = &filetype
		else
			let l:fn = glob("%")
			if !len(l:fn) == 0
				let b:filetype = join(split(system("file -s -p -L -z -b --mime-type ".l:fn))) " TODO: sometimes there is no `file`
			else
				let b:filetype = "none"
			endif
		endif
	endif
	return b:filetype
endfunction " }}}

function! statusline#get_icon(name) " {{{
	let l:fallback      = {}
	let l:fallback.rar  = nr2char(57520) "  .
	let l:fallback.rlar = nr2char(57521) "  .
	let l:fallback.lar  = nr2char(57522) "  .
	let l:fallback.llar = nr2char(57523) "  .

	" let l:fallback.rar  = nr2char(57520+(4*1)) "  .
	" let l:fallback.rlar = nr2char(57521+(4*1)) "  .
	" let l:fallback.lar  = nr2char(57522+(4*1)) "  .
	" let l:fallback.llar = nr2char(57523+(4*1)) "  .

	let l:fallback.ro   = nr2char(57506) "  .
	let l:fallback.lnum = nr2char(57505) "  .
	let l:fallback.cnum = nr2char(57507) "  .
	let l:fallback.ok   = nr2char(10003) " ✓ .
	let l:fallback.nok  = nr2char(10007) " ✗ .
	let l:fallback.time = nr2char(8986)  " ⌚. (use bold for emoji)
	let l:fallback.vcs  = nr2char(57504) "  .
	let l:fallback.git  = nr2char(177)   " ± .
	let l:fallback.hg   = nr2char(9791)  " ☿ .

	let l:ret = ""

	if exists("g:statusline_icons") && exists("g:statusline_icons['".a:name."']")
		let l:ret = g:statusline_icon[a:name]
	elseif exists("l:fallback['".a:name."']")
		let l:ret = l:fallback[a:name]
	endif
	return l:ret
endfunction " }}}

function! statusline#SL() " {{{
let l:rar		= statusline#get_icon("rar")
let l:lar		= statusline#get_icon("lar")
let l:rlar	= statusline#get_icon("rlar")
let l:llar	= statusline#get_icon("llar")


" TODO: make arrows (well, maybe all icons) configurable

let l:ro		= statusline#get_icon("ro")
let l:ln		= statusline#get_icon("lnum")
let l:cn		= statusline#get_icon("cnum")
let l:ok		= statusline#get_icon("ok")
let l:nok		= statusline#get_icon("nok")
let l:time	= statusline#get_icon("time")
let l:vcs		= statusline#get_icon("vcs")
let l:git		= statusline#get_icon("git")
let l:hg		= statusline#get_icon("hg")

	let l:mode = mode()

	if l:mode !=# g:last_mode
		let g:last_mode = l:mode
	endif
"        if l:mode ==# 'n'
"            hi User3 ctermfg=190
"        elseif l:mode ==# "i"
"            hi User2 ctermbg=231 ctermfg=24
"            hi User3 guibg=#0087af ctermbg=4
"            hi User4 ctermfg=117 ctermbg=24
"            hi User5 ctermfg=27 ctermbg=117
"            hi User6 ctermfg=117 ctermbg=4
"            hi User7 ctermbg=4
"        elseif l:mode ==# "R"
"            hi User2 ctermfg=255 ctermbg=160
"        elseif l:mode ==? "v" || l:mode ==# ""
"            hi User2 ctermfg=239 ctermbg=214
"        endif

	let l:mode_cg = "%#NormalMode# "
	let l:mode_ar_cg=" %#NormalModeArrow#"
	let l:mode_pst_ar_cg="%#NormalModeArrowPaste#"

	if l:mode ==# "n"
		if !exists("b:statusline_mode_replace")
			let l:mode="NORMAL"
		else
			let l:mode=b:statusline_mode_replace
		endif
	elseif l:mode ==# "no"
		let l:mode="N·OPER"
	elseif l:mode ==# "s"
		let l:mode="SELECT"
	elseif l:mode ==# "S"
		let l:mode="S·LINE"
	elseif l:mode ==# ""
		let l:mode="S·BLCK"
	elseif l:mode ==# "Rv"
		let l:mode="V·RPLCE"
	elseif l:mode ==# "c"
		let l:mode="COMMAND"
	elseif l:mode ==# "cv"
		let l:mode="VIM EX"
	elseif l:mode ==# "ce"
		let l:mode="EX"
	elseif l:mode ==# "R"
		let l:mode_cg="%#ReplaceMode# "
		let l:mode_ar_cg=" %#ReplaceModeArrow#"
		let l:mode_pst_ar_cg=" %#ReplaceModeArrowPaste#"
		let l:mode="REPLACE"
	elseif l:mode ==# "r"
		let l:mode="PROMPT"
	elseif l:mode ==# "rm"
		let l:mode="MORE"
	elseif l:mode ==# "r?"
		let l:mode="CONFIRM"
	elseif l:mode ==# "!"
		let l:mode="SHELL"
	elseif l:mode ==# "i"
		let l:mode_cg="%#InsertMode# "
		let l:mode_ar_cg=" %#InsertModeArrow#"
		let l:mode_pst_ar_cg=" %#InsertModeArrowPaste#"
		let l:mode="INSERT"
	elseif l:mode ==# "v"
		let l:mode_cg="%#VisualMode# "
		let l:mode_ar_cg=" %#VisualSelModeArrow#"
		let l:mode_pst_ar_cg=" %#VisualModeArrowPaste#"
		let l:mode="VISUAL"
		let l:mode.=" %#VisualModeArrow#".l:rar
		let l:mode.=" %#VisualSelMode#x"
	elseif l:mode ==# "V"
		let l:mode_cg="%#VisualMode# "
		let l:mode_ar_cg=" %#VisualSelModeArrow#"
		let l:mode_pst_ar_cg=" %#VisualModeArrowPaste#"
		let l:mode="V·LINE"
		let l:mode.=" %#VisualModeArrow#".l:rar
		let l:mode.=" %#VisualSelMode#x"
	elseif l:mode ==# ""
		let l:mode_cg="%#VisualMode# "
		let l:mode_ar_cg=" %#VisualSelModeArrow#"
		let l:mode_pst_ar_cg=" %#VisualModeArrowPaste#"
		let l:mode="V·BLCK"
		let l:mode.=" %#VisualModeArrow#".l:rar
		let l:mode.=" %#VisualSelMode#x"
	endif

	let l:vp = statusline#PercentPosition()
	let l:hp = virtcol(".")

	if l:hp < 10
		let l:hp = l:hp." "
	endif

	let l:ft =  statusline#filetype()

	let l:fn = statusline#get_filename()
"	if l:ft == "man"
"		let l:fn = substitute(l:fn,"\\~","","")
"	endif

"	let &titlestring = substitute(&titlestring,'expand("%:t")','statusline#get_filename()',"g")

	let l:vcs_branch = statusline#VCS_branch()

	let l:sl = ''

"if !(&buftype=="help" || (&buftype == "nofile" && filetype=="NvimTree"))
	let l:sl .= l:mode_cg.l:mode
	if &paste == 0
		let l:sl .= l:mode_ar_cg.l:rar
	else
		let l:sl .= l:mode_pst_ar_cg.l:rar
		let l:sl .= ' %#PasteMode#PASTE'
		let l:sl .= ' %#PasteArrow#'.l:rar
	endif
"endif
	let l:sl .= ' %<'

	if len(l:vcs_branch) > 0
		let l:sl .= '%#FileName#'. l:vcs .' '
		let l:sl .= '%#VCS_Icon#'.l:vcs_branch.' '. l:rlar
	endif

	let l:sl .= '%#isRO#%{&readonly?"'.l:ro.' ":""}'
	let l:sl .= '%#FileName#'

	let l:sl .= ' '.l:fn

	let l:sl .= '%#Modified#%{&modified?" '.l:nok.' ":" "}'
	let l:sl .= '%#Saved#%{(&modifiable&&!&modified)?" '.l:ok.' ":" "}'
	let l:sl .= '%#FileNameArrow#'.l:rar

	let l:sl .= '%*'
	let l:sl .= '%<'
	let l:sl .= '%#Panel#'
	let l:sl .= '%<'

	let l:sl .= '%='

	let l:sl .= ' %{&fileformat} '.l:llar.' %{&fileencoding} '.l:llar.' '.l:ft.' '

	let l:sl .= '%#ScrollArrow#'.l:lar

	if l:vp >= 90
		let l:scr_suf=100
	elseif l:vp >= 70 && l:vp < 90
		let l:scr_suf=90
	elseif l:vp >= 50 && l:vp < 70
		let l:scr_suf=70
	elseif l:vp >=30 && l:vp < 50
		let l:scr_suf=50
	elseif l:vp >= 10 && l:vp < 30
		let l:scr_suf=30
	elseif l:vp < 10
		let l:scr_suf=10
	endif

	if l:hp > 77
		let l:lin_suf=80
	elseif l:hp >= 73 && l:hp <= 77
		let l:lin_suf=70
	elseif l:hp >= 35 && l:hp < 73
		let l:lin_suf=30
	elseif l:hp < 35
		let l:lin_suf=1
	endif


	let l:sl .= '%#Scroll_'.l:scr_suf.'# '.l:vp.'%% '
	let l:sl .= '%#CurArrow#'.l:lar
	let l:sl .= '%#CurPos# '.l:ln.'%l'.l:cn.'%#LinePos_'.l:lin_suf.'#'.l:hp.'%*'

	return l:sl
endfunction " }}}


function! statusline#Up() abort "{{{
	let w = winnr()
	let l = winnr('$')
	let s = l == 1 && w == l ? [statusline#getline(0)] : [statusline#getline(0), statusline#getline(1)]
	for n in range(1, winnr('$'))
		call setwinvar(n, '&statusline', s[n!=w])
	endfor
endfunction "}}}

function! statusline#getline(inactive) " {{{
"  if a:inactive && !has_key(s:highlight, 'inactive')
"    call statusline#highlight('inactive')
"  endif
"  return s:line(0, a:inactive)
	return statusline#SL()
endfunction " }}}

""" 02.04.2021: Adding some code inspired by statusline, made by itchyny
""" TODO: continue porting from ↓ to ↑; TODO: tabline theming;


let s:_ = 1 " 1: not init, 2) disabled

function! statusline#update() abort " {{{
  if !s:skip() && s:_ && s:_ != 2
    call statusline#init()
    call statusline#colorscheme()
  endif
  if s:statusline.enable.statusline
    let w = winnr()
    let l = winnr('$')
    let s = l == 1 && w == l ? [statusline#statusline(0)] : [statusline#statusline(0), statusline#statusline(1)]
    for n in range(1, winnr('$'))
      call setwinvar(n, '&statusline', s[n!=w])
    endfor
  endif
endfunction " }}}

if exists('*win_gettype') " {{{
  function! s:skip() abort " Vim 8.2.0257 (00f3b4e007), 8.2.0991 (0fe937fd86), 8.2.0996 (40a019f157)
    return win_gettype() ==# 'popup' || win_gettype() ==# 'autocmd'
  endfunction
else
  function! s:skip() abort
    return &buftype ==# 'popup'
  endfunction
endif " }}}

function! statusline#update_disable() abort " {{{
  if s:statusline.enable.statusline
    call setwinvar(0, '&statusline', '')
  endif
endfunction " }}}

function! statusline#enable() abort " {{{
  let s:_ = 1
  call statusline#update()
  augroup statusline
    autocmd!
    autocmd WinEnter,BufEnter,BufDelete,SessionLoadPost,FileChangedShellPost * call statusline#update()
    if !has('patch-8.1.1715')
      autocmd FileType qf call statusline#update()
    endif
    autocmd SessionLoadPost * call statusline#highlight()
    autocmd ColorScheme * if !has('vim_starting') || expand('<amatch>') !=# 'macvim'
          \ | call statusline#update() | call statusline#highlight() | endif
  augroup END
  augroup statusline-disable
    autocmd!
  augroup END
  augroup! statusline-disable
endfunction " }}}

function! statusline#disable() abort " {{{
  let [&statusline, &tabline] = [get(s:, '_statusline', ''), get(s:, '_tabline', '')]
  for t in range(1, tabpagenr('$'))
    for n in range(1, tabpagewinnr(t, '$'))
      call settabwinvar(t, n, '&statusline', '')
    endfor
  endfor
  augroup statusline
    autocmd!
  augroup END
  augroup! statusline
  augroup statusline-disable
    autocmd!
    autocmd WinEnter * call statusline#update_disable()
  augroup END
  let s:_ = 2
endfunction " }}}

function! statusline#toggle() abort " {{{
  if exists('#statusline')
    call statusline#disable()
  else
    call statusline#enable()
  endif
endfunction " }}}

" {{{
let s:_statusline = {
      \   'active': {
      \     'left': [['mode', 'paste'], ['readonly', 'filename', 'modified']],
      \     'right': [['lineinfo'], ['percent'], ['fileformat', 'fileencoding', 'filetype']]
      \   },
      \   'inactive': {
      \     'left': [['filename']],
      \     'right': [['lineinfo'], ['percent']]
      \   },
      \   'tabline': {
      \     'left': [['tabs']],
      \     'right': [['close']]
      \   },
      \   'tab': {
      \     'active': ['tabnum', 'filename', 'modified'],
      \     'inactive': ['tabnum', 'filename', 'modified']
      \   },
      \   'component': {
      \     'mode': '%{statusline#mode()}',
      \     'absolutepath': '%F', 'relativepath': '%f', 'filename': '%t', 'modified': '%M', 'bufnum': '%n',
      \     'paste': '%{&paste?"PASTE":""}', 'readonly': '%R', 'charvalue': '%b', 'charvaluehex': '%B',
      \     'spell': '%{&spell?&spelllang:""}', 'fileencoding': '%{&fenc!=#""?&fenc:&enc}', 'fileformat': '%{&ff}',
      \     'filetype': '%{&ft!=#""?&ft:"no ft"}', 'percent': '%3p%%', 'percentwin': '%P',
      \     'lineinfo': '%3l:%-2c', 'line': '%l', 'column': '%c', 'close': '%999X X ', 'winnr': '%{winnr()}'
      \   },
      \   'component_visible_condition': {
      \     'modified': '&modified||!&modifiable', 'readonly': '&readonly', 'paste': '&paste', 'spell': '&spell'
      \   },
      \   'component_function': {},
      \   'component_function_visible_condition': {},
      \   'component_expand': {
      \     'tabs': 'statusline#tabs'
      \   },
      \   'component_type': {
      \     'tabs': 'tabsel', 'close': 'raw'
      \   },
      \   'component_raw': {},
      \   'tab_component': {},
      \   'tab_component_function': {
      \     'filename': 'statusline#tab#filename', 'modified': 'statusline#tab#modified',
      \     'readonly': 'statusline#tab#readonly', 'tabnum': 'statusline#tab#tabnum'
      \   },
      \   'colorscheme': 'default',
      \   'mode_map': {
      \     'n': 'NORMAL', 'i': 'INSERT', 'R': 'REPLACE', 'v': 'VISUAL', 'V': 'V-LINE', "\<C-v>": 'V-BLOCK',
      \     'c': 'COMMAND', 's': 'SELECT', 'S': 'S-LINE', "\<C-s>": 'S-BLOCK', 't': 'TERMINAL'
      \   },
      \   'separator': { 'left': '', 'right': '' },
      \   'subseparator': { 'left': '|', 'right': '|' },
      \   'tabline_separator': {},
      \   'tabline_subseparator': {},
      \   'enable': { 'statusline': 1, 'tabline': 1 },
      \   '_mode_': {
      \     'n': 'normal', 'i': 'insert', 'R': 'replace', 'v': 'visual', 'V': 'visual', "\<C-v>": 'visual',
      \     'c': 'command', 's': 'select', 'S': 'select', "\<C-s>": 'select', 't': 'terminal'
      \   },
      \   'mode_fallback': { 'replace': 'insert', 'terminal': 'insert', 'select': 'visual' },
      \   'palette': {},
      \ }
" }}}

function! statusline#init() abort " {{{
  let s:statusline = deepcopy(get(g:, 'statusline', {}))
  for [key, value] in items(s:_statusline)
    if type(value) == 4
      if !has_key(s:statusline, key)
        let s:statusline[key] = {}
      endif
      call extend(s:statusline[key], value, 'keep')
    elseif !has_key(s:statusline, key)
      let s:statusline[key] = value
    endif
    unlet value
  endfor
  call extend(s:statusline.tabline_separator, s:statusline.separator, 'keep')
  call extend(s:statusline.tabline_subseparator, s:statusline.subseparator, 'keep')
  let s:statusline.tabline_configured = has_key(get(get(g:, 'statusline', {}), 'component_expand', {}), 'tabs')
  for components in deepcopy(s:statusline.tabline.left + s:statusline.tabline.right)
    if len(filter(components, 'v:val !=# "tabs" && v:val !=# "close"')) > 0
      let s:statusline.tabline_configured = 1
      break
    endif
  endfor
  if !exists('s:_statusline')
    let s:_statusline = &statusline
  endif
  if !exists('s:_tabline')
    let s:_tabline = &tabline
  endif
  if s:statusline.enable.tabline
    set tabline=%!statusline#tabline()
  else
    let &tabline = get(s:, '_tabline', '')
  endif
  for f in values(s:statusline.component_function)
    silent! call call(f, [])
  endfor
  for f in values(s:statusline.tab_component_function)
    silent! call call(f, [1])
  endfor
  let s:mode = ''
endfunction " }}}

function! statusline#colorscheme() abort " {{{
  try
    let s:statusline.palette = g:statusline#colorscheme#{s:statusline.colorscheme}#palette
  catch
    call statusline#error('Could not load colorscheme ' . s:statusline.colorscheme . '.')
    let s:statusline.colorscheme = 'default'
    let s:statusline.palette = g:statusline#colorscheme#{s:statusline.colorscheme}#palette
  finally
    if has('win32') && !has('gui_running') && &t_Co < 256
      call statusline#colortable#gui2cui_palette(s:statusline.palette)
    endif
    let s:highlight = {}
    call statusline#highlight('normal')
    call statusline#link()
    let s:_ = 0
  endtry
endfunction " }}}

function! statusline#palette() abort
  return s:statusline.palette
endfunction

function! statusline#mode() abort
  return get(s:statusline.mode_map, mode(), '')
endfunction

let s:mode = ''
function! statusline#link(...) abort " {{{
  let mode = get(s:statusline._mode_, a:0 ? a:1 : mode(), 'normal')
  if s:mode ==# mode
    return ''
  endif
  let s:mode = mode
  if !has_key(s:highlight, mode)
    call statusline#highlight(mode)
  endif
  let types = map(s:uniq(sort(filter(values(s:statusline.component_type), 'v:val !=# "raw"'))), '[v:val, 1]')
  for [p, l] in [['Left', len(s:statusline.active.left)], ['Right', len(s:statusline.active.right)]]
    for [i, t] in map(range(0, l), '[v:val, 0]') + types
      if i != l
        exec printf('hi link statusline%s_active_%s statusline%s_%s_%s', p, i, p, mode, i)
      endif
      for [j, s] in map(range(0, l), '[v:val, 0]') + types
        if i + 1 == j || t || s && i != l
          exec printf('hi link statusline%s_active_%s_%s statusline%s_%s_%s_%s', p, i, j, p, mode, i, j)
        endif
      endfor
    endfor
  endfor
  exec printf('hi link statuslineMiddle_active statuslineMiddle_%s', mode)
  return ''
endfunction " }}}

function! s:term(p) abort
  return get(a:p, 4) !=# '' ? 'term='.a:p[4].' cterm='.a:p[4].' gui='.a:p[4] : ''
endfunction

if exists('*uniq') " {{{
  let s:uniq = function('uniq')
else
  function! s:uniq(xs) abort
    let i = len(a:xs) - 1
    while i > 0
      if a:xs[i] ==# a:xs[i - 1]
        call remove(a:xs, i)
      endif
      let i -= 1
    endwhile
    return a:xs
  endfunction
endif " }}}

function! statusline#highlight(...) abort " {{{
  let [c, f] = [s:statusline.palette, s:statusline.mode_fallback]
  let [s:statusline.llen, s:statusline.rlen] = [len(c.normal.left), len(c.normal.right)]
  let [s:statusline.tab_llen, s:statusline.tab_rlen] = [len(has_key(get(c, 'tabline', {}), 'left') ? c.tabline.left : c.normal.left), len(has_key(get(c, 'tabline', {}), 'right') ? c.tabline.right : c.normal.right)]
  let types = map(s:uniq(sort(filter(values(s:statusline.component_type), 'v:val !=# "raw"'))), '[v:val, 1]')
  let modes = a:0 ? [a:1] : extend(['normal', 'insert', 'replace', 'visual', 'inactive', 'command', 'select', 'tabline'], exists(':terminal') == 2 ? ['terminal'] : [])
  for mode in modes
    let s:highlight[mode] = 1
    let d = has_key(c, mode) ? mode : has_key(f, mode) && has_key(c, f[mode]) ? f[mode] : 'normal'
    let left = d ==# 'tabline' ? s:statusline.tabline.left : d ==# 'inactive' ? s:statusline.inactive.left : s:statusline.active.left
    let right = d ==# 'tabline' ? s:statusline.tabline.right : d ==# 'inactive' ? s:statusline.inactive.right : s:statusline.active.right
    let ls = has_key(get(c, d, {}), 'left') ? c[d].left : has_key(f, d) && has_key(get(c, f[d], {}), 'left') ? c[f[d]].left : c.normal.left
    let ms = has_key(get(c, d, {}), 'middle') ? c[d].middle[0] : has_key(f, d) && has_key(get(c, f[d], {}), 'middle') ? c[f[d]].middle[0] : c.normal.middle[0]
    let rs = has_key(get(c, d, {}), 'right') ? c[d].right : has_key(f, d) && has_key(get(c, f[d], {}), 'right') ? c[f[d]].right : c.normal.right
    for [p, l, zs] in [['Left', len(left), ls], ['Right', len(right), rs]]
      for [i, t] in map(range(0, l), '[v:val, 0]') + types
        if i < l || i < 1
          let r = t ? (has_key(get(c, d, []), i) ? c[d][i][0] : has_key(get(c, 'tabline', {}), i) ? c.tabline[i][0] : get(c.normal, i, zs)[0]) : get(zs, i, ms)
          exec printf('hi statusline%s_%s_%s guifg=%s guibg=%s ctermfg=%s ctermbg=%s %s', p, mode, i, r[0], r[1], r[2], r[3], s:term(r))
        endif
        for [j, s] in map(range(0, l), '[v:val, 0]') + types
          if i + 1 == j || t || s && i != l
            let q = s ? (has_key(get(c, d, []), j) ? c[d][j][0] : has_key(get(c, 'tabline', {}), j) ? c.tabline[j][0] : get(c.normal, j, zs)[0]) : (j != l ? get(zs, j, ms) :ms)
            exec printf('hi statusline%s_%s_%s_%s guifg=%s guibg=%s ctermfg=%s ctermbg=%s', p, mode, i, j, r[1], q[1], r[3], q[3])
          endif
        endfor
      endfor
    endfor
    exec printf('hi statuslineMiddle_%s guifg=%s guibg=%s ctermfg=%s ctermbg=%s %s', mode, ms[0], ms[1], ms[2], ms[3], s:term(ms))
  endfor
  if !a:0 | let s:mode = '' | endif
endfunction " }}}

function! s:subseparator(components, subseparator, expanded) abort " {{{
  let [a, c, f, v, u] = [a:components, s:statusline.component, s:statusline.component_function, s:statusline.component_visible_condition, s:statusline.component_function_visible_condition]
  let xs = map(range(len(a:components)), 'a:expanded[v:val] ? "1" :
        \ has_key(f, a[v:val]) ? (has_key(u, a[v:val]) ? "(".u[a[v:val]].")" : (exists("*".f[a[v:val]]) ? "" : "exists(\"*".f[a[v:val]]."\")&&").f[a[v:val]]."()!=#\"\"") :
        \ has_key(v, a[v:val]) ? "(".v[a[v:val]].")" : has_key(c, a[v:val]) ? "1" : "0"')
  return '%{' . (xs[0] ==# '1' || xs[0] ==# '(1)' ? '' : xs[0] . '&&(') . join(xs[1:], '||') . (xs[0] ==# '1' || xs[0] ==# '(1)' ? '' : ')') . '?"' . a:subseparator . '":""}'
endfunction " }}}

function! statusline#concatenate(xs, right) abort
  let separator = a:right ? s:statusline.subseparator.right : s:statusline.subseparator.left
  return join(filter(copy(a:xs), 'v:val !=# ""'), ' ' . separator . ' ')
endfunction

function! statusline#statusline(inactive) abort " {{{
  if a:inactive && !has_key(s:highlight, 'inactive')
    call statusline#highlight('inactive')
  endif
  return s:line(0, a:inactive)
endfunction " }}}

function! s:normalize(result) abort " {{{
  if type(a:result) == 3
    return map(a:result, 'type(v:val) == 1 ? v:val : string(v:val)')
  elseif type(a:result) == 1
    return [a:result]
  else
    return [string(a:result)]
  endif
endfunction " }}}

function! s:evaluate_expand(component) abort " {{{
  try
    let result = eval(a:component . '()')
    if type(result) == 1 && result ==# ''
      return []
    endif
  catch
    return []
  endtry
  return map(type(result) == 3 ? (result + [[], [], []])[:2] : [[], [result], []], 'filter(s:normalize(v:val), "v:val !=# ''''")')
endfunction " }}}

function! s:convert(name, index) abort " {{{
  if !has_key(s:statusline.component_expand, a:name)
    return [[[a:name], 0, a:index, a:index]]
  else
    let type = get(s:statusline.component_type, a:name, a:index)
    let is_raw = get(s:statusline.component_raw, a:name) || type ==# 'raw'
    return filter(map(s:evaluate_expand(s:statusline.component_expand[a:name]),
          \ '[v:val, 1 + ' . is_raw . ', v:key == 1 && ' . (type !=# 'raw') . ' ? "' . type . '" : "' . a:index . '", "' . a:index . '"]'), 'v:val[0] != []')
  endif
endfunction " }}}

function! s:expand(components) abort " {{{
  let components = []
  let expanded = []
  let indices = []
  let prevtype = ''
  let previndex = -1
  let xs = []
  call map(deepcopy(a:components), 'map(v:val, "extend(xs, s:convert(v:val, ''" . v:key . "''))")')
  for [component, expand, type, index] in xs
    if prevtype !=# type
      for i in range(previndex + 1, max([previndex, index - 1]))
        call add(indices, string(i))
        call add(components, [])
        call add(expanded, [])
      endfor
      call add(indices, type)
      call add(components, [])
      call add(expanded, [])
    endif
    call extend(components[-1], component)
    call extend(expanded[-1], repeat([expand], len(component)))
    let prevtype = type
    let previndex = index
  endfor
  for i in range(previndex + 1, max([previndex, len(a:components) - 1]))
    call add(indices, string(i))
    call add(components, [])
    call add(expanded, [])
  endfor
  call add(indices, string(len(a:components)))
  return [components, expanded, indices]
endfunction " }}}

function! s:func(name) abort
  return exists('*' . a:name) ? '%{' . a:name . '()}' : '%{exists("*' . a:name . '")?' . a:name . '():""}'
endfunction

function! s:line(tabline, inactive) abort " {{{
  let _ = a:tabline ? '' : '%{statusline#link()}'
  if s:statusline.palette == {}
    call statusline#colorscheme()
  endif
  let [l, r] = a:tabline ? [s:statusline.tab_llen, s:statusline.tab_rlen] : [s:statusline.llen, s:statusline.rlen]
  let [p, s] = a:tabline ? [s:statusline.tabline_separator, s:statusline.tabline_subseparator] : [s:statusline.separator, s:statusline.subseparator]
  let [c, f, t, w] = [s:statusline.component, s:statusline.component_function, s:statusline.component_type, s:statusline.component_raw]
  let mode = a:tabline ? 'tabline' : a:inactive ? 'inactive' : 'active'
  let ls = has_key(s:statusline, mode) ? s:statusline[mode].left : s:statusline.active.left
  let [lc, le, li] = s:expand(ls)
  let rs = has_key(s:statusline, mode) ? s:statusline[mode].right : s:statusline.active.right
  let [rc, re, ri] = s:expand(rs)
  for i in range(len(lc))
    let _ .= '%#statuslineLeft_' . mode . '_' . li[i] . '#'
    for j in range(len(lc[i]))
      let x = le[i][j] ? lc[i][j] : has_key(f, lc[i][j]) ? s:func(f[lc[i][j]]) : get(c, lc[i][j], '')
      let _ .= has_key(t, lc[i][j]) && t[lc[i][j]] ==# 'raw' || get(w, lc[i][j]) || le[i][j] ==# 2 || x ==# '' ? x : '%( ' . x . ' %)'
      if j < len(lc[i]) - 1 && s.left !=# ''
        let _ .= s:subseparator(lc[i][(j):], s.left, le[i][(j):])
      endif
    endfor
    let _ .= '%#statuslineLeft_' . mode . '_' . li[i] . '_' . li[i + 1] . '#'
    let _ .= i < l + len(lc) - len(ls) && li[i] < l || li[i] != li[i + 1] ? p.left : len(lc[i]) ? s.left : ''
  endfor
  let _ .= '%#statuslineMiddle_' . mode . '#%='
  for i in range(len(rc) - 1, 0, -1)
    let _ .= '%#statuslineRight_' . mode . '_' . ri[i] . '_' . ri[i + 1] . '#'
    let _ .= i < r + len(rc) - len(rs) && ri[i] < r || ri[i] != ri[i + 1] ? p.right : len(rc[i]) ? s.right : ''
    let _ .= '%#statuslineRight_' . mode . '_' . ri[i] . '#'
    for j in range(len(rc[i]))
      let x = re[i][j] ? rc[i][j] : has_key(f, rc[i][j]) ? s:func(f[rc[i][j]]) : get(c, rc[i][j], '')
      let _ .= has_key(t, rc[i][j]) && t[rc[i][j]] ==# 'raw' || get(w, rc[i][j]) || re[i][j] ==# 2 || x ==# '' ? x : '%( ' . x . ' %)'
      if j < len(rc[i]) - 1 && s.right !=# ''
        let _ .= s:subseparator(rc[i][(j):], s.right, re[i][(j):])
      endif
    endfor
  endfor
  return _
endfunction " }}}

" {{{
let s:tabnr = -1
let s:tabcnt = -1
let s:columns = -1
let s:tabline = ''
function! statusline#tabline() abort " {{{
  if !has_key(s:highlight, 'tabline')
    call statusline#highlight('tabline')
  endif
  if s:statusline.tabline_configured || s:tabnr != tabpagenr() || s:tabcnt != tabpagenr('$') || s:columns != &columns
    let s:tabnr = tabpagenr()
    let s:tabcnt = tabpagenr('$')
    let s:columns = &columns
    let s:tabline = s:line(1, 0)
  endif
  return s:tabline
endfunction " }}}
" }}}

function! statusline#tabs() abort " {{{
  let [x, y, z] = [[], [], []]
  let nr = tabpagenr()
  let cnt = tabpagenr('$')
  for i in range(1, cnt)
    call add(i < nr ? x : i == nr ? y : z, (i > nr + 3 ? '%<' : '') . '%' . i . 'T%{statusline#onetab(' . i . ',' . (i == nr) . ')}' . (i == cnt ? '%T' : ''))
  endfor
  let abbr = '...'
  let n = min([max([&columns / 40, 2]), 8])
  if len(x) > n && len(z) > n
    let x = extend(add(x[:n/2-1], abbr), x[-(n+1)/2:])
    let z = extend(add(z[:(n+1)/2-1], abbr), z[-n/2:])
  elseif len(x) + len(z) > 2 * n
    if len(x) > n
      let x = extend(add(x[:(2*n-len(z))/2-1], abbr), x[-(2*n-len(z)+1)/2:])
    elseif len(z) > n
      let z = extend(add(z[:(2*n-len(x)+1)/2-1], abbr), z[-(2*n-len(x))/2:])
    endif
  endif
  return [x, y, z]
endfunction " }}}

function! statusline#onetab(n, active) abort " {{{
  let _ = []
  for name in a:active ? s:statusline.tab.active : s:statusline.tab.inactive
    if has_key(s:statusline.tab_component_function, name)
      call add(_, call(s:statusline.tab_component_function[name], [a:n]))
    else
      call add(_, get(s:statusline.tab_component, name, ''))
    endif
  endfor
  return join(filter(_, 'v:val !=# ""'), ' ')
endfunction " }}}

function! statusline#error(msg) abort " {{{
  echohl ErrorMsg
  echomsg 'statusline.vim: '.a:msg
  echohl None
endfunction " }}}

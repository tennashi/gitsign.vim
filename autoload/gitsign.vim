let s:repo_root = ''
let s:signs = {}

let s:path_sep = fnamemodify('.', ':p')[-1:]

function! gitsign#enable() abort
  try
    call s:initialize()
  catch
    return
  endtry
  call s:update_signs()
endfunction

function! gitsign#disable() abort
  call s:disable_events()
  call gitsign#sign#clear(bufnr())
endfunction

function! s:initialize() abort
  if !executable('git')
    throw 'git is not executable'
  endif

  let s:repo_root = systemlist('git rev-parse --show-toplevel')[0]
  if v:shell_error
    throw 'git: ' . s:repo_root
  endif
  if s:repo_root ==# ''
    throw getcwd() . ' is not a git repository'
  endif

  call gitsign#highlight#initialize()
  call gitsign#sign#initialize()
  call s:enable_events()
endfunction

function! s:enable_events() abort
  augroup GitsignAutoUpdate
    autocmd!
    autocmd User gitsign_sign_updated call s:apply_signs()
    autocmd BufRead,BufNewFile,BufWritePost * call s:update_signs()
  augroup END
endfunction

function! s:disable_events() abort
  autocmd! GitsignAutoUpdate
endfunction

function! s:apply_signs() abort
  let l:bufnrs = tabpagebuflist()
  for l:bufnr in l:bufnrs
    call gitsign#sign#clear(l:bufnr)
    call gitsign#sign#apply(l:bufnr, s:signs)
  endfor
endfunction

function! s:update_signs() abort
  let l:bufnrs = tabpagebuflist()
  for l:bufnr in l:bufnrs
    let l:fname = fnamemodify(bufname(l:bufnr), ':p')
    if has_key(s:signs, l:fname)
      let s:signs[fnamemodify(bufname(l:bufnr), ':p')] = {}
    endif
  endfor
  call gitsign#diff#update()
endfunction

function! gitsign#set_signs(signs) abort
  let s:signs = a:signs
endfunction

function! gitsign#error_msg(msg) abort
  echohl ErrorMsg
  redraw
  echom '[gitsign] ' . a:msg
  echohl None
endfunction

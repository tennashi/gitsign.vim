let s:repo_root = ''
let s:signs = {}

let s:path_sep = fnamemodify('.', ':p')[-1:]

function! gitsign#initialize() abort
  if !g:gitsign#enable
    return
  endif

  if !executable('git')
    return
  endif

  let s:repo_root = systemlist('git rev-parse --show-toplevel')[0]
  if s:repo_root ==# ''
    return
  endif

  call gitsign#highlight#initialize()
  call gitsign#sign#initialize()
  call gitsign#enable()
endfunction

function! gitsign#enable() abort
  augroup GitsignAutoUpdate
    autocmd!
    autocmd User gitsign_sign_updated call s:apply_signs()
    autocmd BufWritePost * call s:update_signs()
  augroup END
  call s:update_signs()
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

function! gitsign#disable() abort
  augroup GitsignAutoUpdate
    autocmd!
  augroup END
  call gitsign#sign#clear(bufnr())
endfunction

function! gitsign#add_sign(fname, hunk) abort
  let l:fname = s:repo_root . s:path_sep . a:fname
  if !has_key(s:signs, l:fname)
    let s:signs[l:fname] = {}
  endif

  let l:sign = gitsign#diff#to_sign(a:hunk)
  call extend(s:signs[l:fname], l:sign)
endfunction


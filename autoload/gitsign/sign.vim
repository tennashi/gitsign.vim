echom 'loaded autoload/gitsign/sign.vim'

let g:gitsign#sign#add_mark = get(g:, 'gitsign#sign#add_mark', '+')
let g:gitsign#sign#delete_mark = get(g:, 'gitsign#sign#delete_mark', '_')
let g:gitsign#sign#delete_first_line_mark = get(g:, 'gitsign#sign#delete_first_line_mark', '^')
let g:gitsign#sign#change_mark = get(g:, 'gitsign#sign#change_mark', '~')
let s:sign_defs = [
\ {
\   'name': 'GitsignAdd',
\   'text': g:gitsign#sign#add_mark,
\   'linehl': 'GitsignAdd',
\   'texthl': 'GitsignAddMark',
\ },
\ {
\   'name': 'GitsignDelete',
\   'text': g:gitsign#sign#delete_mark,
\   'linehl': 'GitsignDelete',
\   'texthl': 'GitsignDeleteMark',
\ },
\ {
\   'name': 'GitsignDeleteFirstLine',
\   'text': g:gitsign#sign#delete_first_line_mark,
\   'linehl': 'GitsignDelete',
\   'texthl': 'GitsignDeleteMark',
\ },
\ {
\   'name': 'GitsignChange',
\   'text': g:gitsign#sign#change_mark,
\   'linehl': 'GitsignChange',
\   'texthl': 'GitsignChangeMark',
\ },
\]

function! gitsign#sign#initialize() abort
  call sign_define(s:sign_defs)
endfunction

function! gitsign#sign#apply(bufnr, signs) abort
  let l:bufname = fnamemodify(bufname(a:bufnr), ':p')
  if has_key(a:signs, l:bufname)
    call map(copy(a:signs[l:bufname]), { lnum, sign ->
    \ sign_place(0, 'gitsign', sign, l:bufname, { 'lnum': lnum })
    \})
  endif
endfunction

function! gitsign#sign#clear(bufnr) abort
  call sign_unplace('gitsign', { 'buffer': a:bufnr })
endfunction

let s:line_initialized = v:false
let s:mark_initialized = v:false

let g:gitsign#highlight#enable_lines = get(g:, 'gitsign#highlight#enable_lines', 1)
let g:gitsign#highlight#enable_marks = get(g:, 'gitsign#highlight#enable_marks', 1)

function! gitsign#highlight#initialize() abort
  if g:gitsign#highlight#enable_lines && !s:line_initialized
    call s:initialize_line()
    let s:line_initialized = v:true
  endif
  if g:gitsign#highlight#enable_marks && !s:mark_initialized
    call s:initialize_mark()
    let s:mark_initialized = v:true
  endif
endfunction

function! s:initialize_line() abort
  highlight default link GitsignAdd DiffAdd
  highlight GitsignDelete gui=undercurl guisp=Red
  highlight default link GitsignChange DiffChange
endfunction

function! s:initialize_mark() abort
  highlight GitsignAddMark ctermfg=2 guifg=Green
  highlight GitsignDeleteMark ctermfg=4 guifg=Red
  highlight GitsignChangeMark ctermfg=6 guifg=Yellow
endfunction

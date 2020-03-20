function! gitsign#highlight#initialize() abort
  highlight default link GitsignAdd DiffAdd
  highlight GitsignDelete gui=undercurl guisp=Red
  highlight default link GitsignChange DiffChange
  highlight GitsignAddMark ctermfg=2 guifg=Green
  highlight GitsignDeleteMark ctermfg=4 guifg=Red
  highlight GitsignChangeMark ctermfg=6 guifg=Yellow
endfunction

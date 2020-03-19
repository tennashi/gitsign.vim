scriptencoding utf-8
if exists('g:loaded_gitsign') && g:loaded_gitsign
  finish
endif
let g:loaded_gitsign = 1

command! GitsignEnable call gitsign#enable()
command! GitsignDisable call gitsign#disable()

nnoremap <Plug>(gitsign-enable) :<C-u>GitsignEnable<CR>
nnoremap <Plug>(gitsign-disable) :<C-u>GitsignDisable<CR>

let g:gitsign#enable = get(g:, 'gitsign#enable', 1)

augroup Gitsign
  autocmd!
  autocmd VimEnter * call gitsign#initialize()
augroup END

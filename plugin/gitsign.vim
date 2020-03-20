scriptencoding utf-8
if exists('g:loaded_gitsign') && g:loaded_gitsign
  finish
endif
let g:loaded_gitsign = 1

command! GitsignEnable call gitsign#enable()
command! GitsignDisable call gitsign#disable()

nnoremap <Plug>(gitsign-enable) :<C-u>GitsignEnable<CR>
nnoremap <Plug>(gitsign-disable) :<C-u>GitsignDisable<CR>

let g:gitsign#auto_enable = get(g:, 'gitsign#auto_enable', 1)

if g:gitsign#auto_enable
  augroup GitsignAutoEnable
    autocmd!
    autocmd VimEnter * call gitsign#enable()
  augroup END
endif

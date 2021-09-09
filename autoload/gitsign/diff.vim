function! gitsign#diff#update() abort
  call denops#request_async('gitsign', 'getSigns', [], function('s:on_success'), function('s:on_failure'))
endfunction

function! s:on_failure(...)
  call gitsign#error_msg(a:000)
endfunction

function! s:on_success(...)
  call gitsign#set_signs(a:1)
  doautocmd <nomodeline> User gitsign_sign_updated
endfunction

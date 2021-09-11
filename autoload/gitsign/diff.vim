function! gitsign#diff#update() abort
  call denops#request_async('gitsign', 'getSigns', [], function('s:on_success'), function('s:on_failure'))
endfunction

function! s:on_failure(...)
  if type(a:1) ==# v:t_string
    call gitsign#error_msg(a:1)
    return
  endif

  call gitsign#error_msg(json_encode(a:1))
endfunction

function! s:on_success(...)
  call gitsign#set_signs(a:1)
  doautocmd <nomodeline> User gitsign_sign_updated
endfunction

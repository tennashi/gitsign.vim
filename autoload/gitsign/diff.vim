let s:diff_cmd = ['git', '-c', 'diff.noprefix', 'diff', '--no-ext-diff', '--no-color', '-U0']
let s:hunk_re = '^@@\v -(\d+),?(\d*) \+(\d+),?(\d*)'
let s:filename_re = '^+++\v (.*)'
let s:processing_file = ''

function! gitsign#diff#update() abort
  call job_start(s:diff_cmd, {
  \ 'out_cb': function('s:on_stdout'),
  \ 'exit_cb': function('s:on_exit'),
  \})
endfunction

function! s:on_stdout(_ch, msg) abort
  let l:matches = matchlist(a:msg, s:filename_re)
  if len(l:matches) !=# 0
    call s:process_fname_line(l:matches)
    return
  endif

  let l:matches = matchlist(a:msg, s:hunk_re)
  if len(l:matches) !=# 0
    call s:process_hunk_line(l:matches)
    return
  endif
endfunction

function! s:on_exit(_job, _status) abort
  doautocmd <nomodeline> User gitsign_sign_updated
endfunction

function! s:process_fname_line(matches) abort
  let s:processing_file = a:matches[1]
endfunction

function! s:process_hunk_line(matches) abort
  let l:hunk = map(a:matches[1:4],
  \ { _, val -> val ==# ''? 1 : str2nr(val) }
  \)

  call gitsign#add_sign(s:processing_file, {
  \ 'del_start': l:hunk[0],
  \ 'del_range': l:hunk[1],
  \ 'add_start': l:hunk[2],
  \ 'add_range': l:hunk[3],
  \})
endfunction

function! gitsign#diff#to_sign(hunk) abort
  let l:signs = {}
  let l:lnum = a:hunk['add_start']

  if l:lnum == 0
    let l:signs[1] = 'GitsignDeleteFirstLine'
    return l:signs
  endif

  if a:hunk['add_range'] == 0
    let l:signs[l:lnum] = 'GitsignDelete'
    return l:signs
  endif

  if a:hunk['del_range'] == 0
    while l:lnum < a:hunk['add_start'] + a:hunk['add_range']
      let l:signs[l:lnum] = 'GitsignAdd'
      let l:lnum += 1
    endwhile
    return l:signs
  endif

  while l:lnum < a:hunk['add_start'] + a:hunk['add_range']
    let l:signs[l:lnum] = 'GitsignChange'
    let l:lnum += 1
  endwhile
  return l:signs
endfunction

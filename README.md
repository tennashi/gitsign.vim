# gitsign.vim
gitsign is Vim plugin to show `git diff` in the sign column.
This is a study plugin based on [airblade/vim-gitgutter](https://github.com/airblade/vim-gitgutter)

## Install
* [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'tennashi/gitsign.vim'
```

* [dein.vim](https://github.com/Shougo/dein.vim)

```vim
call dein#add('tennashi/gitsign.vim')
```

* [volt](https://github.com/vim-volt/volt)

```bash
$ volt get tennashi/gitsign.vim
```

## Commands
| Command | Description |
| ------- | ----------- |
| `:GitsignEnable` | Enable gitsign |
| `:GitsignDisable` | Disable gitsign |

## Options
### Auto enable when vim starts
```vim
let g:gitsign#auto_enable = 1
```

### Highlight lines
```vim
let g:gitsign#highlight#enable_lines = 1
```

### Highlight marks
```vim
let g:gitsign#highlight#enable_marks = 1
```

### Edit the `git diff` marks
```vim
let g:gitsign#sign#delete_mark = '󿕂'
let g:gitsign#sign#delete_first_line_mark = '󿕛'
let g:gitsign#sign#add_mark = '󿕓'
let g:gitsign#sign#change_mark = '󿕓'
```

## License
MIT

# Vim Terraform Completion with Linter - [Demos](./DEMO.md)

## [Changelog](./CHANGELOG.md)

[![Build Status](https://travis-ci.org/juliosueiras/vim-terraform-completion.svg?branch=master)](https://travis-ci.org/juliosueiras/vim-terraform-completion)
[![Join the chat at https://gitter.im/juliosueiras/vim-terraform-completion](https://badges.gitter.im/juliosueiras/vim-terraform-completion.svg)](https://gitter.im/juliosueiras/vim-terraform-completion?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

- [Vim Terraform Completion with Linter - Demos](#vim-terraform-completion-with-linter---demosdemomd)
  * [Changelog](#changelog)
  * [Dependencies](#dependencies)
  * [Installation](#installation)
    + [NeoBundle](#neobundle)
    + [Vim-Plug](#vim-plug)
    + [Minimal Configuration](#minimal-configuration)
  * [Extra](#extra)
    + [Tagbar Config for Terraform](#tagbar-config-for-terraform)
  * [General Todo](#general-todo)
  * [Todo for Terraform completion](#todo-for-terraform-completion)
  * [Todo for HCL](#todo-for-hcl)
  * [Todo for Improvement](#todo-for-improvement)
  * [Contributors](#contributors)%

**A very early prototype**

## Dependencies

- [vim-terraform](https://github.com/hashivim/vim-terraform)
- [vim-syntastic](https://github.com/vim-syntastic/syntastic)

## Installation

**Require `+ruby` or `+ruby/dyn` for vim**

### NeoBundle
```vim
NeoBundle 'hashivim/vim-terraform'
NeoBundle 'vim-syntastic/syntastic'
NeoBundle 'juliosueiras/vim-terraform-completion'
```

### Vim-Plug
```vim
Plug 'hashivim/vim-terraform'
Plug 'vim-syntastic/syntastic'
Plug 'juliosueiras/vim-terraform-completion'
```

### Minimal Configuration
```vim
" Minimal Configuration
set nocompatible
syntax on
filetype plugin indent on

call plug#begin('~/.vim/plugged')

" (Optinal for Tag Sidebar
" Plug 'majutsushi/tagbar'

Plug 'hashivim/vim-terraform'
Plug 'vim-syntastic/syntastic'
Plug 'juliosueiras/vim-terraform-completion'
call plug#end()

" Syntastic Config
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" (Optional)Remove Info(Preview) window
set completeopt-=preview

" (Optional)Hide Info(Preview) window after completions
autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif

" (Optional) Enable terraform plan to be include in filter
let g:syntastic_terraform_tf_filter_plan = 1

" (Optional, If terraform exist is Default to the version of it, or else Defalt to 0.9.4) Version to complete from
let g:terraformcomplete_version = '0.9.4'
```

## Extra
### Tagbar Config for Terraform

[![asciicast](https://asciinema.org/a/32w8wselqmrwk1ce8mj5k2rut.png)](https://asciinema.org/a/32w8wselqmrwk1ce8mj5k2rut)

This should inside `~/.ctags`
```
--langdef=terraform
--langmap=terraform:.tf.tfvars
--regex-terraform=/^\s*resource\s*"([^"]*)"\s*"([^"]*)"/\1.\2/r,Resource/
--regex-terraform=/^\s*data\s*"([^"]*)"\s*"([^"]*)"/\1.\2/d,Data/
--regex-terraform=/^\s*variable\s*"([^"]*)"/\1/v,Variable/
--regex-terraform=/^\s*provider\s*"([^"]*)"/\1/p,Provider/
--regex-terraform=/^\s*module\s*"([^"]*)"/\1/m,Module/
--regex-terraform=/^\s*output\s*"([^"]*)"/\1/o,Output/
--regex-terraform=/^([a-z0-9_]+)\s*=/\1/f,TFVar/
```

This config go inside `~/.vimrc`
```vim
let g:tagbar_type_terraform = {
	\ 'ctagstype' : 'terraform',
	\ 'kinds' : [
		\ 'r:Resources',
		\ 'd:Datas',
		\ 'v:Variables',
		\ 'p:Providers',
		\ 'o:Outputs',
		\ 'm:Modules',
		\ 'f:TFVars'
	\ ],
	\ 'sort' : 1
\ }
```

## General Todo
- [ ] Move regex code to a json(for easier extension)
- [x] Test from zero to useful setup using Docker
- [x] Jump Reference (Ctrl-L first time to jump to resource definition, second time
    on the same line to jump back)
- [x] Provide config and example
- [x] Integrate Basic `terraform validate` and `tflint` into Synstatic
- [x] Added a custom linter for providing a better error
- [ ] (WIP) Full Snippets
**NOTE:** enabling deep check for tflint can be a bit slow

[Demo of the linter](https://asciinema.org/a/118441)

## Todo for Terraform completion
- [x] Version-based Completion
- [ ] Provider
- [ ] (WIP)Module
- [x] Data
- [x] Resource(with Provider)
- [x] Parameter
- [x] Adding Info to Argument and Attribute(Type not including ,since Info
    already indicate it)
- [x] Variable
- [ ] Cleaner code
- [x] local/offline
- [ ] Add completion tags, ingress, and other subblock
- [ ] Further seperate data source from resource

## Todo for HCL
- [ ] Add Completion for hcl
- [ ] Completion for Sublock
## Todo for Improvement
- [X] Add Travis-CI for testing, and ensuring the completion is outputing the right completion

## [Contributors](./CONTRIBUTORS.md)

# (Neo)Vim Terraform Completion with Linter - [Demos](./DEMO.md)

## [Changelog](./CHANGELOG.md)

[![neovim build](https://badges.herokuapp.com/travis/juliosueiras/vim-terraform-completion?env=VIM_TYPE=nvim&label=Neovim%20Build)](https://travis-ci.org/juliosueiras/vim-terraform-completion)
[![vim build](https://badges.herokuapp.com/travis/juliosueiras/vim-terraform-completion?env=VIM_TYPE=vim&label=Vim%20Build)](https://travis-ci.org/juliosueiras/vim-terraform-completion)
![terraform version](https://img.shields.io/badge/terraform-0.10.3-blue.svg)
[![Join the chat at https://gitter.im/juliosueiras/vim-terraform-completion](https://badges.gitter.im/juliosueiras/vim-terraform-completion.svg)](https://gitter.im/juliosueiras/vim-terraform-completion?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)


## Overview

[![asciicast](https://asciinema.org/a/119610.png)](https://asciinema.org/a/119610)

- [Vim Terraform Completion with Linter - Demos](#vim-terraform-completion-with-linter---demosdemomd)
  * [Changelog](#changelog)
  * [Dependencies](#dependencies)
  * [Installation](#installation)
    + [NeoBundle](#neobundle)
    + [Vim-Plug](#vim-plug)
    + [Minimal Configuration](#minimal-configuration)
  * [General Todo](#general-todo)
  * [Todo for Terraform completion](#todo-for-terraform-completion)
  * [Todo for HCL](#todo-for-hcl)
  * [Todo for Improvement](#todo-for-improvement)
  * [Credits](#credits)
  * [Contributors](#contributors)

### Block Completions
(R) for Require , (O) for Optional and (B) for Block

![block completion](pics/block_completion1.png)

![block 2 completion](pics/block_completion2.png)

## Dependencies

- [vim-terraform](https://github.com/hashivim/vim-terraform) (For FileType)
  (Optional not require for completion)
- [vim-syntastic](https://github.com/vim-syntastic/syntastic) (Only for Linter)
- [neomake](https://github.com/neomake/neomake) (Only for Linter, Neovim)
- Ctags & [tagbar](https://github.com/majutsushi/tagbar) (Optional for Tag Sidebar)

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

" (Optinal) for Tag Sidebar
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
let g:syntastic_terraform_tffilter_plan = 1

```

## General Todo
<details>
<summary>Todolist</summary>

- [X] Adapt to Upcoming terraform 0.10
- [ ] (WIP) Refactoring Regex for linter and completion, and Trying out on api based(so it can integrade with other editor) solution
- [ ] (WIP) More test cases, and update to 0.9.6
- [x] Support for Neomake(Require further testing)
- [X] Run terraform plan and output to a new window(`<leader>rr`) 
- [X] Async Run support(For Neovim/Vim 8) 
- [ ] Move regex code to a json(for easier extension)
- [x] Test from zero to useful setup using Docker
- [x] Jump Reference (Ctrl-L first time to jump to resource definition, second time
    on the same line to jump back)
- [x] Show Doc (Ctrl-K)
- [x] Provide config and example
- [x] Integrate Basic `terraform validate` and `tflint` into Synstatic
- [x] Added a custom linter for providing a better error
- [ ] (WIP) Better linter
- [ ] (WIP) Full Snippets
</details>

**NOTE:** enabling deep check for tflint can be a bit slow

**NOTE:** To use `tffilter` please add `export PATH=$PATH:/path/to/this/plugin/bin` to your bashrc or zshrc

[Demo of the linter](https://asciinema.org/a/118441)

## Todo for Terraform completion
<details>
<summary>Todolist</summary>

- (Scrape due to Speed, Storage, and Inconsistency) Version-based Completion
- [X] (Require more work) Lookup Attributes data using terraform.tfstate
- [ ] Provider
- [x] Completion for functions(file,etc) and basic resource arguments(count,lifecyle, etc)
- [x] Module (Make sure you run `terraform get` beforehand)
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
</details>

## Todo for HCL
- [ ] Add Completion for hcl
- [X] Completion for Sublock(Indicate by `Type(B)` )
## Todo for Improvement
- [X] Add Travis-CI for testing, and ensuring the completion is outputing the right completion
- [ ] Look into the new module registry

## Credits
- Completion data is from Terraform Official Documentation and Model data from [Intellij-HCL](https://github.com/VladRassokhin/intellij-hcl/)
- Folding adapted from [vim-terraform](https://github.com/hashivim/vim-terraform)

## [Contributors](./CONTRIBUTORS.md)

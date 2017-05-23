"============================================================================
"File:        tffilter.vim
"Description: Syntax checking plugin for syntastic.vim(Custom Filter for
"terraform)
"Maintainer:  Julio Tain Sueiras <juliosueiras@gmail.com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists('g:loaded_syntastic_terraform_tffilter_checker')
    finish
endif

if !exists('g:syntastic_terraform_tffilter_plan')
""
" @setting g:syntastic_terraform_tffilter_plan
" @public
" Enable tffilter linter to use validate(0) or plan(1)
  let g:syntastic_terraform_tffilter_plan = 0
endif

let g:loaded_syntastic_terraform_tffilter_checker = 1

let s:save_cpo = &cpo
set cpo&vim

let s:path = fnamemodify(resolve(expand('<sfile>:p')), ':h')

function! SyntaxCheckers_terraform_tffilter_GetLocList() dict
    if g:syntastic_terraform_tffilter_plan == 1
      let makeprg = self.makeprgBuild({'fname_after': ' --with-plan' })
    else
      let makeprg = self.makeprgBuild({'fname_after': '' })
    endif

    let errorformat =
        \ '%f:%l:%m'

    let env = syntastic#util#isRunningWindows() ? {} : { 'TERM': 'dumb' }

    return SyntasticMake({
        \ 'defaults': { 'bufnr': bufnr('')},
        \ 'makeprg': makeprg,
        \ 'cwd': expand('%:p:h'),
        \ 'errorformat': errorformat })

endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'terraform',
    \ 'name': 'tffilter',
    \ 'exec': 'tffilter' })

let &cpo = s:save_cpo
unlet s:save_cpo

"============================================================================
"File:        terraform_validate.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Julio Tain Sueiras <juliosueiras@gmail.com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists('g:loaded_syntastic_terraform_terraform_validate_checker')
    finish
endif
let g:loaded_syntastic_terraform_terraform_validate_checker = 1

let s:save_cpo = &cpo
set cpo&vim

" function! SyntaxCheckers_terraform_terraform_validate_IsAvailable() dict
"     if !executable(self.getExec())
"         return 0
"     endif
"     return syntastic#util#versionIsAtLeast(self.getVersion(), [2, 0, 4])
" endfunction

function! SyntaxCheckers_terraform_terraform_validate_GetLocList() dict
    let makeprg = self.makeprgBuild({ 'args_after': 'validate -no-color', 'fname': '' })

    let errorformat =
        \ 'Error\ loading\ files\ Error\ parsing %f:\ At\ %l:%c:\ %m'

    let env = syntastic#util#isRunningWindows() ? {} : { 'TERM': 'dumb' }

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'cwd': expand('%:p:h'),
        \ 'errorformat': errorformat })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'terraform',
    \ 'name': 'terraform_validate',
    \ 'exec': 'terraform'})

let &cpo = s:save_cpo
unlet s:save_cpo

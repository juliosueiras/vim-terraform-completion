" Terraform set up for Tagbar plugin
" (https://github.com/majutsushi/tagbar).

if !exists(':Tagbar')
    finish
endif

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
    \ 'sort' : 1,
    \ 'deffile'   : expand('<sfile>:p:h:h') . '/ctags/terraform.ctags',
\ }

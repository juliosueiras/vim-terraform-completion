setlocal omnifunc=terraformcomplete#Complete
if !exists('g:syntastic_terraform_checkers')
        let g:syntastic_terraform_checkers = ['terraform_validate', 'tflint', 'tf_filter']
endif

augroup TerraformCompleteKeys
    autocmd FileType terraform noremap <buffer><silent> <C-K> :call terraformcomplete#GetDoc()<CR>
    autocmd FileType terraform noremap <buffer> <C-L> :call terraformcomplete#JumpRef()<CR>
augroup END

set keywordprg=:help

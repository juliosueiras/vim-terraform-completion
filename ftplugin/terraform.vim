setlocal omnifunc=terraformcomplete#Complete
if !exists('g:syntastic_terraform_checkers')
        let g:syntastic_terraform_checkers = ['terraform_validate', 'tflint', 'tf_filter']
endif

" autocmd FileType terraform nnoremap <C-K> :call terraformcomplete#GetDoc()<CR>
set keywordprg=:help

setlocal omnifunc=terraformcomplete#Complete
if !exists('g:syntastic_terraform_checkers')
        let g:syntastic_terraform_checkers = ['terraform_validate', 'tflint', 'tf_filter']
endif

" autocmd FileType terraform nnoremap <C-L> :call terraformcomplete#GetDoc()<CR>
autocmd FileType terraform nnoremap <C-L> :call terraformcomplete#JumpRef()<CR>
set keywordprg=:help

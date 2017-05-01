setlocal omnifunc=terraformcomplete#Complete
if !exists('g:syntastic_terraform_checkers')
        let g:syntastic_terraform_checkers = ['terraform_validate', 'tflint']
endif

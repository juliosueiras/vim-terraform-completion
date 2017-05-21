setlocal omnifunc=terraformcomplete#Complete

if !exists('g:syntastic_terraform_checkers')
    let g:syntastic_terraform_checkers = ['tffilter', 'terraform_validate', 'tflint']
endif

augroup TerraformCompleteKeys
    autocmd FileType terraform noremap <buffer><silent> <C-K> :call terraformcomplete#GetDoc()<CR>
    autocmd FileType terraform noremap <buffer> <C-L> :call terraformcomplete#JumpRef()<CR>
    autocmd FileType terraform noremap <buffer><silent> <leader>a :call terraformcomplete#LookupAttr()<CR>
augroup END


if has('nvim')
    silent! map <unique> <buffer> <Leader>rr :call terraformcomplete#NeovimRun()<CR>
elseif v:version >= 800
    silent! map <unique> <buffer> <Leader>rr :call terraformcomplete#AsyncRun()<CR>
else
    silent! map <unique> <buffer> <Leader>rr :call terraformcomplete#Run()<CR>
end


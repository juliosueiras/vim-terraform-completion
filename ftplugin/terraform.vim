""
" @section Introduction,introduction
" @order introduction configuration features mappings
" @all
" This plugin allow autocompletion for terraform, and it require "+ruby", check using |if_ruby|

""
" @section Configuration, configuration
" let g:syntastic_terraform_tffilter_plan = 0
"
" Enable tffilter linter to use validate(0) or plan(1)

""
" @section Features, features
" 1. Resource Completion
" 2. Data Completion
" 3. Block Completion
" 4. Attribute Completion
" 5. Variable Completion
" 6. Module Completion


setlocal omnifunc=terraformcomplete#Complete

if !exists('g:syntastic_terraform_checkers')
    let g:syntastic_terraform_checkers = ['tffilter', 'terraform_validate', 'tflint']
endif

""
" @section Mappings,mappings
" "<C-K>" (Ctrl-K) will show doc of the current attribute/argument in vim
"
" "<C-L>" (Ctrl-L) will jump to declaration of the resource/data/variable
"
" "<leader>a" will look up the current attribute data given that there is
" terraform.tfstate
"
" "<leader>o" will open the current resource/data on a browser
"
" "<leader>rr" to run terraform plan(async for neovim/vim 8, non-async for
" vim)

augroup TerraformCompleteKeys
    autocmd FileType terraform noremap <buffer><silent> <C-K> :call terraformcomplete#GetDoc()<CR>
    autocmd FileType terraform noremap <buffer> <C-L> :call terraformcomplete#JumpRef()<CR>
    autocmd FileType terraform noremap <buffer><silent> <leader>a :call terraformcomplete#LookupAttr()<CR>
    autocmd FileType terraform noremap <buffer><silent> <leader>o :call terraformcomplete#OpenDoc()<CR>
augroup END


if has('nvim')
    silent! map <unique> <buffer> <Leader>rr :call terraformcomplete#NeovimRun()<CR>
elseif v:version >= 800
    silent! map <unique> <buffer> <Leader>rr :call terraformcomplete#AsyncRun()<CR>
else
    silent! map <unique> <buffer> <Leader>rr :call terraformcomplete#Run()<CR>
end


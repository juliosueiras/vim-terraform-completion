if !has("ruby") && !has("ruby/dyn")
    finish
endif

if exists('loaded_deoplete')
    let deoplete#omni_patterns.terraform = '[^ *\t"{=$]\w*'
endif

if exists('g:syntastic_extra_filetypes')
    call add(g:syntastic_extra_filetypes, 'terraform')
else
    let g:syntastic_extra_filetypes = ['terraform']
endif

if exists('g:loaded_neomake')
    if !exists('g:neomake_terraform_tffilter_plan') 
        let g:neomake_terraform_tffilter_plan = 0
    endif

    if g:neomake_terraform_tffilter_plan == 0
        let args = ['%:p']
    else
        let args = ['%:p','--with-plan']
    endif

    let g:neomake_terraform_terraform_validate_maker = {
                \ 'exe' : 'terraform',
                \ 'append_file': 0,
                \ 'cwd': '%:p:h',
                \ 'args': ['validate', '-no-color'],
                \ 'errorformat': 'Error\ loading\ files\ Error\ parsing %f:\ At\ %l:%c:\ %m'
                \ }

    let g:neomake_terraform_tffilter_maker = {
                \ 'exe': 'tffilter',
                \ 'append_file': 0,
                \ 'cwd': '%:p:h',
                \ 'args': args,
                \ 'errorformat': '%f:%l:%m'
                \ }

    let g:neomake_terraform_tflint_maker = {
                \ 'exe' : 'tflint',
                \ 'append_file': 0,
                \ 'cwd': '%:p:h',
                \ 'args': [],
                \ 'errorformat': '%+P%f,%p%t%*[^:]:%l %m,%-Q'
                \ }

    let g:neomake_terraform_enabled_makers = ['terraform_validate', 'tflint', 'tffilter']
endif


let s:path = fnamemodify(resolve(expand('<sfile>:p')), ':h')

""
" Function to open the doc in browser
function! terraformcomplete#OpenDoc()
    try
        let a:provider = terraformcomplete#GetProvider()
        let a:resource = terraformcomplete#GetResource()
        let a:arg = matchlist(getline("."), '\s*\([^ ]*\)\s*=\?', '')
        if len(a:arg) >= 2
            let a:arg = a:arg[1]
        else
            let a:arg = ''
        endif

        let a:link = 'https://www.terraform.io/docs/providers/' . a:provider

        if terraformcomplete#GetType() ==? 'resource'
            let a:link .= '/r'
        else
            let a:link .= '/d'
        endif

        let a:link .= '/' . a:resource . '.html\#' . a:arg

        "(Windows) cmd /c start filename_or_URL
        if system('uname -s') == 'Darwin'
            silent! execute ':!open ' . a:link
        else
            silent! execute ':!xdg-open ' . a:link
        endif
    catch
    endtry
endfunction

function! terraformcomplete#OutputFold()
    let curr_line = getline(v:lnum)
    if match(curr_line, '-/+ .*') >= 0
        return ">1"
    elseif match(curr_line, '^\* .*') >= 0
        return ">1"
    elseif match(curr_line, '^+ .*') >= 0
        return ">1"
    elseif match(curr_line, '^- .*') >= 0
        return ">1"
    elseif match(curr_line, '\~ .*') >= 0
        return ">1"
    else
        return "="
    end
endfunction

function! terraformcomplete#NeovimRunHandler(job_id, data, event) dict
	if a:event == 'stdout'
	elseif a:event == 'stderr'
	else
	    let file = expand('%')
	    botright new
        execute ':r ' . g:planOutputFile
	    setlocal buftype=nofile
	    setlocal bufhidden=hide
	    setlocal nowrap
	    setlocal noswapfile
	    setlocal readonly
	    setlocal foldmethod=expr
	    setlocal foldexpr=terraformcomplete#OutputFold()

      syntax match addedItem '^+ .*'
      syntax match removedItem '^- .*'
      syntax match recreateItem '^-/+ .*'
      syntax match changedItem '^\~ .*'
      highlight addedItem guifg=#409900
      highlight removedItem guifg=#BC4C4C
      highlight recreateItem guifg=#409900
      highlight changedItem guifg=#FFAE19


        execute 'normal! GG'
	    noremap <silent><buffer> q :q<CR>
        unlet g:planOutputFile
	endif
endfunction

fun! terraformcomplete#NeovimRun() 
    let s:callbacks = {
                \ 'on_stdout': function('terraformcomplete#NeovimRunHandler'),
                \ 'on_stderr': function('terraformcomplete#NeovimRunHandler'),
                \ 'on_exit': function('terraformcomplete#NeovimRunHandler')
                \ }

    if exists('g:planOutputFile')
        echo 'Already running Plan in background'
    else
        echo 'Running Plan in background'

        let g:planOutputFile = tempname()
        let job1 = jobstart(['/bin/sh', '-c', 'terraform plan -input=false -no-color &> ' . g:planOutputFile ], extend({'shell': ''}, s:callbacks))
    endif
endfun

function! terraformcomplete#AsyncRunHandler(channel)
	    let file = expand('%')
	    botright new
        execute ':r ' . g:planOutputFile
	    setlocal buftype=nofile
	    setlocal bufhidden=hide
	    setlocal nowrap
	    setlocal noswapfile
	    setlocal readonly
	    setlocal foldmethod=expr
	    setlocal foldexpr=terraformcomplete#OutputFold()

        syntax match addedItem '^+ .*'
        syntax match removedItem '^- .*'
        syntax match recreateItem '^-/+ .*'
        syntax match changedItem '^\~ .*'
        highlight addedItem guifg=#409900
        highlight removedItem guifg=#BC4C4C
        highlight recreateItem guifg=#409900
        highlight changedItem guifg=#FFAE19

        execute 'normal! GG'
	    noremap <silent><buffer> q :q<CR>
        unlet g:planOutputFile
endfunction

fun! terraformcomplete#AsyncRun()
    if v:version < 800
        echoerr 'AsyncRun requires VIM version 8 or higher'
        return
    endif

    if exists('g:planOutputFile')
        echo 'Already running Plan in background'
    else
        echo 'Running Plan in background'

        let g:planOutputFile = tempname()
        call job_start(["/bin/sh", "-c", "terraform plan -input=false -no-color &> " . g:planOutputFile], {'close_cb': 'terraformcomplete#AsyncRunHandler'})
    endif
endfun

fun! terraformcomplete#Run()
    let file = expand('%')
    botright new
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal nowrap
    setlocal noswapfile
    setlocal readonly
    silent execute ':r!terraform plan -no-color -input=false'
    setlocal foldmethod=expr
    setlocal foldexpr=terraformcomplete#OutputFold()

    syntax match addedItem '^+ .*'
    syntax match removedItem '^- .*'
    syntax match recreateItem '^-/+ .*'
    syntax match changed2Item '^~ .*'
    highlight addedItem guifg=#409900
    highlight removedItem guifg=#BC4C4C
    highlight recreateItem guifg=#409900
    highlight changedItem guifg=#FFAE19

    noremap <silent><buffer> q :q<CR>
endfunc

let s:oldpos = []
function! terraformcomplete#JumpRef()
    try 
        let old_pos = getpos(".")
        if strpart(getline("."),0, getpos(".")[2]) =~ ".*{"
            execute 'normal! t}'
            let a:curr = strpart(getline("."),0, getpos(".")[2])
            let a:attr = split(split(a:curr, "${")[-1], '\.')
            call setpos('.', old_pos)
            let s:oldpos = getpos('.')

            if a:attr[0] == 'var'
                call search('\s*variable\s*"' . a:attr[1] . '".*')
            else
              if a:attr[0] == "data" 
                call search('.*\s*"' . a:attr[1] . '"\s*"' . a:attr[2] . '".*')
              else
                call search('.*\s*"' . a:attr[0] . '"\s*"' . a:attr[1] . '".*')
              endif
            end
            echo 'Jump to ' . a:attr[0] . '.' . a:attr[1]
        else
            call setpos('.', s:oldpos)
            echo 'Jumping Back'
            let s:oldpos = []
        end
    catch
    endtry
endfunction

function! terraformcomplete#LookupAttr()
    " TODO: Improve capture of interpolation
    " let a:curr = expand("<cWORD>")
        " ruby <<EOF
        " temp = VIM::evaluate('a:curr')
        " if temp[-1] != '.'
        "     temp = temp[0..-2]
        " end
        " if temp.match(/\${.*[^\w.-](?:(?![^\w.-]))(.*\.)[\)}]/) != nil
        "     res = temp.match(/\${.*[^\w.-](?:(?![^\w.-]))(.*\.)[\)}]/)[1]
        " elsif temp.match(/.*\${(.*\.)}/) != nil
        "     res = temp.match(/.*\${(.*\.)}/)[1]
        " end

    " VIM::command("let a:temp_attr = '#{res}'")
" EOF
try
    let a:curr_word = expand("<cWORD>")

    if a:curr_word =~ '${.*}'
        let a:word_array = split(matchlist(a:curr_word, '\v\$\{(.*)\}')[1], '\.')
        if a:word_array[0] == 'data'
            let a:look_for = a:word_array[0] . '.' . a:word_array[1] . '.' . a:word_array[2]
            if len(a:word_array) > 4
                let a:look_attr = a:word_array[3] . '.' . a:word_array[4]
            else
                let a:look_attr = a:word_array[3]
            endif
        else
            let a:look_for = a:word_array[0] . '.' . a:word_array[1]
            let a:look_attr = a:word_array[2]
        endif

        echo system(s:path . '/../utils/lookup_attrs ' . expand("%:p:h") . ' ' . a:look_for . ' ' . a:look_attr)
    endif
catch
endtry
endfunction

function! terraformcomplete#GetDoc()
    let s:curr_pos = getpos('.')
    if getline(".") !~# '^\s*\(resource\|data\)\s*"'
        execute '?\s*\(resource\|data\)\s*"'
    endif
    let a:provider = split(split(substitute(getline("."),'"', '', ''))[1], "_")[0]

    let a:resource = substitute(split(split(getline("."))[1], a:provider . "_")[1], '"','','')
    if getline(".") =~ '^data.*'
        let s:type = 'datas'
    else
        let s:type = 'resources'
    end
    call setpos('.', s:curr_pos)
    let a:curr_word = expand("<cWORD>")
    let a:search_word = ''
    let a:word_array = []

    if a:curr_word =~ '${.*}'
      let a:word_array = split(matchlist(a:curr_word, '\v\$\{(.*)\}')[1], '\.')
      if a:word_array[0] == 'data'
        let a:provider = split(a:word_array[1], "_")[0]
        let a:resource = split(a:word_array[1], a:provider . "_")[0]
        let s:type = 'datas'
        let a:res_type = 'attributes'
        let a:search_word = a:word_array[3]
      else
        let a:provider = split(a:word_array[0], "_")[0]
        let a:resource = split(a:word_array[0], a:provider . "_")[0]
        let s:type = 'resources'
        let a:res_type = 'attributes'
        let a:search_word = a:word_array[2]
      endif
    else
      let a:search_word = a:curr_word
      let a:res_type = 'arguments'
    endif

      let res = system(s:path . '/../utils/get_doc ' . s:path . " '" . a:search_word . "' " . a:provider . " " . a:resource . " " . s:type . " " . a:res_type)

      echo substitute(res, '\n', '', '')
endfunction


fun! terraformcomplete#GetResource()
    let s:curr_pos = getpos('.')
    if getline(".") !~# '^\s*\(resource\|data\)\s*"'
        execute '?\s*\(resource\|data\)\s*"'
    endif
    let a:provider = split(split(substitute(getline("."),'"', '', ''))[1], "_")[0]

    let a:resource = substitute(split(split(getline("."))[1], a:provider . "_")[1], '"','','')
    call setpos('.', s:curr_pos)
    unlet s:curr_pos
    return a:resource
endfun

fun! terraformcomplete#GetType()
    let s:curr_pos = getpos('.')
    if getline(".") !~# '^\s*\(resource\|data\)\s*"'
        execute '?\s*\(resource\|data\)\s*"'
    endif

    if getline(".") =~? "resource"
        let a:res = "resource"
    else
        let a:res = "data"
    endif

    call setpos(".", s:curr_pos)
    unlet s:curr_pos
	return a:res
endfun

fun! terraformcomplete#GetProvider()
    let s:curr_pos = getpos('.')
    if getline(".") !~# '^\s*\(resource\|data\)\s*"'
        execute '?\s*\(resource\|data\)\s*"'
    endif

    let a:provider = split(split(substitute(getline("."),'"', '', ''))[1], "_")[0]

    call setpos(".", s:curr_pos)
    unlet s:curr_pos
	return a:provider
endfun

function! terraformcomplete#rubyComplete(ins, provider, resource, attribute, data_or_resource)
    let s:curr_pos = getpos('.')
    let a:res = []
    let a:resource_line = getline(s:curr_pos[1]) =~ "^[ ]*resource"
    let a:data_line = getline(s:curr_pos[1]) =~ "^[ ]*data"
    let a:provider_line = (strpart(getline("."),0, getpos(".")[2]) =~ '^[ ]*\(resource\|data\)[ ]*"\%["]$' || getline(s:curr_pos[1]) =~ "provider")
    

  ruby << EOF
require 'json'

def terraform_complete(provider, resource)
    begin
        data = ''
        if VIM::evaluate('a:provider_line') == 0 then
            File.open("#{VIM::evaluate('s:path')}/../provider_json/#{provider}.json", "r") do |f|
              f.each_line do |line|
                data = line
              end
            end

            parsed_data = JSON.parse(data)
            if VIM::evaluate('a:attribute') == "true" then
              if VIM::evaluate('a:data_or_resource') == 0 then
                result = parsed_data['datas'][resource]["attributes"]
              else
                result = parsed_data['resources'][resource]["attributes"]
              end
            elsif VIM::evaluate('a:data_line') == 1 then
                temp = parsed_data['datas'].keys
                temp.delete("provider_arguments")
                result = temp.map { |x|
                    { "word" => x }
                }
            elsif VIM::evaluate('a:resource_line') == 1 then
                temp = parsed_data['resources'].keys
                temp.delete("provider_arguments")
                result = temp.map { |x|
                    { "word" => x }
                }
            else
              if VIM::evaluate('a:data_or_resource') == 0 then
                result = parsed_data['datas'][resource]["arguments"]
              else
                result = parsed_data['resources'][resource]["arguments"]
              end
              result.concat(JSON.parse(File.read("#{VIM::evaluate('s:path')}/../extra_json/base.json")))
            end
        elsif VIM::evaluate('a:provider_line') == 1 then
            result = Dir.glob("#{VIM::evaluate('s:path')}/../provider_json/*.json").map { |x|
              { "word" => x.split("../provider_json/")[1].split('.json')[0] }
            }
        end

        return JSON.generate(result)
    rescue
        return []
    end
end


class TerraformComplete
  def initialize()
    @buffer = Vim::Buffer.current
   
    print Vim::evaluate('a:ins')

    result = terraform_complete(VIM::evaluate('a:provider'), VIM::evaluate('a:resource'))
    Vim::command("let a:res = #{result}")
  end
end
gem = TerraformComplete.new()
EOF
let a:resource_line = 0
let a:provider_line = 0
return a:res
endfunction

fun! terraformcomplete#Complete(findstart, base)
  if a:findstart
    " locate the start of the word
    let line = getline('.')
    let start = col('.') - 1
    while start > 0 && line[start - 1] =~ '\a'
      let start -= 1
    endwhile
    return start
  else
    let res = []
    try
      let a:provider = terraformcomplete#GetProvider()
    catch
      let a:provider = ''
    endtry

    try
      let a:resource = terraformcomplete#GetResource()
    catch
      let a:resource = ''
    endtry

    let a:old_pos = getpos(".")
    try
        execute 'normal! [{'
        let a:test_line = getline(".")
        execute 'normal! [{'
        let a:data_or_resource = matchlist(getline("."), '\s*\([^" ]*\)\s*.*', '')[1]
        call setpos(".",a:old_pos)
        let a:test_name = matchlist(a:test_line, '\s*\([^ ]*\)\s*{', '')[1]
        ruby <<EOF
            require 'json'
            data = ''
            File.open("#{VIM::evaluate('s:path')}/../provider_json/#{VIM::evaluate('a:provider')}.json", "r") do |f|
              f.each_line do |line|
                data = line
              end
            end

            base_data = JSON.parse(File.read("#{VIM::evaluate('s:path')}/../extra_json/base.json"))

            test = VIM::evaluate("a:test_name")
            parsed_data = ''
            result = JSON.parse(data)["#{VIM::evaluate('a:data_or_resource')}s"][VIM::evaluate("a:resource")]['arguments']

            result.concat(base_data)

            result.each do |i| 
                if i['word'] == test
                    parsed_data = JSON.generate(i['subblock'])
                    break
                end
            end
            VIM::command("let a:res = #{parsed_data}")
EOF
        return a:res
    catch
    endtry
    call setpos(".",a:old_pos)


    if strpart(getline('.'),0, getpos('.')[2]) =~ '\${[^}]*\%[}]$'
    try
            let a:search_continue = 1
            let a:resource_list = []
            let a:type_list = {}
            let a:data_list = []
            let a:data_type_list = {}

            let a:all_res = terraformcomplete#GetAll('resource')
            let a:resource_list = a:all_res[0]
            let a:type_list = a:all_res[1]
            call add(a:resource_list, { 'word': 'var' })
            call add(a:resource_list, { 'word': 'module' })
            call add(a:resource_list, { 'word': 'data' })
            ruby <<EOF
            require 'json'
            res = JSON.parse(File.read("#{VIM::evaluate('s:path')}/../extra_json/functions.json"))
            res.each do |i|
                VIM::command("call add(a:resource_list, #{JSON.generate(i)})") 
            end
EOF

            try
                let a:curr = strpart(getline('.'),0, getpos('.')[2])

                ruby <<EOF
                temp = VIM::evaluate('a:curr')
                if temp[-1] != '.'
                    temp = temp[0..-2]
                end
                if temp.match(/\${.*[^\w.-](?:(?![^\w.-]))(.*\.)$/) != nil
                    res = temp.match(/\${.*[^\w.-](?:(?![^\w.-]))(.*\.)$/)[1]
                elsif temp.match(/.*\${(.*\.)$/) != nil
                    res = temp.match(/.*\${(.*\.)$/)[1]
                end

                VIM::command("let a:temp_attr = '#{res}'")
EOF
                let a:attr = split(a:temp_attr, '\.')


                if len(a:attr) == 1
                    if a:attr[0] == "data" 
                      let a:data_list = terraformcomplete#GetAll('data')[0]
                      return a:data_list
                    elseif a:attr[0] == "module" 
                      let a:module_list = terraformcomplete#GetAllModule()[0]
                      return a:module_list
                    elseif a:attr[0] == "var" 
                        ruby <<EOF
                        require 'json'

                        def terraform_get_vars()
                            path = "#{Vim::evaluate("expand('%:p:h')")}"
                            curr_file = "#{Vim::evaluate("expand('%:p')")}"
                            vars_file_paths = ["#{path}/variables.tf", "#{path}/vars.tf", curr_file]
                            vars = []
                            vars_file_paths.each do |file|
                                if File.readable? file then
                                    vars_array = File.read(file)
                                    vars_array = vars_array.split("\n")
                                    vars_array = vars_array.find_all {|x| x[/variable\s*".*"/]}
                                    vars.concat(vars_array.map {|x| { "word": x.split(" ")[1].tr("\"", '')} })
                                end
                            end
                            return JSON.generate(vars)
                        end

                        Vim::command("let a:vars_res = #{terraform_get_vars()}")
EOF
                        return a:vars_res
                    else
                        if a:type_list != {}
                          return a:type_list[a:attr[0]]
                        else
                          return 
                        endif
                    endif
                elseif len(a:attr) == 2
                    if a:attr[0] == "data" 
                      let a:data_type_list = terraformcomplete#GetAll('data')[1]
                      return a:data_type_list[a:attr[1]]
                    elseif a:attr[0] == "module"
                        let a:file_path = expand('%:p:h')
                        let a:line = terraformcomplete#GetAllModule()[1][a:attr[1]][0]
                        let a:module_name = a:attr[1]
                        ruby <<EOF
                        require "#{Vim::evaluate("s:path")}/../module"
                        include ModuleUtils
                        name = Vim::evaluate("a:module_name")
                        line = Vim::evaluate("a:line")
                        file_path = Vim::evaluate("a:file_path")
                        Vim::command("let a:res = #{load_attr_module(name, line.to_s, file_path)}")
EOF
                        return a:res
                    else
                      let a:provider = split(a:attr[0], "_")[0]

                      let a:resource = split(a:attr[0], a:provider . "_")[0]
                      let a:data_or_resource = 1

                      for m in terraformcomplete#rubyComplete(a:base, a:provider, a:resource, 'true', a:data_or_resource)
                        if m.word =~ '^' . a:base
                          call add(res, m)
                        endif
                      endfor
                      return res
                    endif
                elseif len(a:attr) == 3
                    if a:attr[0] == "data"
                        let a:res = []
                        let a:provider = split(a:attr[1], "_")[0]

                        let a:resource = split(a:attr[1], a:provider . "_")[0]
                        let a:data_or_resource = 0
                        for m in terraformcomplete#rubyComplete(a:base, a:provider, a:resource, 'true', a:data_or_resource)
                            if m.word =~ '^' . a:base
                                call add(a:res, m)
                            endif
                        endfor
                        return a:res
                    else
                      let a:provider = split(a:attr[0], "_")[0]

                      let a:resource = split(a:attr[0], a:provider . "_")[0]
                      let a:data_or_resource = 1

                      for m in terraformcomplete#rubyComplete(a:base, a:provider, a:resource, 'true', a:data_or_resource)
                        if m.word =~ '^' . a:base
                          call add(res, m)
                        endif
                      endfor
                      return res
                    endif
                else
                    return a:resource_list
                endif
            catch
                return a:resource_list
            endtry
        catch
            return a:resource_list
        endtry
    else
        try
          let s:curr_pos = getpos('.')
          let s:oldline = getline('.')
          call search('^\s*\(resource\|data\|module\)\s*"', 'b')
          if getline('.') =~ '^\s*module'
            let a:module_name = matchlist(getline("."), '^\s*module\s*"\(.*\)".*')[1]
            execute '/^\s*source.*'
            let a:line = getline(".")
            call setpos('.', s:curr_pos)
            let a:file_path = expand('%:p:h')
              ruby <<EOF
                  require "#{Vim::evaluate("s:path")}/../module"
                  include ModuleUtils
                  name = Vim::evaluate("a:module_name")
                  line = Vim::evaluate("a:line")
                  file_path = Vim::evaluate("a:file_path")
                  Vim::command("let a:res = #{load_arg_module(name, line.to_s, file_path)}")
EOF
              return a:res
          else
            if getline('.') =~ '^\s*data'
              let a:data_or_resource = 0
            else
              let a:data_or_resource = 1
            endif

            call setpos('.', s:curr_pos)
            for m in terraformcomplete#rubyComplete(a:base, a:provider, a:resource, 'false', a:data_or_resource)
              if m.word =~ '^' . a:base
                call add(res, m)
              endif
            endfor
            return res
          endif
      catch
      endtry
    endif
  endif
endfun

fun! terraformcomplete#GetAllModule() abort
  let a:old_pos = getpos('.')
  execute 'normal! gg'
  let a:search_continue = 1
  let a:list = []
  let a:source_list = {}
  if getline(".") =~ 'module\s*".*"\s*' 
      let temp = substitute(split(split(getline(1),'\s*module ')[0], ' ')[0], '"','','g')
      let a:oldpos = getpos('.')
      call search('source\s*=')
      let a:source = getline('.')
      call setpos('.', a:oldpos)
      call add(a:list, { 'word': temp })

      if has_key(a:source_list, temp) == 0
        let a:source_list[temp] = []
      endif

      call add(a:source_list[temp], a:source )
  endif
  while a:search_continue != 0

    let a:search_continue = search('module\s*".*"\s*', 'W')

    if a:search_continue != 0 
      let temp = substitute(split(split(getline(a:search_continue),'module ')[0], ' ')[0], '"','','g')
      let a:oldpos = getpos('.')
      call search('source\s*=')
      let a:source = getline(".")
      call setpos('.', a:oldpos)
      call add(a:list, { 'word': temp })

      if has_key(a:source_list, temp) == 0
        let a:source_list[temp] = []
      endif

      call add(a:source_list[temp], a:source )
    endif
  endwhile
  call setpos('.', a:old_pos)
  return [a:list, a:source_list]
endfunc

fun! terraformcomplete#GetAll(data_or_resource) abort
  let a:old_pos = getpos('.')
  execute 'normal! gg'
  let a:search_continue = 1
  let a:list = []
  let a:type_list = {}
  if getline(".") =~ a:data_or_resource . '\s*"\w*"\s*"[^"]*"' 
      let temp = substitute(split(split(getline(a:search_continue),a:data_or_resource . ' ')[0], ' ')[0], '"','','g')
      call add(a:list, { 'word': temp })

      if has_key(a:type_list, temp) == 0
        let a:type_list[temp] = []
      endif

      call add(a:type_list[temp], { 'word': substitute(split(split(getline(a:search_continue), a:data_or_resource . ' ')[0], ' ')[1], '"','','g')})
  endif
  while a:search_continue != 0

    let a:search_continue = search(a:data_or_resource . '\s*"\w*"\s*"[^"]*"', 'W')

    if a:search_continue != 0 
      let temp = substitute(split(split(getline(a:search_continue),a:data_or_resource . ' ')[0], ' ')[0], '"','','g')
      call add(a:list, { 'word': temp })

      if has_key(a:type_list, temp) == 0
        let a:type_list[temp] = []
      endif

      call add(a:type_list[temp], { 'word': substitute(split(split(getline(a:search_continue), a:data_or_resource . ' ')[0], ' ')[1], '"','','g')})
    endif
  endwhile
  call setpos('.', a:old_pos)
  return [a:list, a:type_list]
endfunc

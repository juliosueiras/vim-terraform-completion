if !has("ruby") && !has("ruby/dyn")
    finish
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
" Function to eval interpolation
function! terraformcomplete#EvalInter()


	let old_pos = getpos(".")
	execute 'normal! t}'
	if strpart(getline(".") , 0 , getpos(".")[2]) =~ ".*{"
		let a_curr = strpart(getline("."),0, getpos(".")[2])
		let a_pair_text = split(a_curr, "${")[-1]
		call setpos('.', old_pos)
		botright new
		setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap

	ruby <<EOF
	require 'tempfile'

	result = `terraform console <<EOE 2>&1
#{Vim::evaluate("a_pair_text")}
EOE
`

	file = Tempfile.new('tfconsole')
	begin
	  file.write(result)
  ensure
		file.close
		Vim::command("read #{file.path}")
		file.unlink   # deletes the temp file
  end
EOF
	setlocal nomodifiable
endif
endfunc

""
" Function to open the doc in browser
function! terraformcomplete#OpenDoc()
    try
        let a_provider = terraformcomplete#GetProvider()
        let a_resource = terraformcomplete#GetResource()
        let a_arg = matchlist(getline("."), '\s*\([^ ]*\)\s*=\?', '')
        if len(a_arg) >= 2
            let a_arg = a_arg[1]
        else
            let a_arg = ''
        endif

        if a_provider == "digitalocean"
          let a_provider = "do"
        endif

        let a_link = 'https://www.terraform.io/docs/providers/' . a_provider

        if terraformcomplete#GetType() ==? 'resource'
            let a_link .= '/r'
        else
            let a_link .= '/d'
        endif

        let a_link .= '/' . a_resource . '.html\#' . a_arg

        "(Windows) cmd /c start filename_or_URL
        if system('uname -s') =~ 'Darwin'
            silent! execute ':!open ' . a_link
            silent! execute ':redraw!'
        else
            silent! execute ':!xdg-open ' . a_link
            silent! execute ':redraw!'
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
            let a_curr = strpart(getline("."),0, getpos(".")[2])
            let a_attr = split(split(a_curr, "${")[-1], '\.')
            call setpos('.', old_pos)
            let s:oldpos = getpos('.')

            if a_attr[0] == 'var'
                call search('\s*variable\s*"' . a_attr[1] . '".*')
            else
              if a_attr[0] == "data" 
                call search('.*\s*"' . a_attr[1] . '"\s*"' . a_attr[2] . '".*')
              else
                call search('.*\s*"' . a_attr[0] . '"\s*"' . a_attr[1] . '".*')
              endif
            end
            echo 'Jump to ' . a_attr[0] . '.' . a_attr[1]
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
    " let a_curr = expand("<cWORD>")
        " ruby <<EOF
        " temp = VIM::evaluate('a_curr')
        " if temp[-1] != '.'
        "     temp = temp[0..-2]
        " end
        " if temp.match(/\${.*[^\w.-](?:(?![^\w.-]))(.*\.)[\)}]/) != nil
        "     res = temp.match(/\${.*[^\w.-](?:(?![^\w.-]))(.*\.)[\)}]/)[1]
        " elsif temp.match(/.*\${(.*\.)}/) != nil
        "     res = temp.match(/.*\${(.*\.)}/)[1]
        " end

    " VIM::command("let a_temp_attr = '#{res}'")
" EOF
try
    let a_curr_word = expand("<cWORD>")

    if a_curr_word =~ '${.*}'
        let a_word_array = split(matchlist(a_curr_word, '\v\$\{(.*)\}')[1], '\.')
        if a_word_array[0] == 'data'
            let a_look_for = a_word_array[0] . '.' . a_word_array[1] . '.' . a_word_array[2]
            if len(a_word_array) > 4
                let a_look_attr = a_word_array[3] . '.' . a_word_array[4]
            else
                let a_look_attr = a_word_array[3]
            endif
        else
            let a_look_for = a_word_array[0] . '.' . a_word_array[1]
            let a_look_attr = a_word_array[2]
        endif

        echo system(s:path . '/../utils/lookup_attrs ' . expand("%:p:h") . ' ' . a_look_for . ' ' . a_look_attr)
    endif
catch
endtry
endfunction

function! terraformcomplete#GetDoc()
    let s:curr_pos = getpos('.')
    if getline(".") !~# '^\s*\(resource\|data\)\s*"'
        execute '?\s*\(resource\|data\)\s*"'
    endif
    let a_provider = split(split(substitute(getline("."),'"', '', ''))[1], "_")[0]

    let a_resource = substitute(split(split(getline("."))[1], a_provider . "_")[1], '"','','')
    if getline(".") =~ '^data.*'
        let s:type = 'datas'
    else
        let s:type = 'resources'
    end
    call setpos('.', s:curr_pos)
    let a_curr_word = expand("<cWORD>")
    let a_search_word = ''
    let a_word_array = []

    if a_curr_word =~ '${.*}'
      let a_word_array = split(matchlist(a_curr_word, '\v\$\{(.*)\}')[1], '\.')
      if a_word_array[0] == 'data'
        let a_provider = split(a_word_array[1], "_")[0]
        let a_resource = split(a_word_array[1], a_provider . "_")[0]
        let s:type = 'datas'
        let a_res_type = 'attributes'
        let a_search_word = a_word_array[3]
      else
        let a_provider = split(a_word_array[0], "_")[0]
        let a_resource = split(a_word_array[0], a_provider . "_")[0]
        let s:type = 'resources'
        let a_res_type = 'attributes'
        let a_search_word = a_word_array[2]
      endif
    else
      let a_search_word = a_curr_word
      let a_res_type = 'arguments'
    endif

      let res = system(s:path . '/../utils/get_doc ' . s:path . " '" . a_search_word . "' " . a_provider . " " . a_resource . " " . s:type . " " . a_res_type)

      echo substitute(res, '\n', '', '')
endfunction


fun! terraformcomplete#GetResource()
    let s:curr_pos = getpos('.')
    if getline(".") !~# '^\s*\(resource\|data\)\s*"'
        execute '?^\s*\(resource\|data\)\s*"'
    endif
    let a_provider = split(split(substitute(getline("."),'"', '', ''))[1], "_")[0]

    let a_resource = substitute(split(split(getline("."))[1], a_provider . "_")[1], '"','','')
    call setpos('.', s:curr_pos)
    unlet s:curr_pos
    return a_resource
endfun

fun! terraformcomplete#GetType()
    let s:curr_pos = getpos('.')
    if getline(".") !~# '^\s*\(resource\|data\)\s*"'
        execute '?\s*\(resource\|data\)\s*"'
    endif

    if getline(".") =~? "resource"
        let a_res = "resource"
    else
        let a_res = "data"
    endif

    call setpos(".", s:curr_pos)
    unlet s:curr_pos
	return a_res
endfun

fun! terraformcomplete#GetProvider()
    let s:curr_pos = getpos('.')
    if getline(".") !~# '^\s*\(resource\|data\)\s*"'
        execute '?^\s*\(resource\|data\)\s*"'
    endif

    let a_provider = split(split(substitute(getline("."),'"', '', ''))[1], "_")[0]

    call setpos(".", s:curr_pos)
    unlet s:curr_pos
	return a_provider
endfun

function! terraformcomplete#rubyComplete(ins, provider, resource, attribute, data_or_resource, block_word)

    let s:curr_pos = getpos('.')
    let a_res = []
    let a_resource_line = getline(s:curr_pos[1]) =~ "^[ ]*resource"
    let a_data_line = getline(s:curr_pos[1]) =~ "^[ ]*data"
    let a_provider_line = (strpart(getline("."),0, getpos(".")[2]) =~ '^[ ]*\(resource\|data\)[ ]*"\%["]$' || getline(s:curr_pos[1]) =~ "provider")

  ruby << EOF
require 'json'

def terraform_complete(provider, resource)
    begin
        data = ''
        if VIM::evaluate('a_provider_line') == 0 then
						if File.exists? "#{VIM::evaluate('s:path')}/../provider_json/#{provider}/#{VIM::evaluate("g:terraform_versions_config")[provider]}/#{provider}.json" 
							File.open("#{VIM::evaluate('s:path')}/../provider_json/#{provider}/#{VIM::evaluate("g:terraform_versions_config")[provider]}/#{provider}.json", "r") do |f|
								f.each_line do |line|
									data = line
								end
							end
						else
							File.open("#{VIM::evaluate('s:path')}/../community_provider_json/#{provider}/#{VIM::evaluate("g:terraform_versions_config")[provider]}/#{provider}.json", "r") do |f|
								f.each_line do |line|
									data = line
								end
							end
						end

            parsed_data = JSON.parse(data)
						block_word = VIM::evaluate('a:block_word')
            if VIM::evaluate('a:attribute') == "true" then
              if VIM::evaluate('a:data_or_resource') == 0 then
								if block_word == "" then
									result = parsed_data['datas'][resource]["attributes"]
								else
									result = parsed_data['datas'][resource]["attributes"]
									for r in result
										if r["word"] == block_word
											result = r["subblock"]
										end
									end
								end
              else
								if block_word == "" then
									result = parsed_data['resources'][resource]["attributes"]
								else
									result = parsed_data['resources'][resource]["attributes"]
									for r in result
										if r["word"] == block_word
											result = r["subblock"]
										end
									end
								end
              end
            elsif VIM::evaluate('a_data_line') == 1 then
                temp = parsed_data['datas'].keys
                temp.delete("provider_arguments")
                result = temp.map { |x|
                    { "word" => x }
                }
            elsif VIM::evaluate('a_resource_line') == 1 then
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
        elsif VIM::evaluate('a_provider_line') == 1 then
						result = VIM::evaluate('g:terraform_versions_config').keys.sort.map	do |value|
							{ "word" => value }
						end
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
    Vim::command("let a_res = #{result}")
  end
end
gem = TerraformComplete.new()
EOF
let a_resource_line = 0
let a_provider_line = 0
return a_res
endfunction

fun! terraformcomplete#tfcompleterc_Complete(findstart, base)
	if a:findstart
		" locate the start of the word
		let line = getline('.')
		let start = col('.') - 1
		while start > 0 && line[start - 1] =~ '\a'
			let start -= 1
		endwhile
		return start
	else
    let a_res = []
		for m in readfile(s:path . "/../dicts/tfcompleterc_dict")
			if m =~ '^' . a:base
				call add(a_res, m)
			endif
		endfor
		return a_res
	endif
endfunc

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
    let final_res = []
		if getline(".") =~ '\s*source\s*=\s*"'
			if g:terraform_registry_module_completion
				for m in terraformcomplete#GetAllRegistryModules()
					if m.word =~ '^' . a:base
            call add(final_res, m)
					endif
				endfor
        return final_res
			endif
		endif
    try
      let a_provider = terraformcomplete#GetProvider()
    catch
      let a_provider = ''
    endtry
	
    try
      let a_resource = terraformcomplete#GetResource()
    catch
      let a_resource = ''
    endtry

    let a_old_pos = getpos(".")
    try
        execute 'normal! [{'
        let a_test_line = getline(".")
        call setpos(".",a_old_pos)
				let a_all_line = []
				let counter = 0
				while counter <= 40
					let counter += 1
					execute 'normal! [{'
					let a_curr_line = match(getline("."), '^\s*\(resource\|data\|module\|variable\|output\|locals\|provider\)\s*"')
					if a_curr_line != 0
						call add(a_all_line,matchlist(getline("."), '\s*\([^ ]*\)\s*{', '')[1])
					else
						break
					endif
				endw
        call setpos(".",a_old_pos)
        execute 'normal! [{'

				let a_nested = match(getline("."), '^\s*\(resource\|data\|module\)\s*"')
				call search('^\s*\(resource\|data\|module\)\s*"', 'b')

        let a_data_or_resource = matchlist(getline("."), '\s*\([^" ]*\)\s*.*', '')[1] 
        call setpos(".",a_old_pos)
        let a_test_name = matchlist(a_test_line, '\s*\([^ ]*\)\s*{', '')[1]
        ruby <<EOF
            require 'json'
            data = ''
						if File.exists? "#{VIM::evaluate('s:path')}/../provider_json/#{VIM::evaluate('a_provider')}/#{VIM::evaluate("g:terraform_versions_config")[VIM::evaluate('a_provider')]}/#{VIM::evaluate('a_provider')}.json" 
							File.open("#{VIM::evaluate('s:path')}/../provider_json/#{VIM::evaluate('a_provider')}/#{VIM::evaluate("g:terraform_versions_config")[VIM::evaluate('a_provider')]}/#{VIM::evaluate('a_provider')}.json", "r") do |f|
								f.each_line do |line|
									data = line
								end
							end
						else
							File.open("#{VIM::evaluate('s:path')}/../community_provider_json/#{VIM::evaluate('a_provider')}/#{VIM::evaluate("g:terraform_versions_config")[VIM::evaluate('a_provider')]}/#{VIM::evaluate('a_provider')}.json", "r") do |f|
								f.each_line do |line|
									data = line
								end
							end
						end

            base_data = JSON.parse(File.read("#{VIM::evaluate('s:path')}/../extra_json/base.json"))

            test = VIM::evaluate("a_test_name")
            nested = VIM::evaluate("a_nested")
            parsed_data = ''
            result = JSON.parse(data)["#{VIM::evaluate('a_data_or_resource')}s"][VIM::evaluate("a_resource")]['arguments']

            result.concat(base_data)

						all_words = VIM::evaluate("a_all_line")
						result_subblock = result 
						all_words.reverse.each do |word|
							result_subblock = result_subblock.find {|i| i["word"] == word }["subblock"]
						end
						parsed_data = JSON.generate(result_subblock)
            result.each do |i| 
	    end
            VIM::command("let a_res = #{parsed_data}")
EOF
        return a_res
    catch
    endtry
    call setpos(".",a_old_pos)


    if strpart(getline('.'),0, getpos('.')[2]) =~ '\${[^}]*\%[}]$'
    try
            let a_search_continue = 1
            let a_resource_list = []
            let a_type_list = {}
            let a_data_list = []
            let a_data_type_list = {}

            let a_all_res = terraformcomplete#GetAll('resource')
            let a_resource_list = a_all_res[0]
            let a_type_list = a_all_res[1]
            call add(a_resource_list, { 'word': 'var' })
            call add(a_resource_list, { 'word': 'module' })
            call add(a_resource_list, { 'word': 'data' })
            ruby <<EOF
            require 'json'
            res = JSON.parse(File.read("#{VIM::evaluate('s:path')}/../extra_json/functions.json"))
            res.each do |i|
                VIM::command("call add(a_resource_list, #{JSON.generate(i)})") 
            end
EOF

            try
                let a_curr = strpart(getline('.'),0, getpos('.')[2])

                ruby <<EOF
                temp = VIM::evaluate('a_curr')
                if temp[-1] != '.'
                    temp = temp[0..-2]
                end

								#puts temp.match(/\${.*[^\w*.-](?:(?![^\w*.-]))(.*\.)$/)
                if temp.match(/\${.*[^\[\]\w*.-](?:(?![^\[\]\w*.-]))(.*\.)$/) != nil
                    res = temp.match(/\${.*[^\[\]\w*.-](?:(?![^\[\]\w*.-]))(.*\.)$/)[1]
                elsif temp.match(/.*\${(.*\.)$/) != nil
                    res = temp.match(/.*\${(.*\.)$/)[1]
                end
								#res_ar = res.split "."

								#puts res_ar
								#if res_ar[0] == "data" and res_ar[3] == '*'
								#	res_ar.delete_at 3
								#elsif res_ar[2] == "*"
								#	res_ar.delete_at 2
								#end

                VIM::command("let a_temp_attr = '#{res}'")
EOF
                let a_attr = split(a_temp_attr, '\.')


                if len(a_attr) == 1
                    if a_attr[0] == "data" 
                      let a_data_list = terraformcomplete#GetAll('data')[0]
                      return a_data_list
                    elseif a_attr[0] == "module" 
                      let a_module_list = terraformcomplete#GetAllModule()[0]
                      return a_module_list
                    elseif a_attr[0] == "var" 
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

                        Vim::command("let a_vars_res = #{terraform_get_vars()}")
EOF
                        return a_vars_res
                    else
                        if a_type_list != {}
                          return a_type_list[a_attr[0]]
                        else
                          return 
                        endif
                    endif
                elseif len(a_attr) == 2
                    if a_attr[0] == "data" 
                      let a_data_type_list = terraformcomplete#GetAll('data')[1]
                      return a_data_type_list[a_attr[1]]
                    elseif a_attr[0] == "module"
                        let a_file_path = expand('%:p:h')
                        let a_line = terraformcomplete#GetAllModule()[1][a_attr[1]][0]
                        let a_module_name = a_attr[1]
                        ruby <<EOF
                        require "#{Vim::evaluate("s:path")}/../module"
                        include ModuleUtils
                        name = Vim::evaluate("a_module_name")
                        line = Vim::evaluate("a_line")
                        file_path = Vim::evaluate("a_file_path")
                        Vim::command("let a_res = #{load_attr_module(name, line.to_s, file_path)}")
EOF
                        return a_res
                    else
                      let a_provider = split(a_attr[0], "_")[0]

                      let a_resource = split(a_attr[0], a_provider . "_")[0]
                      let a_data_or_resource = 1

                      for m in terraformcomplete#rubyComplete(a:base, a_provider, a_resource, 'true', a_data_or_resource, "")
                        if m.word =~ '^' . a:base
                          call add(res, m)
                        endif
                      endfor
                      return res
                    endif
                elseif len(a_attr) == 3
                    if a_attr[0] == "data"
                        let a_res = []
                        let a_provider = split(a_attr[1], "_")[0]

                        let a_resource = split(a_attr[1], a_provider . "_")[0]
                        let a_data_or_resource = 0
                        for m in terraformcomplete#rubyComplete(a:base, a_provider, a_resource, 'true', a_data_or_resource, "")
                            if m.word =~ '^' . a:base
                                call add(a_res, m)
                            endif
                        endfor
                        return a_res
                    else
                      let a_provider = split(a_attr[0], "_")[0]

                      let a_resource = split(a_attr[0], a_provider . "_")[0]
                      let a_data_or_resource = 1

                      for m in terraformcomplete#rubyComplete(a:base, a_provider, a_resource, 'true', a_data_or_resource, "")
                        if m.word =~ '^' . a:base
                          call add(res, m)
                        endif
                      endfor
                      return res
                    endif
                elseif len(a_attr) == 4 
                    if a_attr[0] == "data"
                        let a_res = []
                        let a_provider = split(a_attr[1], "_")[0]

                        let a_resource = split(a_attr[1], a_provider . "_")[0]
                        let a_data_or_resource = 0

												"if match(a_attr[3], "^[0-9*]*$") == 0
												"	let a_attr_block_word = a_attr[4]
												"else
												"	let a_attr_block_word = a_attr[3]
												"endif
												"echo a_attr_block_word

                        for m in terraformcomplete#rubyComplete(a:base, a_provider, a_resource, 'true', a_data_or_resource, "")
                            if m.word =~ '^' . a:base
                                call add(a_res, m)
                            endif
                        endfor
                        return a_res
                    else
                      let a_provider = split(a_attr[0], "_")[0]

                      let a_resource = split(a_attr[0], a_provider . "_")[0]
                      let a_data_or_resource = 1

											if match(a_attr[2], "^[0-9*]*$") == 0
												let a_attr_block_word = a_attr[3]
											else
												let a_attr_block_word = a_attr[2]
											endif

                      for m in terraformcomplete#rubyComplete(a:base, a_provider, a_resource, 'true', a_data_or_resource, a_attr_block_word)
                        if m.word =~ '^' . a:base
                          call add(res, m)
                        endif
                      endfor
                      return res
                    endif
                elseif len(a_attr) == 5 
                    if a_attr[0] == "data"
                        let a_res = []
                        let a_provider = split(a_attr[1], "_")[0]

                        let a_resource = split(a_attr[1], a_provider . "_")[0]
                        let a_data_or_resource = 0

												if match(a_attr[3], "^[0-9*]*$") == 0
													let a_attr_block_word = a_attr[4]
												else
													let a_attr_block_word = a_attr[3]
												endif

                        for m in terraformcomplete#rubyComplete(a:base, a_provider, a_resource, 'true', a_data_or_resource, a_attr_block_word)
                            if m.word =~ '^' . a:base
                                call add(a_res, m)
                            endif
                        endfor
                        return a_res
                    else
                      let a_provider = split(a_attr[0], "_")[0]

                      let a_resource = split(a_attr[0], a_provider . "_")[0]
                      let a_data_or_resource = 1

											if match(a_attr[2], "^[0-9*]*$") == 0
												let a_attr_block_word = a_attr[3]
											else
												let a_attr_block_word = a_attr[2]
											endif

                      for m in terraformcomplete#rubyComplete(a:base, a_provider, a_resource, 'true', a_data_or_resource, a_attr_block_word)
                        if m.word =~ '^' . a:base
                          call add(res, m)
                        endif
                      endfor
                      return res
                    endif
                elseif len(a_attr) == 6 
                    if a_attr[0] == "data"
                        let a_res = []
                        let a_provider = split(a_attr[1], "_")[0]

                        let a_resource = split(a_attr[1], a_provider . "_")[0]
                        let a_data_or_resource = 0

												if match(a_attr[4], "^[0-9*]*$") == 0
													let a_attr_block_word = a_attr[5]
												else
													let a_attr_block_word = a_attr[4]
												endif

                        for m in terraformcomplete#rubyComplete(a:base, a_provider, a_resource, 'true', a_data_or_resource, a_attr_block_word)
                            if m.word =~ '^' . a:base
                                call add(a_res, m)
                            endif
                        endfor
                        return a_res
                    endif
                else
                    return a_resource_list
                endif
            catch
                return a_resource_list
            endtry
        catch
            return a_resource_list
        endtry
    else
        try
          let s:curr_pos = getpos('.')
          let s:oldline = getline('.')
          call search('^\s*\(resource\|data\|module\)\s*"', 'b')
          if getline('.') =~ '^\s*module'
            let a_module_name = matchlist(getline("."), '^\s*module\s*"\(.*\)".*')[1]
            execute '/^\s*source.*'
            let a_line = getline(".")
            call setpos('.', s:curr_pos)
            let a_file_path = expand('%:p:h')
              ruby <<EOF
                  require "#{Vim::evaluate("s:path")}/../module"
                  include ModuleUtils
                  name = Vim::evaluate("a_module_name")
                  line = Vim::evaluate("a_line")
                  file_path = Vim::evaluate("a_file_path")
                  Vim::command("let a_res = #{load_arg_module(name, line.to_s, file_path)}")
EOF
              return a_res
          else
            if getline('.') =~ '^\s*data'
              let a_data_or_resource = 0
            else
              let a_data_or_resource = 1
            endif

            call setpos('.', s:curr_pos)
            for m in terraformcomplete#rubyComplete(a:base, a_provider, a_resource, 'false', a_data_or_resource, "")
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
  let a_old_pos = getpos('.')
  execute 'normal! gg'
  let a_search_continue = 1
  let a_list = []
  let a_source_list = {}
  if getline(".") =~ 'module\s*".*"\s*' 
      let temp = substitute(split(split(getline(1),'\s*module ')[0], ' ')[0], '"','','g')
      let a_oldpos = getpos('.')
      call search('source\s*=')
      let a_source = getline('.')
      call setpos('.', a_oldpos)
      call add(a_list, { 'word': temp })

      if has_key(a_source_list, temp) == 0
        let a_source_list[temp] = []
      endif

      call add(a_source_list[temp], a_source )
  endif
  while a_search_continue != 0

    let a_search_continue = search('module\s*".*"\s*', 'W')

    if a_search_continue != 0 
      let temp = substitute(split(split(getline(a_search_continue),'module ')[0], ' ')[0], '"','','g')
      let a_oldpos = getpos('.')
      call search('source\s*=')
      let a_source = getline(".")
      call setpos('.', a_oldpos)
      call add(a_list, { 'word': temp })

      if has_key(a_source_list, temp) == 0
        let a_source_list[temp] = []
      endif

      call add(a_source_list[temp], a_source )
    endif
  endwhile
  call setpos('.', a_old_pos)
  return [a_list, a_source_list]
endfunc

fun! terraformcomplete#GetAllRegistryModules() abort
	let res = []
	ruby <<EOF
	require 'json'
	require 'open-uri'
	modules = []
	offset = 0
	loop do
		d = JSON.parse(open("https://registry.terraform.io/v1/modules?limit=10000&offset=#{offset}").read);
		modules.push(* d["modules"])
		break if d["meta"]["next_offset"].nil?
		offset = d["meta"]["next_offset"]
	end
	puts modules.count
	data = modules.map {|m| { "word": m["id"].split("/")[0..-2].join("/") }}
	Vim::command("let res = #{JSON.generate(data)}")

EOF
	return res
endfunc

fun! terraformcomplete#GetAll(data_or_resource) abort
  let a_old_pos = getpos('.')
  execute 'normal! gg'
  let a_search_continue = 1
  let a_list = []
  let a_type_list = {}
  if getline(".") =~ '^\s*' . a:data_or_resource . '\s*"\w*"\s*"[^"]*"' 
      let temp = substitute(split(split(getline(a_search_continue),a:data_or_resource . ' ')[0], ' ')[0], '"','','g')
      call add(a_list, { 'word': temp })

      if has_key(a_type_list, temp) == 0
        let a_type_list[temp] = []
      endif

      call add(a_type_list[temp], { 'word': substitute(split(split(getline(a_search_continue), a:data_or_resource . ' ')[0], ' ')[1], '"','','g')})
  endif
  while a_search_continue != 0

    let a_search_continue = search('^\s*' . a:data_or_resource . '\s*"\w*"\s*"[^"]*"', 'W')

    if a_search_continue != 0 
      let temp = substitute(split(split(getline(a_search_continue),a:data_or_resource . ' ')[0], ' ')[0], '"','','g')
      call add(a_list, { 'word': temp })

      if has_key(a_type_list, temp) == 0
        let a_type_list[temp] = []
      endif

      call add(a_type_list[temp], { 'word': substitute(split(split(getline(a_search_continue), a:data_or_resource . ' ')[0], ' ')[1], '"','','g')})
    endif
  endwhile
  call setpos('.', a_old_pos)
	ruby <<EOF
	data_or_resource = VIM::evaluate("a:data_or_resource")
	Dir.glob('*.tf').each do |file|
	File.read(file).split("\n").map {|i| i.match(/^\s*#{data_or_resource}\s*"(\w*)"\s*"([^"]*)"/) }.compact.each do |temp|
		res = VIM::evaluate("has_key(a_type_list, \"#{temp[1]}\")")

		if res == 0
			VIM::command("let a_type_list[\"#{temp[1]}\"] = []")
		end

		
		VIM::command("call add(a_list, { 'word': \"#{temp[1]}\" })")
		VIM::command("call add(a_type_list[\"#{temp[1]}\"], { 'word': \"#{temp[2]}\"})")
		end
	end

	sorted_list =  VIM::evaluate("a_list").sort_by { |item| item['word'] }
	sorted_type_list = {}

	VIM::evaluate("a_type_list").map do |itemName, itemList| 
    sorted_type_list[itemName] =	itemList.sort_by { |item| item['word'] }
	end

	VIM::command("let a_list = #{sorted_list.to_json}")
	VIM::command("let a_type_list = #{sorted_type_list.to_json}")

EOF
  return [a_list, a_type_list]
endfunc

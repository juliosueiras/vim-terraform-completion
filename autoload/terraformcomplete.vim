if !has("ruby") && !has("ruby/dyn")
    finish
endif

let s:path = fnamemodify(resolve(expand('<sfile>:p')), ':h')

fun! terraformcomplete#GetResource()
    let s:curr_pos = getpos('.')
    if getline('.') !~# 'resource'
        execute '?resource'
    endif
    let a:provider = split(split(substitute(getline("."),'"', '', ''))[1], "_")[0]

	let a:resource = substitute(split(split(getline("."))[1], a:provider . "_")[1], '"','','')
    call setpos('.', s:curr_pos)
	return a:resource
endfun

fun! terraformcomplete#GetProvider()
    let s:curr_pos = getpos('.')
    if getline(".") !~# 'resource'
        execute '?resource'
    endif

    let a:provider = split(split(substitute(getline("."),'"', '', ''))[1], "_")[0]

    call setpos(".", s:curr_pos)
	return a:provider
endfun

function! terraformcomplete#rubyComplete(ins, provider, resource, attribute)
    let a:res = []
    let a:resource_line = getline(s:curr_pos[1]) =~ "resource"
    let a:provider_line = getline(s:curr_pos[1]) =~ "provider" 

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
            if VIM::evaluate('a:resource_line') == 1 then
                result = JSON.parse(data).keys.map { |x|
                { "word" => x }
                }
            elsif VIM::evaluate('a:attribute') == "true" then
                result = JSON.parse(data)[resource]["attributes"]
            else
                result = JSON.parse(data)[resource]["arguments"]
            end
        elsif VIM::evaluate('a:provider_line') == 1 then
            result = Dir.glob("#{VIM::evaluate('s:path')}/../provider_json/**/*.json").map { |x|
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


    if getline(".") =~ '${.*$'
      try
      let a:old_pos = getpos('.')
      execute 'normal! gg'
      let a:search_continue = 1
      let a:resource_list = []
      let a:type_list = {}
      while a:search_continue != 0
        let a:search_continue = search("resource \"", "W")

        if a:search_continue != 0
          try
            let temp_resource = substitute(split(split(getline(a:search_continue),"resource ")[0], " ")[0], '"','','g')
            call add(a:resource_list, { "word": temp_resource })

            if has_key(a:type_list, temp_resource) == 0
              let a:type_list[temp_resource] = []
            endif
            call add(a:type_list[temp_resource], { 'word': substitute(split(split(getline(a:search_continue),'resource ')[0], ' ')[1], '"','','g')})
          catch
            return []
          endtry
        endif
      endwhile
      call setpos('.', a:old_pos)
      try
        let a:curr = getline(".")
        let a:attr = split(split(a:curr, "${")[1], '\.')
        if len(a:attr) == 1
          return a:type_list[a:attr[0]]
        elseif len(a:attr) == 2
          let a:provider = split(a:attr[0], "_")[0]

          let a:resource = split(a:attr[0], a:provider . "_")[0]

          for m in terraformcomplete#rubyComplete(a:base, a:provider, a:resource, 'true')
            if m.word =~ '^' . a:base
              call add(res, m)
            endif
          endfor
          return res
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
      for m in terraformcomplete#rubyComplete(a:base, a:provider, a:resource, 'false')
        if m.word =~ '^' . a:base
          call add(res, m)
        endif
      endfor
      return res
    endif
  endif
endfun


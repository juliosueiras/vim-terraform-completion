if !has("ruby") && !has("ruby/dyn")
    finish
endif

let s:path = fnamemodify(resolve(expand('<sfile>:p')), ':h')

fun! terraformcomplete#GetResource()
    let s:curr_pos = getpos(".")
    execute '?resource'
    let a:provider = split(split(substitute(getline("."),'"', '', ''))[1], "_")[0]

	let a:resource = substitute(split(split(getline("."))[1], a:provider . "_")[1], '"','','')
    call setpos(".", s:curr_pos)
	return a:resource
endfun

fun! terraformcomplete#GetProvider()
    let s:curr_pos = getcurpos()
    execute '?resource'
    let a:provider = split(split(substitute(getline("."),'"', '', ''))[1], "_")[0]

    call setpos(".", s:curr_pos)
	return a:provider
endfun

function! terraformcomplete#rubyComplete(ins, provider, resource)
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
            else
                result = JSON.parse(data)[resource]["words"]
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

        for m in terraformcomplete#rubyComplete(a:base, a:provider, a:resource)
            if m.word =~ '^' . a:base
                call add(res, m)
            endif
        endfor
        return res
    endif
endfun


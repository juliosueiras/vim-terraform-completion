fun! terraformcomplete#GetProviderAndResource()
    let a:curr_pos = getcurpos()
    execute '?resource'
    let a:provider = split(split(substitute(getline(getcurpos()[1]),'"', '', ''))[1], "_")[0]
	let a:resource = substitute(split(split(getline(getcurpos()[1]))[1], a:provider . "_")[1], '"','','')
    let a:test_pos = getcurpos()
    call setpos(".", a:curr_pos)
	return [a:provider, a:resource]
endfun

function! terraformcomplete#rubyComplete(ins, provider, resource)
    let a:res = []
  ruby << EOF
require 'rubygems'
require 'nokogiri'         
require 'json'
require 'open-uri'

def terraform_complete(provider, resource)


  page = Nokogiri::HTML(open("https://www.terraform.io/docs/providers/#{provider}"))
  
  url = page.css("a[href*='/#{resource}']")[0]['href']

  page = Nokogiri::HTML(open("https://www.terraform.io#{url}"))

  def collect_between(first, last)
    first == last ? [first] : [first, *collect_between(first.next, last)]
  end

  @start_element = "h2[@id='argument-reference']"
  @end_element = "h2[@id='attributes-reference']"
  @arguments = page.xpath("//*[preceding-sibling::#@start_element and
                               following-sibling::#@end_element]
                         | //#@start_element | //#@end_element")


  data = []
  resource = []
  @arguments.css('ul li a').each do |x|
    if not x['name'].nil? then
		data.push(x['njame'])
    end
  end

  page.css('ul li a').each do |x|
    if not x['name'].nil? then
		if not x['name'].include? "-1" then
			resource.push({ 'word' => x['name']})
		end
    end
  end

  data.each do |x|
    resource.delete(x)
  end

  return JSON.generate(resource)
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
		let a:result = terraformcomplete#GetProviderAndResource()
        let a:provider = a:result[0]
        let a:resource = a:result[1]
        for m in terraformcomplete#rubyComplete(a:base, a:provider, a:resource)
            if m.word =~ '^' . a:base
                call add(res, m)
            endif
        endfor
        return res
    endif
endfun


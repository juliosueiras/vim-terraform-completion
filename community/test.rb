require 'nokogiri'
require 'json'
require 'rest-client'
require 'pry'

test =  Nokogiri::HTML(File.read('community-index.html'))

hrefs = test.css("table a").collect { |i| i['href'] }

community = JSON.parse(File.read("community.json"))

new_community = []

hrefs.push("https://github.com/IBM-Cloud/terraform-provider-ibm")
hrefs.compact.each do |href|
	names =  href[19..-1].split("/")

	if not Dir.exists? "/Users/fastsupport/.go/src/github.com/#{href[19..-1]}"
		`mkdir -p ~/.go/src/github.com/#{names[0]} && cd ~/.go/src/github.com/#{names[0]} && git clone #{href}`
	else
		`cd ~/.go/src/github.com/#{names[0]}/#{names[1]} && git pull`
	end

	tags = JSON.parse(RestClient.get("https://api.github.com/repos/#{names[0]}/#{names[1]}/tags?access_token=#{ENV['GITHUB_TOKEN']}"))

	tags = tags.collect {|i| i["name"]}

	if not community.find {|i| i["name"] == names[1] }.nil?
		parse_target = community.find {|i| i["name"] == names[1] }["parse_target"]
	else
		parse_target = names[1].split("-")[-1]
	end

	puts "Added #{names[1]}"
	new_community.push({
		"name": names[1],
		"owner": names[0],
		"parse_target": parse_target,
		"link": href,
		"versions": [
			"master"
		] + tags
	})
end

open("community.json", "w+") do |f|
	f << new_community.to_json
end
`cat community.json | json_pp > test.json && mv test.json community.json`

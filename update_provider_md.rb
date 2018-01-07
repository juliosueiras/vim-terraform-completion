require 'open-uri'
require 'rest-client'
require 'json'

tags_urls = File.read("tags_urls.txt").split.map {|i| i.gsub('"','') }

result = []
tags_urls.each do |tags_url|
	tags = JSON.parse(RestClient.get("#{tags_url}?access_token=#{ENV['GITHUB_TOKEN']}"))
	if not tags.empty?
		version = tags[0]["name"]
		provider = tags[0]["zipball_url"].split("/")[5].match(/terraform-provider-(.*)/)[1]
		result.push({ version: version, provider: provider })
	end
end

final = "||||||\n|---|---|---|---|---|"
result.each_slice(5) do |i|
	result = "\n|"
	i.each do |c|
		link = "https://img.shields.io/badge/style-#{c[:version]}-blue.svg?style=for-the-badge&label=#{c[:provider]}"
		result += "[![](#{link})](https://github.com/terraform-providers/terraform-provider-#{c[:provider]}/blob/master/CHANGELOG.md)|"
	end
	final += result
end
puts final

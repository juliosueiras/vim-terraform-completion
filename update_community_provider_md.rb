require 'open-uri'
require 'rest-client'
require 'json'

community = JSON.parse(File.read("community/community.json"))

result = []
community.each do |item|
	if item["versions"].count != 1
		version = item["versions"][1]
	else
		version = "master"
	end

	result.push({ version: version, provider: item["name"].split("-")[-1], link: item["link"] })
end

result = result.sort_by {|i| i[:provider] }
final = "||||||\n|---|---|---|---|---|"
result.each_slice(5) do |i|
	result = "\n|"
	i.each do |c|
		link = "https://img.shields.io/badge/style-#{c[:version]}-blue.svg?style=for-the-badge&label=#{c[:provider]}"
		result += "[![](#{link})](#{c[:link]})|"
	end
	final += result
end
puts final

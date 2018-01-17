require 'open-uri'
require 'rest-client'
require 'json'
require 'pry'

tags_urls = File.read("tags_urls.txt").split.map {|i| i.gsub('"','') }

result = []
tags_urls.each do |tags_url|
	tags = JSON.parse(RestClient.get("#{tags_url}?access_token=#{ENV['GITHUB_TOKEN']}"))
	if not tags.empty?
		tags.each do |tag|
			version = tag["name"].match("[vV](.*)")[1]
			provider = tag["zipball_url"].split("/")[5].match(/terraform-provider-(.*)/)[1]
			`echo terraform-provider-#{provider} > schemas-extractor/providers.list.full`
			`echo #{provider} > schemas-extractor/providers.list`
			`cd schemas-extractor && ./build-version.sh #{version}`
		end
	end
end

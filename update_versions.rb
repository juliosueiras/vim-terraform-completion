require 'open-uri'
require 'rest-client'
require 'json'
require 'pry'

tags_urls = File.read("tags_urls.txt").split.map {|i| i.gsub('"','') }

result = []
tags_urls.each do |tags_url|
	tags = JSON.parse(RestClient.get("#{tags_url}?access_token=#{ENV['GITHUB_TOKEN']}"))
	if not tags.empty?
		#tags.each do |tag|
		#	version = tag["name"]
		#	provider = tag["zipball_url"].split("/")[5].match(/terraform-provider-(.*)/)[1]
		#	puts version.match("[vV](.*)")[1]
		#end
		version = tags[0]["name"]
		provider = tags[0]["zipball_url"].split("/")[5].match(/terraform-provider-(.*)/)[1]

		if provider == "azure-classic"
			provider = "azure"
		end

		if provider == "google-beta"
      next
		end

		puts "#{provider}=#{version.match("[vV](.*)")[1]}"
	end
end


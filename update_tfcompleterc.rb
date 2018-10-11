Dir["provider_json/**/*.json"].each do |file|
  puts "#{file.split("/")[1]}=#{file.split("/")[2]}"
end

Dir["community_provider_json/**/*.json"].each do |file|
  puts "#{file.split("/")[1]}=#{file.split("/")[2]}"
end


File.read(".tfcompleterc").split("\n").map{|i| i.split("=") }.each do |item|
  
  `ruby generate_snippets.rb #{item[0]} schemas-extractor/schemas/#{item[0]}-#{item[1]}.json provider > snippets/terraform/#{item[0]}.snippets`
end


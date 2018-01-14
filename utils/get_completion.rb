require 'json'

inputs = ARGV[0].split(",")
resource_line = inputs[0].to_i
data_line = inputs[1].to_i
provider_line = inputs[2].to_i
spath = inputs[3]
provider_inputs = inputs[4]
resource_inputs = inputs[5]
data_or_resource = inputs[6]
block_word_inputs = inputs[7]
attribute_inputs = inputs[8]

def terraform_complete(provider, resource)
	inputs = ARGV[0].split(",")
	resource_line = inputs[0].to_i
	data_line = inputs[1].to_i
	provider_line = inputs[2].to_i
	spath = inputs[3]
	provider_inputs = inputs[4]
	resource_inputs = inputs[5]
	data_or_resource = inputs[6]
	block_word_inputs = inputs[7]
	attribute_inputs = inputs[8]

	data = ''
	if provider_line == 0 then
		File.open("#{spath}/../provider_json/#{provider}.json", "r") do |f|
			f.each_line do |line|
				data = line
			end
		end

		parsed_data = JSON.parse(data)
		block_word = block_word_inputs
		if attribute_inputs == "true" then
			if data_or_resource == 0 then
				if block_word == "" then
					result = parsed_data['datas'][resource]["attributes"]
				else
					result = parsed_data['datas'][resource]["attributes"]
					for r in result
						if r["word"] == block_word
							result = r["subblock"]
						end
					end
				end
			else
				result = parsed_data['resources'][resource]["attributes"]
			end
		elsif data_line == 1 then
			temp = parsed_data['datas'].keys
			temp.delete("provider_arguments")
			result = temp.map { |x|
				{ "word" => x }
			}
		elsif resource_line == 1 then
			temp = parsed_data['resources'].keys
			temp.delete("provider_arguments")
			result = temp.map { |x|
				{ "word" => x }
			}
		else
			if data_or_resource == 0 then
				result = parsed_data['datas'][resource]["arguments"]
			else
				result = parsed_data['resources'][resource]["arguments"]
			end
			result.concat(JSON.parse(File.read("#{spath}/../extra_json/base.json")))
		end
	elsif provider_line == 1 then
		result = Dir.glob("#{spath}/../provider_json/*.json").map { |x|
			{ "word" => x.split("../provider_json/")[1].split('.json')[0] }
		}
	end

	return JSON.generate(result)
end

result = terraform_complete(provider_inputs, resource_inputs)
puts result

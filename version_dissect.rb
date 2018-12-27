require 'json'

Dir.glob("./schemas-extractor/schemas/*.json").each do |t|
	o = t.split("./schemas-extractor/schemas/")[1].split(".json")[0].split("-")

	original_json = {"provider_arguments":[],"resources":{},"datas":{},"unknowns":{}}

	provider = o[0]
	schema_json = JSON.parse(File.read("./schemas-extractor/schemas/#{provider}-#{o[1]}.json"))

	def parse_items_attr(items, subblock)
		resources = []
		if items != nil
			items.each do |i|
					item = { 'word': i[0], 'kind': "#{i[1]['Type'].match(/Type(.*)/).captures[0]}" }
					if not i[1]["Description"].nil? then
						item[:info] = i[1]["Description"]
					end
					if not i[1]['Elem'].empty? and i[1]['Elem']['Type'] == 'SchemaInfo'
						item[:kind] += "(B)"
						item[:subblock] = parse_items_attr(i[1]['Elem']['Info'], true)
					end
					resources.push(item)
			end
		end

		if resources.select{|i| i['word'] == 'id' }.length == 0 
			resources.push({ 'word': 'id', 'kind': 'String' })
		end

		return resources
	end

	def parse_items(items)
		resources = []
		if items != nil
			items.each do |i|
				if not i[1]["Required"].nil? or not i[1]["Optional"].nil? then
					if not i[1]["Required"].nil? then
						o_or_r = "R"
					elsif not i[1]["Optional"].nil? then
						o_or_r = "O"
					end
					item = { 'word': i[0], 'kind': "#{i[1]['Type'].match(/Type(.*)/).captures[0]}(#{o_or_r})" }
					if not i[1]["Description"].nil? then
						item[:info] = i[1]["Description"]
					end

					if not i[1]['Elem'].empty? and i[1]['Elem']['Type'] == 'SchemaInfo'
						item[:kind] += "(B)"
						item[:subblock] = parse_items(i[1]['Elem']['Info'])
					end
					resources.push(item)
				end
			end
		end
		return resources
	end


	def parse_arrays(ar1, ar2) 

		ar1.pop()
		ar1 = ar1.map do |i|
			if i != nil

				i = i.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
				y = []
				ar2.delete_if {|x| y << x if i[:word] == x[:word]}
				if y != nil and not y.empty?
					# puts y
					i.merge(y[0])
				end
			end
		end

		ar1.concat(ar2)
		return ar1
	end

	original_json[:resources].map do |key, value|
		if not value["arguments"].all? {|i| i == nil }
			if key == 'vroute_entry'
				key = key[1..-1]
			end

			value['arguments'] = parse_arrays(value['arguments'],parse_items(schema_json['resources']["#{provider}_#{key}"])).compact
		else
			value["arguments"] = []
			if key == 'vroute_entry'
				key = key[1..-1]
			end

			value['arguments'] = parse_arrays(value['arguments'],parse_items(schema_json['resources']["#{provider}_#{key}"])).compact
		end

		if value['attributes'] != nil and not value["attributes"].all? {|i| i == nil }
			if key == 'vroute_entry'
				key = key[1..-1]
			end

			value['attributes'] = parse_arrays(value['attributes'],parse_items_attr(schema_json['resources']["#{provider}_#{key}"], false)).compact
		else
			value["attributes"] = []
			if key == 'vroute_entry'
				key = key[1..-1]
			end

			value['attributes'] = parse_arrays(value['attributes'],parse_items_attr(schema_json['resources']["#{provider}_#{key}"]), false).compact
		end

		schema_json['resources'].delete("#{provider}_#{key}")

	end

	if schema_json['resources'].length != 0
		schema_json['resources'].each do |key, value|
			if key != 'external' # TODO: Fix external data sources

				if original_json[:resources] == nil
					original_json[:resources] = {}
				end

				original_json[:resources][key.split("#{provider}_")[1]] = { 'arguments': parse_items(value).compact ,'attributes': parse_items_attr(value, false).compact }
			end
		end
	end

	original_json[:datas].each do |key, value|
		if not value["arguments"].all? {|i| i == nil }
			if key == 'vroute_entry'
				key = key[1..-1]
			end

			value['arguments'] = parse_arrays(value['arguments'],parse_items(schema_json['data-sources']["#{provider}_#{key}"])).compact
		else
			value["arguments"] = []
			if key == 'vroute_entry'
				key = key[1..-1]
			end

			value['arguments'] = parse_arrays(value['arguments'],parse_items(schema_json['data-sources']["#{provider}_#{key}"])).compact
		end

		if value['attributes'] != nil and not value["attributes"].all? {|i| i == nil }
			if key == 'vroute_entry'
				key = key[1..-1]
			end

			value['attributes'] = parse_arrays(value['attributes'],parse_items_attr(schema_json['data-sources']["#{provider}_#{key}"]), false).compact
		else
			value["attributes"] = []
			if key == 'vroute_entry'
				key = key[1..-1]
			end

			value['attributes'] = parse_arrays(value['attributes'],parse_items_attr(schema_json['data-sources']["#{provider}_#{key}"]), false).compact
			if provider == 'digitalocean' and key == 'application'
				binding.pry
			end
		end

		schema_json['data-sources'].delete("#{provider}_#{key}")

	end

	if schema_json['data-sources'].length != 0
		schema_json['data-sources'].each do |key, value|
			if key != 'external' # TODO: Fix external data sources

				if original_json[:datas] == nil
					original_json[:datas] = {}
				end

				original_json[:datas][key.split("#{provider}_")[1]] = { 'arguments': parse_items(value) , 'attributes': parse_items_attr(value, false).compact }
			end
		end
	end

	`mkdir -p ./provider_json/#{o[0]}/#{o[1]}`
	File.write("./provider_json/#{o[0]}/#{o[1]}/#{o[0]}.json",JSON.generate(original_json))
end

Dir.glob("./schemas-extractor/community_schemas/*.json").each do |t|
	o = t.split("./schemas-extractor/community_schemas/")[1].split(".json")[0].split("-")

	original_json = {"provider_arguments":[],"resources":{},"datas":{},"unknowns":{}}

	provider = o[0]
	schema_json = JSON.parse(File.read("./schemas-extractor/community_schemas/#{provider}-#{o[1]}.json"))

	def parse_items_attr(items, subblock)
		resources = []
		if items != nil
			items.each do |i|
					item = { 'word': i[0], 'kind': "#{i[1]['Type'].match(/Type(.*)/).captures[0]}" }
					if not i[1]["Description"].nil? then
						item[:info] = i[1]["Description"]
					end
					if not i[1]['Elem'].empty? and i[1]['Elem']['Type'] == 'SchemaInfo'
						item[:kind] += "(B)"
						item[:subblock] = parse_items_attr(i[1]['Elem']['Info'], true)
					end
					resources.push(item)
			end
		end

		if resources.select{|i| i['word'] == 'id' }.length == 0 
			resources.push({ 'word': 'id', 'kind': 'String' })
		end

		return resources
	end

	def parse_items(items)
		resources = []
		if items != nil
			items.each do |i|
				if not i[1]["Required"].nil? or not i[1]["Optional"].nil? then
					if not i[1]["Required"].nil? then
						o_or_r = "R"
					elsif not i[1]["Optional"].nil? then
						o_or_r = "O"
					end
					item = { 'word': i[0], 'kind': "#{i[1]['Type'].match(/Type(.*)/).captures[0]}(#{o_or_r})" }
					if not i[1]["Description"].nil? then
						item[:info] = i[1]["Description"]
					end

					if not i[1]['Elem'].empty? and i[1]['Elem']['Type'] == 'SchemaInfo'
						item[:kind] += "(B)"
						item[:subblock] = parse_items(i[1]['Elem']['Info'])
					end
					resources.push(item)
				end
			end
		end
		return resources
	end


	def parse_arrays(ar1, ar2) 

		ar1.pop()
		ar1 = ar1.map do |i|
			if i != nil

				i = i.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
				y = []
				ar2.delete_if {|x| y << x if i[:word] == x[:word]}
				if y != nil and not y.empty?
					# puts y
					i.merge(y[0])
				end
			end
		end

		ar1.concat(ar2)
		return ar1
	end

	original_json[:resources].map do |key, value|
		if not value["arguments"].all? {|i| i == nil }
			if key == 'vroute_entry'
				key = key[1..-1]
			end

			value['arguments'] = parse_arrays(value['arguments'],parse_items(schema_json['resources']["#{provider}_#{key}"])).compact
		else
			value["arguments"] = []
			if key == 'vroute_entry'
				key = key[1..-1]
			end

			value['arguments'] = parse_arrays(value['arguments'],parse_items(schema_json['resources']["#{provider}_#{key}"])).compact
		end

		if value['attributes'] != nil and not value["attributes"].all? {|i| i == nil }
			if key == 'vroute_entry'
				key = key[1..-1]
			end

			value['attributes'] = parse_arrays(value['attributes'],parse_items_attr(schema_json['resources']["#{provider}_#{key}"], false)).compact
		else
			value["attributes"] = []
			if key == 'vroute_entry'
				key = key[1..-1]
			end

			value['attributes'] = parse_arrays(value['attributes'],parse_items_attr(schema_json['resources']["#{provider}_#{key}"]), false).compact
		end

		schema_json['resources'].delete("#{provider}_#{key}")

	end

	if schema_json['resources'].length != 0
		schema_json['resources'].each do |key, value|
			if key != 'external' # TODO: Fix external data sources

				if original_json[:resources] == nil
					original_json[:resources] = {}
				end

				original_json[:resources][key.split("#{provider}_")[1]] = { 'arguments': parse_items(value).compact ,'attributes': parse_items_attr(value, false).compact }
			end
		end
	end

	original_json[:datas].each do |key, value|
		if not value["arguments"].all? {|i| i == nil }
			if key == 'vroute_entry'
				key = key[1..-1]
			end

			value['arguments'] = parse_arrays(value['arguments'],parse_items(schema_json['data-sources']["#{provider}_#{key}"])).compact
		else
			value["arguments"] = []
			if key == 'vroute_entry'
				key = key[1..-1]
			end

			value['arguments'] = parse_arrays(value['arguments'],parse_items(schema_json['data-sources']["#{provider}_#{key}"])).compact
		end

		if value['attributes'] != nil and not value["attributes"].all? {|i| i == nil }
			if key == 'vroute_entry'
				key = key[1..-1]
			end

			value['attributes'] = parse_arrays(value['attributes'],parse_items_attr(schema_json['data-sources']["#{provider}_#{key}"]), false).compact
		else
			value["attributes"] = []
			if key == 'vroute_entry'
				key = key[1..-1]
			end

			value['attributes'] = parse_arrays(value['attributes'],parse_items_attr(schema_json['data-sources']["#{provider}_#{key}"]), false).compact
			if provider == 'digitalocean' and key == 'application'
				binding.pry
			end
		end

		schema_json['data-sources'].delete("#{provider}_#{key}")

	end

	if schema_json['data-sources'].length != 0
		schema_json['data-sources'].each do |key, value|
			if key != 'external' # TODO: Fix external data sources

				if original_json[:datas] == nil
					original_json[:datas] = {}
				end

				original_json[:datas][key.split("#{provider}_")[1]] = { 'arguments': parse_items(value) , 'attributes': parse_items_attr(value, false).compact }
			end
		end
	end

	`mkdir -p ./community_provider_json/#{o[0]}/#{o[1]}`
	File.write("./community_provider_json/#{o[0]}/#{o[1]}/#{o[0]}.json",JSON.generate(original_json))
end

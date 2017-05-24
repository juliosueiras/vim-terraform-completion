require 'json'
require 'pry'

Dir.glob("./provider_json/*.json").each do |o| 
  original_json = JSON.parse(File.read(o))
  provider = o.split('/')[-1].split('.json')[0]
  schema_json = JSON.parse(File.read("./schema_json/#{provider}.json"))

  def parse_items_attr(items)
    resources = []
    if items != nil
      items.each do |i|
          item = { 'word': i[0], 'kind': "#{i[1][0]['value'].match(/Type(.*)/).captures[0]}" }
          if i[1][-1]['value'].class == Hash
            item[:kind] += "(B)"
            item[:subblock] = parse_items(i[1][-1]['value'])
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
        if (i[1].select {|x| x['name'] == 'Required' or x['name'] == 'Optional' }).length != 0
          item = { 'word': i[0], 'kind': "#{i[1][0]['value'].match(/Type(.*)/).captures[0]}(#{i[1][1]['name'][0]})" }
          if i[1][-1]['value'].class == Hash
            item[:kind] += "(B)"
            item[:subblock] = parse_items(i[1][-1]['value'])
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

  original_json['resources'].map do |key, value|
    if not value["arguments"].all? {|i| i == nil }
      if key == 'vroute_entry'
        key = key[1..-1]
      end

      value['arguments'] = parse_arrays(value['arguments'],parse_items(schema_json['resources']["#{provider}_#{key}"]))
    else
      value["arguments"] = []
      if key == 'vroute_entry'
        key = key[1..-1]
      end

      value['arguments'] = parse_arrays(value['arguments'],parse_items(schema_json['resources']["#{provider}_#{key}"]))
    end

    if value['attributes'] != nil and not value["attributes"].all? {|i| i == nil }
      if key == 'vroute_entry'
        key = key[1..-1]
      end

      value['attributes'] = parse_arrays(value['attributes'],parse_items_attr(schema_json['resources']["#{provider}_#{key}"]))
    else
      value["attributes"] = []
      if key == 'vroute_entry'
        key = key[1..-1]
      end

      value['attributes'] = parse_arrays(value['attributes'],parse_items_attr(schema_json['resources']["#{provider}_#{key}"]))
    end

    schema_json['resources'].delete("#{provider}_#{key}")

  end

  if schema_json['resources'].length != 0
    schema_json['resources'].each do |key, value|
      if key != 'external' # TODO: Fix external data sources

        if original_json['resources'] == nil
          original_json['resources'] = {}
        end

        original_json['resources'][key.split("#{provider}_")[1]] = { 'arguments': parse_items(value) }
        puts key
      end
    end
  end

  original_json['datas'].each do |key, value|
    if not value["arguments"].all? {|i| i == nil }
      if key == 'vroute_entry'
        key = key[1..-1]
      end

      value['arguments'] = parse_arrays(value['arguments'],parse_items(schema_json['data-sources']["#{provider}_#{key}"]))
    else
      value["arguments"] = []
      if key == 'vroute_entry'
        key = key[1..-1]
      end

      value['arguments'] = parse_arrays(value['arguments'],parse_items(schema_json['data-sources']["#{provider}_#{key}"]))
    end

    if value['attributes'] != nil and not value["attributes"].all? {|i| i == nil }
      if key == 'vroute_entry'
        key = key[1..-1]
      end

      value['attributes'] = parse_arrays(value['attributes'],parse_items_attr(schema_json['data-sources']["#{provider}_#{key}"]))
    else
      value["attributes"] = []
      if key == 'vroute_entry'
        key = key[1..-1]
      end

      value['attributes'] = parse_arrays(value['attributes'],parse_items_attr(schema_json['data-sources']["#{provider}_#{key}"]))
    end

    schema_json['data-sources'].delete("#{provider}_#{key}")

  end

  if schema_json['data-sources'].length != 0
    schema_json['data-sources'].each do |key, value|
      if key != 'external' # TODO: Fix external data sources

        if original_json['datas'] == nil
          original_json['datas'] = {}
        end

        original_json['datas'][key.split("#{provider}_")[1]] = { 'arguments': parse_items(value) }
      end
    end
  end

  File.write(o,JSON.generate(original_json))
end

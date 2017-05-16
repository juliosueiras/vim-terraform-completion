require 'json'
require 'pry'

Dir.glob("./provider_json/*.json").each do |o| 
  original_json = JSON.parse(File.read(o))
  schema_json = JSON.parse(File.read("./schema_json/#{o.split('/')[-1]}"))

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
    if value["arguments"][0] != nil
      if key == 'vroute_entry'
        value['arguments'] = parse_arrays(value['arguments'],parse_items(schema_json['resources']["#{value['provider']}_#{key[1..-1]}"]))
      else
        value['arguments'] = parse_arrays(value['arguments'],parse_items(schema_json['resources']["#{value['provider']}_#{key}"]))
      end
    end
  end

  original_json['datas'].each do |key, value|
    if value["arguments"][0] != nil
      if key == 'vroute_entry'
        value['arguments'] = parse_arrays(value['arguments'],parse_items(schema_json['data-sources']["#{value['provider']}_#{key[1..-1]}"]))
      else
        value['arguments'] = parse_arrays(value['arguments'],parse_items(schema_json['data-sources']["#{value['provider']}_#{key}"]))
      end
    end
  end

  File.write(o,JSON.generate(original_json))

end

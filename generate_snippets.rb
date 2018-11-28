require 'json'
require 'pry'


def get_snippets(args)
  return args.select{|i, v| v.keys.include? "Required" and v["Required"] }.map do |arg, value|
    case value["Type"]
    when "TypeString"
      "\t#{arg} = \"\""
    when "TypeInt"
      "\t#{arg} = 1"
    when "TypeFloat"
      "\t#{arg} = 1.0"
    when "TypeBool"
      "\t#{arg} = false"
    when "TypeList", "TypeSet", "TypeMap"
      if not value["Elem"]["ElementsType"].nil?
        case value["Elem"]["ElementsType"]
        when "TypeString"
          "\t#{arg} = [\"\"]"
        when "TypeInt"
          "\t#{arg} = [1]"
        when "TypeFloat"
          "\t#{arg} = [1.0]"
        when "TypeMap"
          snippet_result = "\t#{arg} {\n"
          snippet_result += "\n\t\t\t}"
          snippet_result
        else
          require 'pry'; binding.pry
        end
      else
        snippet_result = "\t#{arg} {\n"
        if not value["Elem"].empty?
          case value["Elem"]["Type"]
          when "SchemaInfo"
            snippet_result += "\t\t\t" + get_snippets(value["Elem"]["Info"]).join("\n\t\t\t")
          when "schema.ValueType", "SchemaElements"
          else
            require 'pry'; binding.pry
          end
        end
        snippet_result += "\n\t\t\t}"
        snippet_result
      end
    else
      require 'pry'; binding.pry
    end
  end
end

result = JSON.parse(File.read(ARGV[1]))

dicts = [ARGV[0]]

provider_args = result["provider"].select{|i, v| v.keys.include? "Required" and v["Required"] }

current = 0
provider_args = provider_args.map do |i,v|
  current += 1
  case v["Type"]
  when "TypeString"
    "#{i} = \"${#{current}}\""
  when "TypeInt"
    "#{i} = ${#{current}}"
  when "TypeFloat"
    "#{i} = ${#{current}}"
  when "TypeBool"
    "#{i} = ${#{current}:false}"
  else
    require 'pry'; binding.pry
  end
end
current = 0

snippets =<<EOF
snippet #{ARGV[0]}
\tprovider "#{ARGV[0]}" {
\t\t#{provider_args.join("\n\t\t")}
\t}
EOF

result["resources"].each do |i, v|
  args = v.select{|l, m| m.keys.include? "Required" and m["Required"] }

  current = 1
  args = args.map do |o,p|
    current += 1
    case p["Type"]
    when "TypeString"
      "#{o} = \"${#{current}}\""
    when "TypeInt"
      "#{o} = ${#{current}}"
    when "TypeFloat"
      "#{o} = ${#{current}}"
    when "TypeBool"
      "#{o} = ${#{current}:false}"
    when "TypeList", "TypeSet", "TypeMap"
      if not p["Elem"]["ElementsType"].nil?
        case p["Elem"]["ElementsType"]
        when "TypeString"
          "#{o} = [\"${#{current}}\"]"
        when "TypeInt"
          "#{o} = [${#{current}}]"
        when "TypeFloat"
          "#{o} = [${#{current}}]"
        when "TypeMap"
          snippet_result = "\t#{o} {\n"
          snippet_result += "\n\t\t\t}"
          snippet_result
        else
          require 'pry'; binding.pry
        end
      else
        snippet_result = "#{o} {\n"
        if not p["Elem"].empty?
          case p["Elem"]["Type"]
          when "SchemaInfo"
            snippet_result += "\t\t" + get_snippets(p["Elem"]["Info"]).join("\n\t\t")
          when "schema.ValueType", "SchemaElements"
          else
            require 'pry'; binding.pry
          end
        end
        snippet_result += "\n\t\t}"
        snippet_result
      end
    else
      require 'pry'; binding.pry
    end
  end
#
dicts.push("r_#{i}")
snippets +=<<EOF
snippet r_#{i}
\tresource "#{i}" "${1}" {
\t\t#{args.join("\n\t\t")}
\t}
EOF
end

result["data-sources"].each do |i, v|
  args = v.select{|l, m| m.keys.include? "Required" and m["Required"] }

  current = 1
  args = args.map do |o,p|
    current += 1
    case p["Type"]
    when "TypeString"
      "#{o} = \"${#{current}}\""
    when "TypeInt"
      "#{o} = ${#{current}}"
    when "TypeFloat"
      "#{o} = ${#{current}}"
    when "TypeBool"
      "#{o} = ${#{current}:false}"
    when "TypeList", "TypeSet", "TypeMap"
      if not p["Elem"]["ElementsType"].nil?
        case p["Elem"]["ElementsType"]
        when "TypeString"
          "#{o} = [\"${#{current}}\"]"
        when "TypeInt"
          "#{o} = [${#{current}}]"
        when "TypeFloat"
          "#{o} = [${#{current}}]"
        when "TypeMap"
          snippet_result = "\t#{o} {\n"
          snippet_result += "\n\t\t\t}"
          snippet_result
        else
          require 'pry'; binding.pry
        end
      else
        snippet_result = "#{o} {\n"
        if not p["Elem"].empty?
          case p["Elem"]["Type"]
          when "SchemaInfo"
            snippet_result += "\t\t\t" + get_snippets(p["Elem"]["Info"]).join("\n\t\t\t")
          when "schema.ValueType", "SchemaElements"
          else
            require 'pry'; binding.pry
          end
        end
        snippet_result += "\n\t\t\t}"
        snippet_result
      end
    else
      require 'pry'; binding.pry
    end
  end
#

dicts.push("d_#{i}")
snippets +=<<EOF
snippet d_#{i}
\tdata "#{i}" "${1}" {
\t\t#{args.join("\n\t\t")}
\t}
EOF
end
  
  
File.write("dicts/#{ARGV[2]}_#{ARGV[0]}.dicts", dicts.join("\n"))
puts snippets

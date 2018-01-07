#!/usr/bin/env ruby
require 'json'
require 'open-uri'
require "net/http"
require 'digest'

module ModuleUtils
  def parse_link(name, source)
	  source_raw = source.match(/"(.*)"/).captures()[0]
    if source_raw.start_with?"./"
      link = source_raw
    else
			modules = JSON.parse(File.read("./.terraform/modules/modules.json"))
			modules["Modules"].each do |m|
				if m["Source"] == source_raw
					link = "#{m["Dir"]}/#{m["Root"]}"
				end
			end
    end
    return link
  end

  def load_arg_module(name, source, path)

    link = parse_link(name, source)

    variables = ''
    result = []

		['main.tf', 'config.tf', 'inputs.tf', 'variables.tf', 'vars.tf'].each do |i|
      if File.exist? "#{path}/#{link}/#{i}"
				puts "#{path}/#{link}/#{i}"
        variables = open("#{path}/#{link}/#{i}").read.split("\n").select { |x| x[/^variable/]}
        variables.each do |x|
          result.push({ "word": x.match(/variable\s*"?([A-Za-z0-9_-]*)"?\s*{/).captures()[0] })
        end
      end
    end

    return JSON.generate(result)
  end

  def load_attr_module(name,source, path)
    link = parse_link(name, source)

    variables = ''
    result = []

    ['main.tf', 'outputs.tf'].each do |i|
      if File.exist?"#{path}/#{link}/#{i}"
        variables = open("#{path}/#{link}/#{i}").read.split("\n").select { |x| x[/^output/]}
        variables.each do |x|
          result.push({ "word": x.match(/output\s*"?([A-Za-z0-9_-]*)"?\s*{/).captures()[0] })
        end
      end
    end

    return JSON.generate(result)
  end
end

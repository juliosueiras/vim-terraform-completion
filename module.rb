#!/usr/bin/env ruby
require 'json'
require 'open-uri'
require "net/http"
require 'digest'
require 'pry'

module ModuleUtils
  def parse_link(name, source)
	  source_raw = source.match(/"(.*)"/).captures()[0]
    if source_raw.start_with?"./"
      link = source_raw
    else
      hash_module = Digest::MD5.hexdigest "module.#{name}-#{source_raw}"
      if source_raw.split("/").length >= 4
        link = "./.terraform/modules/#{hash_module}"
        source_raw.split('/')[3..-1].each do |i| 
          link += "/#{i}"
        end
      else
        link = "./.terraform/modules/#{hash_module}"
      end
    end
    return link
  end

  def load_arg_module(name, source, path)

    link = parse_link(name, source)

    variables = ''
    result = []

    ['main.tf', 'inputs.tf', 'variables.tf'].each do |i|
      if File.exist? "#{path}/#{link}/#{i}"
        variables = open("#{path}/#{link}/#{i}").read.split("\n").select { |x| x[/variable/]}
        variables.each do |x|
          result.push({ "word": x.match(/"(.*)"/).captures()[0] })
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
        variables = open("#{path}/#{link}/#{i}").read.split("\n").select { |x| x[/output/]}
        variables.each do |x|
          result.push({ "word": x.match(/"(.*)"/).captures()[0] })
        end
      end
    end

    return JSON.generate(result)
  end
end

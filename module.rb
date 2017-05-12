#!/usr/bin/env ruby
require 'json'
require 'open-uri'
require "net/http"
require 'digest'

module ModuleUtils
  def load_arg_module(name, source, path)
    source_raw = source.match(/"(.*)"/).captures()[0]

    if source_raw.start_with?"github"
      hash_module = Digest::MD5.hexdigest "root.#{name}-#{source_raw}"
      puts hash_module
      link = "./.terraform/modules/#{hash_module}"
    else
      link = source_raw
    end

    variables = ''
    result = []

    ['main.tf', 'inputs.tf', 'variables.tf'].each do |i|
      if File.exist?"#{path}/#{link}/#{i}"
        variables = open("#{path}/#{link}/#{i}").read.split("\n").select { |x| x[/variable/]}
        variables.each do |x|
          result.push({ "word": x.match(/"(.*)"/).captures()[0] })
        end
      end
    end

    return JSON.generate(result)
  end

  def load_attr_module(name,source, path)
    source_raw = source.match(/"(.*)"/).captures()[0]

    if source_raw.start_with?"github"
      hash_module = Digest::MD5.hexdigest "root.#{name}-#{source_raw}"
      puts hash_module
      link = "./.terraform/modules/#{hash_module}"
    else
      link = source_raw
    end

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


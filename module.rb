#!/usr/bin/env ruby
require 'json'
require 'open-uri'
require "net/http"

module ModuleUtils
  def load_arg_module(source, path)
    source_raw = source.match(/"(.*)"/).captures()[0]

    if source_raw.start_with?"github"
      link = 'https://raw.githubusercontent.com'
      source = source_raw.split('/')[1..-1]
      source.each_index do |x|
        if x == 2
          link += "/master/#{source[x]}"
        else 
          link += "/#{source[x]}"
        end
      end

      if source.length == 2
        link += "/master"
      end
    else
      link = source_raw
    end

    variables = ''
    result = []
    ['main.tf', 'inputs.tf', 'variables.tf'].each do |i|
      if link.start_with?"http" 
        url = URI.parse("#{link}/#{i}")
        req = Net::HTTP.new(url.host, url.port)
        req.use_ssl = true if url.scheme == 'https'
        res = req.request_head(url.path)
        if not res.code == "404" 
          variables = open("#{link}/#{i}").read.split("\n").select { |x| x[/^\s*variable\s*"/]}
          variables.each do |x|
            result.push({ "word": x.match(/"(.*)"/).captures()[0] })
          end
        end
      else
        if File.exist?"#{path}/#{link}/#{i}"
          variables = open("#{path}/#{link}/#{i}").read.split("\n").select { |x| x[/variable/]}
          variables.each do |x|
            result.push({ "word": x.match(/"(.*)"/).captures()[0] })
          end
        end
      end
    end

    return JSON.generate(result)
  end

  def load_attr_module(source, path)
    source_raw = source.match(/"(.*)"/).captures()[0]

    if source_raw.start_with?"github"
      link = 'https://raw.githubusercontent.com'
      source = source_raw.split('/')[1..-1]
      source.each_index do |x|
        if x == 2
          link += "/master/#{source[x]}"
        else 
          link += "/#{source[x]}"
        end
      end

      if source.length == 2
        link += "/master"
      end
    else
      link = source_raw
    end

    variables = ''
    result = []
    ['main.tf', 'outputs.tf'].each do |i|
      if link.start_with?"http" 
        url = URI.parse("#{link}/#{i}")
        req = Net::HTTP.new(url.host, url.port)
        req.use_ssl = true if url.scheme == 'https'
        res = req.request_head(url.path)
        if not res.code == "404" 
          variables = open("#{link}/#{i}").read.split("\n").select { |x| x[/^\s*output\s*"/]}
          variables.each do |x|
            result.push({ "word": x.match(/"(.*)"/).captures()[0] })
          end
        end
      else
        if File.exist?"#{path}/#{link}/#{i}"
          variables = open("#{path}/#{link}/#{i}").read.split("\n").select { |x| x[/output/]}
          variables.each do |x|
            result.push({ "word": x.match(/"(.*)"/).captures()[0] })
          end
        end
      end
    end

    return JSON.generate(result)
  end
end

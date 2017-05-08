#!/usr/bin/env ruby
require 'json'
require 'open-uri'
require "net/http"

module ModuleUtils
  def load_arg_module(source)
    source = source.match(/"(.*)"/).captures()[0].split('/')[1..-1]
    link = 'https://raw.githubusercontent.com'
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
    variables = ''
    ['inputs.tf', 'variables.tf'].each do |i|
      url = URI.parse("#{link}/#{i}")
      req = Net::HTTP.new(url.host, url.port)
      req.use_ssl = true if url.scheme == 'https'
      res = req.request_head(url.path)

      if not res.code == "404" 
        variables = open("#{link}/#{i}").read.split("\n").select { |x| x[/variable/]}
      end
    end
    res = []
    variables.each do |x|
      res.push({ "word": x.match(/"(.*)"/).captures()[0] })
    end

    return JSON.generate(res)
  end
end

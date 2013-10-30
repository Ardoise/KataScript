#! /usr/bin/env ruby

require 'rubygems'
require 'active_support/core_ext'
require 'json'

xml = File.open(ARGV.first).read
json = Hash.from_xml(xml).to_json
File.open(ARGV.last, 'w+').write json
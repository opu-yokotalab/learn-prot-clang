#!/bin/env ruby
require 'net/http'
require "kconv"
Net::HTTP.version_1_2   # おまじない
Net::HTTP.start(ARGV[0], 80) {|http|
  response = http.get(ARGV[1])

#  File.open("tmp.zip", "w"){|file|
#    file.binmode
#    file.write response.body
#  }

  puts Kconv.kconv(response.body, Kconv::EUC)
}

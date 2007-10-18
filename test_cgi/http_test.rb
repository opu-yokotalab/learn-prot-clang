#!/usr/bin/env ruby
require 'net/http'

require 'kconv'

Net::HTTP.version_1_2   # おまじない
Net::HTTP.start("localhost", 80) {|http|
  response = http.post("/~t_nishi/cgi-bin/prot_clang/test_cgi.cgi", 
                       "msg=test",
                       {"Content-Type" => "application/x-www-form-urlencoded"}
                       )
  puts Kconv.kconv(response.body, Kconv::EUC)
}


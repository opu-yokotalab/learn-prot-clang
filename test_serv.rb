#!/usr/bin/env ruby
#-- List6 lengthsrv.rb:
require 'socket'

port = 7123                    #1

gs = TCPServer.open(port)      #2
while true                     #3
  ns = gs.accept               #4
  p ns.peeraddr
  Thread.start(ns) do |s|      #5
    while l = s.gets
      break if /^q/i =~ l
      s.write "S: (%d)%s\n" %
        [l.size, l.inspect]
    end
    s.close
  end
end

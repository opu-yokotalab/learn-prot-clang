#!/usr/bin/env ruby
# ソケットを用いたプロセス間通信の実験

require 'socket'

port = 7123


gs = TCPServer.open(port)
while true
  ns = gs.accept
  p ns.peeraddr
  Thread.start(ns) do |s|
    while l = s.gets
      break if /^q/i =~ l
      s.write "S: (%d)%s\n" %
        [l.size, l.inspect]
    end
    s.close
  end
end

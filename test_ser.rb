#!/usr/bin/env ruby
# �����åȤ��Ѥ����ץ������̿��μ¸�

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

#!/bin/env ruby
require 'net/http'
require "kconv"

port = 7300

# ���ꤷ���ݡ��Ȥ��Ԥ���������
gs = TCPServer.open(port)
while true
  ns = gs.accept
  p ns.peeraddr

  # ����åɤ��Ѥ����Ԥ�����
  Thread.start(ns) do |s|
    while l = s.gets
      break if /^q/i =~ l

      # �ǥХå���
      puts "l: " + l

      # ��å����������Ƽ�����äƤ����������
      if l == "EOF" then
        puts "get EOF"
        puts ""
        puts msgGetBuf
        puts ""

        Net::HTTP.version_1_2   # ���ޤ��ʤ�
        Net::HTTP.start(ARGV[0], 80) {|http|
          response = http.post(ARGV[1], 
                               msgGetBuf,
                               {"Content-Type" => "application/x-www-form-urlencoded"}
                               )
        }

        msgGetBuf = "" # ��å������ν����
      else
        # �Хåե��˥�å����������Ҥ�����
        msgGetBuf = msgGetBuf + l
      end
    end
    # ����
    puts "close."
    s.close
  end
end


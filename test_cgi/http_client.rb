#!/bin/env ruby
require 'net/http'
require "kconv"

port = 7300

# 指定したポートで待ち受け開始
gs = TCPServer.open(port)
while true
  ns = gs.accept
  p ns.peeraddr

  # スレッドを用いた待ち受け
  Thread.start(ns) do |s|
    while l = s.gets
      break if /^q/i =~ l

      # デバッグ用
      puts "l: " + l

      # メッセージを全て受け取ってから処理開始
      if l == "EOF" then
        puts "get EOF"
        puts ""
        puts msgGetBuf
        puts ""

        Net::HTTP.version_1_2   # おまじない
        Net::HTTP.start(ARGV[0], 80) {|http|
          response = http.post(ARGV[1], 
                               msgGetBuf,
                               {"Content-Type" => "application/x-www-form-urlencoded"}
                               )
        }

        msgGetBuf = "" # メッセージの初期化
      else
        # バッファにメッセージの断片を蓄積
        msgGetBuf = msgGetBuf + l
      end
    end
    # 切断
    puts "close."
    s.close
  end
end


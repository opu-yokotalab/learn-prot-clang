#!/bin/env ruby
require 'net/http'
require 'kconv'
require 'cgi'

port = 7300

# 受信用バッファ
msgGetBuf = String.new

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
#      puts "l: " + l

      # メッセージを全て受け取ってから処理開始
      if l == "EOF" then
        puts "get EOF"
        puts ""
        puts CGI.escape(msgGetBuf)
        puts ""

        Net::HTTP.version_1_2   # おまじない
        Net::HTTP.start("localhost", 80) {|http|
          response = http.post("/~t_nishi/cgi-bin/prot_clang/test_cgi.cgi", 
                               "mode=import&msg=" + CGI.escape(msgGetBuf),
                               {"Content-Type" => "application/x-www-form-urlencoded"}
                               )
          puts Kconv.kconv(response.body, Kconv::EUC)
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


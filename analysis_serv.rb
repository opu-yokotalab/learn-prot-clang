#!/usr/bin/env ruby
# エラーメッセージを受け取ってXMLに整形するモジュール
# ソケットによるプロセス間通信から利用するバージョン

# ソケット
require 'socket'
# REXML
require "rexml/document"
# 文字コード変換
require "kconv"

# リスニングポート
port = 7120

class TransError
  
  # XML操作
  include REXML
  
  # 初期化
  def initialize(msgTmp)
    @msg = msgTmp
  end
  
  # コンパイルエラー
  def transCmpError(msgTmp)

    # 処理するエラーメッセージ
    @msg = msgTmp

    cmpMsgElem = REXML::Element.new("compiler_messages") # 返却するXML
    
    bufAry =  Array.new # 分割した情報の一時格納先
    
    xmlput_flag = false # XML出力フラグ
    errDes = String.new # エラーの内容
    errSts = String.new # エラー、ワーニングの区別
    errSrc = String.new # ソースコード
    errLine = String.new # 行番号
    errFunc = String.new # 関数名
    
    errAry = Array.new # メッセージを格納する配列
    buf = String.new # メッセージを格納する一時バッファ
    bufLine = String.new # ファイルから読み込んだ行から改行を削除
    #log_flag = false # バッファ取り込み用フラグ
    
    err_flag = false # エラーメッセージ整形用
    
    # 引数の検査
    if @msg == nil then
      # Elemntオブジェクトの生成
      sysMsgElem = REXML::Element.new("system_message")
      sysMsgElem.add_text(Kconv.kconv("引数が不正です.", Kconv::UTF8))
      
      # ルートノードに追加
      cmpMsgElem.add_element(sysMsgElem)
    else
      begin
           @msg.each_line {|line|
            
            # 扱いやすいように改行を削除
            bufLine = line.chomp
            
            # 要素数2の時は、開始行か未定義エラー?
            if bufLine.split(":").size == 2 then
              # エラーメッセージ開始行
              # 要素数が2かつ要素1が空ではない場合は開始行ではない?
              if bufLine.split(":")[0] != "" then
                # バッファが空ではない
                # if buf != "" then
                errAry << buf.chomp.split("\n")
                buf = ""
                #   log_flag = false
                # end              
                # log_flag = true
              end
            end
            
            # 開始行からバッファに取り込む
            # if log_flag == true then
            buf = buf + line
            # end
          }
          errAry << buf.chomp.split("\n")        

      rescue # 例外
        # Elemntオブジェクトの生成
        sysMsgElem = REXML::Element.new("system_message")
        sysMsgElem.add_text(Kconv.kconv("例外が発生しました.", Kconv::UTF8))
        
        # ルートノードに追加
        cmpMsgElem.add_element(sysMsgElem)
      end
    end
    
    # テスト出力
    #p errAry
    
    # 配列数の検査
    if errAry.size == 0 then
      # Elemntオブジェクトの生成
      sysMsgElem = REXML::Element.new("system_message")
      sysMsgElem.add_text(Kconv.kconv("エラーメッセージが読み込まれていません.", Kconv::UTF8))
      
      # ルートノードに追加
      cmpMsgElem.add_element(sysMsgElem)
    else
      # 複数のエラーメッセージに対して操作
      errAry.each{|errElemAry|
        # 配列数の検査
        if errElemAry.size == 0 then
          # Elemntオブジェクトの生成
          sysMsgElem = REXML::Element.new("system_message")
          sysMsgElem.add_text(Kconv.kconv("エラーメッセージが空です.", Kconv::UTF8))
          
          # ルートノードに追加
          cmpMsgElem.add_element(sysMsgElem)
        else
          # デバッガのメッセージみたいに行数まで固定ではない(多分)ので、
          # 各配列にたいして操作
          errElemAry.each{|errMsg|
            # テスト出力
            #p errMsg
            
            # ":"でスプリット
            bufAry = errMsg.split(":")
            
            # オブジェクトの初期化
            msgElem = REXML::Element.new("message")
            desElem = REXML::Element.new("description")
            fncElem = REXML::Element.new("function")
            srcElem = REXML::Element.new("source")
            
            # 配列の要素数に応じて処理の分岐
            if bufAry.size == 2 then
              if bufAry[0] != "" then 
                # ひとつの関数内で起きたエラーごとにまとめる
                xmlput_flag = false # 関数内が決定しただけではXML出力しない
                tmpFnc = bufAry[1].match(/^\s+In\s+function\s+`(\w+)'/)
                if tmpFnc != nil then
                  # 関数名がある
                  errFunc = tmpFnc.captures.to_s
                  errSrc = bufAry[0]
                else
                  # 関数名が無い(関数外など)
                  errFunc = bufAry[1].scan(/^\s+(.*)/).to_s
                  errSrc = bufAry[0]
                end
                # テスト出力
                #p errFnc
                
              else
                tmpDes = bufAry[1].match(/^\s+(.*)/)
                if tmpDes != nil then
                  errDes = tmpDes.captures.to_s
                  errSts = "error" # 本当はerrorの出力は無いけど付け足し
                  xmlput_flag = true # xml出力を許可
                  
                  # テスト出力
                  #p errDes
                end
              end
            else # 要素数4
              errSrc = bufAry[0]
              errLine = bufAry[1]
              errSts = bufAry[2].scan(/^\s+(.*)/).to_s
              errDes = bufAry[3].scan(/^\s+(.*)/).to_s
              
              xmlput_flag = true # XML出力を許可
            end
            
            # テスト出力
            #p errFunc
            #p errSrc
            #p errLine
            #p errSts
            #p errDes
            #puts "\n"
            
            if xmlput_flag == true then
              # 取得した情報からXMLを生成
              # Elemntオブジェクトの生成
              msgElem.add_attribute("line", errLine)
              msgElem.add_attribute("status", errSts)
              
              # テキストノードの追加
              desElem.add_text(errDes)
              fncElem.add_text(errFunc)
              srcElem.add_text(errSrc)
              
              # message要素に子要素を追加
              msgElem.add_element(desElem)
              msgElem.add_element(fncElem)
              msgElem.add_element(srcElem)
              
              # debugger_messages要素に子要素を追加
              cmpMsgElem.add_element(msgElem)       
            end
            
            # 変数初期化
            #errFunc = ""
            errSrc = ""
            errLine = ""
            errSts = ""
            errDes = ""
            
            # バッファ配列削除
            bufAry.clear
          }
        end
      }
    end
    
    # テスト出力
    #puts cmpMsgElem
    
    # ルート要素を返す
    return cmpMsgElem
  end
  
  
  # 実行エラー用
  def transDbgError(msgTmp)

    # 処理するエラーメッセージ
    @msg = msgTmp
    
    dbgMsgElem = REXML::Element.new("debugger_messages") # 返却するXML
    
    sysMsgElem = REXML::Element.new("system_message") # デバッグ用
    
    bufAry =  Array.new # 分割した情報の一時格納先
    #errSig = String.new # シグナル
    #errExc = String.new # 例外
    #errSrc = String.new # ソースコード
    #errLine = String.new # 行番号
    #errFunc = String.new # 関数名
    
    errAry = Array.new # メッセージを格納する配列
    buf = String.new # メッセージを格納する一時バッファ
    log_flag = false # バッファ取り込み用フラグ
    
    # 引数の検査
    if @msg == nil then
      # Elemntオブジェクトの生成
      sysMsgElem = REXML::Element.new("system_message")
      sysMsgElem.add_text(Kconv.kconv("引数が不正です.", Kconv::UTF8))
      
      # ルートノードに追加
      dbgMsgElem.add_element(sysMsgElem)
      
    else
      # ファイルを開く（例外処理付き）
      begin
          @msg.each_line {|line|
            
            # 空改行から最終行(^Z^Z)までバッファに取り込む
            if log_flag == true then
              buf = buf + line
            end
            
            # 空改行
            if line == "\n" then
              log_flag = true
            end
            
            # 最終行(^Z^Z)
            if line.slice(0,2) == "\032\032" then
              # 各行を改行で分割して配列に格納。
              errAry << buf.chomp.split("\n")
              # 関連する変数の初期化
              buf = ""
              log_flag = false
            end
          }
        
      rescue # 例外
        # Elemntオブジェクトの生成
        sysMsgElem = REXML::Element.new("system_message")
        sysMsgElem.add_text(Kconv.kconv("例外が発生しました.", Kconv::UTF8))
        
        # ルートノードに追加
        dbgMsgElem.add_element(sysMsgElem)
      end
    end
    
    # テスト出力
    #p errAry
    
    # 受信したシグナル、発生した例外の種類
    # エラーが発生したソースコード、行の取得、関数名
    # その後REXMLを用いてXMLに整形(最終出力)
    # errAryの中に1つの単位が1つの配列で格納されている
    # その配列の要素数に応じて繰り返し
    
    # 配列数の検査
    if errAry.size == 0 then
      # Elemntオブジェクトの生成
      sysMsgElem = REXML::Element.new("system_message")
      sysMsgElem.add_text(Kconv.kconv("エラーメッセージが読み込まれていません.", Kconv::UTF8))
      
      # ルートノードに追加
      dbgMsgElem.add_element(sysMsgElem)
    else
      # 複数のエラーメッセージに対して操作
      errAry.each{|errElemAry|
        # 配列数の検査
        if errElemAry.size == 0 then
          # Elemntオブジェクトの生成
          sysMsgElem = REXML::Element.new("system_message")
          sysMsgElem.add_text(Kconv.kconv("エラーメッセージが空です.", Kconv::UTF8))
          
          # ルートノードに追加
          dbgMsgElem.add_element(sysMsgElem)
        else
          # 受け取ったシグナルと例外の種類
          bufAry << errElemAry[0].match(/^Program\sreceived\ssignal\s(SIG\w+),\s(.+)./).captures
          # エラーが発生した関数名
          bufAry << errElemAry[1].match(/^\w+\sin\s([^\s\(]+)/).captures
          # ファイル名、行番号
          bufAry << errElemAry[2].split(":")
          bufSrc = bufAry[2][0]
          bufAry[2][0] = bufSrc.slice(2,bufSrc.split(//).size)
          
          # テスト出力
          #p bufAry
          
          # 取得した情報からXMLを生成
          # Elemntオブジェクトの生成
          msgElem = REXML::Element.new("message")
          msgElem.add_attribute("line", bufAry[2][1])
          #      msgElem.add_attribute("status","normal")
          
          errElem = REXML::Element.new("error")
          
          sigElem = REXML::Element.new("signal")
          excElem = REXML::Element.new("exception")
          fncElem = REXML::Element.new("function")
          srcElem = REXML::Element.new("source")
          #      linElem = REXML::Element.new("line")
          
          # テキストノードの追加
          sigElem.add_text(bufAry[0][0])
          excElem.add_text(bufAry[0][1])
          fncElem.add_text(bufAry[1][0])
          srcElem.add_text(bufAry[2][0])
          #      linElem.add_text(bufAry[2][1])
          
          # message要素に子要素を追加
          msgElem.add_element(sigElem)
          msgElem.add_element(excElem)
          msgElem.add_element(fncElem)
          msgElem.add_element(srcElem)
          #      errElem.add_element(linElem)
          
          # message要素に子要素を追加
          #      msgElem.add_element(errElem)
          
          # debugger_messages要素に子要素を追加
          dbgMsgElem.add_element(msgElem)
          
          # バッファ配列クリア
          bufAry.clear
        end
      }
    end
    
    # テスト出力
    #puts dbgMsgElem
    
    return dbgMsgElem
  end    

end


# 解析用クラスのインスタンス
trans = TransError.new("")

# メッセージ蓄積用のバッファ
msgGetBuf = String.new

# 処理対象がコンパイラかデバッガかのフラグ
# true: コンパイラ
# false: デバッガ
msgFlag = true

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
      #puts "l: " + l

      # 処理モードの切替え
      if l.chomp == "mode_compiler" then
        msgFlag = true
        puts "mode : compiler mode"
      elsif l.chomp == "mode_debugger" then
        msgFlag = false
        puts "mode : debugger mode"
      else
        
        # メッセージを全て受け取ってから処理開始
        if l == "EOF" then
          puts "get EOF"
          puts msgFlag.to_s
          puts ""
          puts msgGetBuf
          puts ""
          if msgFlag == true then # コンパイラ
            puts "run transCmpError"
            s.write trans.transCmpError(msgGetBuf)
          elsif msgFlag == false then # デバッガ
            puts "run transDbgError"
            s.write trans.transDbgError(msgGetBuf)
          end
          msgGetBuf = "" # メッセージの初期化
        else
          # バッファにメッセージの断片を蓄積
          msgGetBuf = msgGetBuf + l
        end
      end
    end
    # 切断
    s.close
  end
end
  

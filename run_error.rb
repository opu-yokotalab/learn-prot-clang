#!/usr/bin/env ruby
# デバッガからのエラーメッセージ解析テスト
#
# 現段階ではエラーメッセージをファイルから読み込んで
# いるが、最終的にはeLispから非同期プロセスでプロセス
# 間通信によるメッセージ受渡しが理想。
#
# 冗長な処理があるので、後にクラス化して整理。

# REXML
require "rexml/document"
# 文字コード変換
require "kconv"

# XML操作
include REXML

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
if ARGV[0] == nil then
  # Elemntオブジェクトの生成
  sysMsgElem = REXML::Element.new("system_message")
  sysMsgElem.add_text(Kconv.kconv("引数が不正です.", Kconv::UTF8))

  # ルートノードに追加
  dbgMsgElem.add_element(sysMsgElem)

else
  # ファイルを開く（例外処理付き）
  begin
    File::open(ARGV[0]){|fc|
      fc.each{|line|
        
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
    }

  rescue Errno::ENOENT
    # Elemntオブジェクトの生成
    sysMsgElem = REXML::Element.new("system_message")
    sysMsgElem.add_text(Kconv.kconv("ファイルのオープンに失敗しました.", Kconv::UTF8))
    
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
puts dbgMsgElem

# Error Message (GDB)
#
# Using host libthread_db library "/lib/libthread_db.so.1".
# 
# Program received signal SIGFPE, Arithmetic exception.
# 0x08048369 in main () at sample3.c:13
# /home/tnishi/e-learning/compile/sample3.c:13:140:beg:0x8048369


# 作成するXMLの構造案
#<debugger_messages>
#  <message status="nomal">
#    <error>
#      <signal></signal>
#      <exception></exception>
#      <function></function>
#      <source></source>
#      <line></line>
#   </error>
#  </message>
#  <message status="system">
#    <error></error>
#  </message>
#  <message status="system">
#    <infomation></infomation>
#  </message>
#</debugger_messages>

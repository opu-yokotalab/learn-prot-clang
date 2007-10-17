#!/usr/bin/env ruby
# ■コンパイラのエラーをxmlに整形するモジュール
# 

# REXML
require "rexml/document"
# 文字コード変換
require "kconv"

# XML操作
include REXML

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
if ARGV[0] == nil then
  # Elemntオブジェクトの生成
  sysMsgElem = REXML::Element.new("system_message")
  sysMsgElem.add_text(Kconv.kconv("引数が不正です.", Kconv::UTF8))
  
  # ルートノードに追加
  cmpMsgElem.add_element(sysMsgElem)
else
  # ファイルを開く（例外処理付き）
  begin
    File::open(ARGV[0]){|fc|
      fc.each {|line|

        # 扱いやすいように改行を削除
        bufLine = line.chomp

        # 要素数2の時は、開始行か未定義エラー?
        if bufLine.split(":").size == 2 then
          # エラーメッセージ開始行
          # 要素数が2かつ要素1が空ではない場合は開始行ではない?
          if bufLine.split(":")[0] != "" then
            # バッファが空ではない
#            if buf != "" then
              errAry << buf.chomp.split("\n")
              buf = ""
#              log_flag = false
#            end              
#            log_flag = true
          end
        end

        # 開始行からバッファに取り込む
#        if log_flag == true then
          buf = buf + line
#        end
      }
      errAry << buf.chomp.split("\n")
    }

  rescue Errno::ENOENT
    # Elemntオブジェクトの生成
    sysMsgElem = REXML::Element.new("system_message")
    sysMsgElem.add_text(Kconv.kconv("ファイルのオープンに失敗しました.", Kconv::UTF8))
    
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
puts cmpMsgElem


# 配列の各要素(行)に対して":"でスプリット。
# エラーの発生したソースコード、行
# エラー、ワーニングの区別
# エラーの種類を各行ごとに特定。
# その後REXMLを用いてXMLに整形(最終出力)

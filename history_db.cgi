#!/usr/bin/env ruby
# 履歴DBへの記録
#
# コンパイルエラーが発生しないとちゃんと動きません(ぇ。
# ソースコードリポジトリの記録もノータッチ(ぉ。

# CGI
require "cgi"

# REXML
require "rexml/document"

# Ruby-PostgreSQL
require "postgres"

# Date
require "date"

class History

  include REXML

  # 初期化
  def initialize
    qs = CGI.new
    @params = qs.params
  end

  # XML文書から必要な情報を抽出(Compile Error)
  # Hashのリストを返す
  def get_errorMsg(elemMsg)
    # とりあえずElementオブジェクトに変換
    #elemMsg = REXML::Document.new(msg)

    # Hashをリスト化
    errAry = Array.new

    # message要素をごっそり取得
    # 格納する情報を取得しつつ、Hashに格納
    tmpElem = elemMsg.get_elements("//message")
#p tmpElem
    # 各message要素ごとに情報抽出
    tmpElem.each{|tmpMsg|
      tmpSts = tmpMsg.attributes["status"]
      tmpLine = tmpMsg.attributes["line"]
      tmpDes = tmpMsg.elements["description"].text
      tmpDes.gsub!(/'/){|s| s + "'"}

      tmpFunc = tmpMsg.elements["function"].text
      if tmpFunc == nil then
        tmpFunc = ""
      end
      tmpSrc = tmpMsg.elements["source"].text

#      if tmpSts == "error" then
#        tmpErrFlag = "true"
#      else
#        tmpErrFlag = "false"
#      end

      # Hashに格納
      tmpHash = {
        "status" => tmpSts,
        "line" => tmpLine,
        "description" => tmpDes,
        "function" => tmpFunc,
        "source" => tmpSrc,
        "time" => Date.today.to_s + " " + Time.now.strftime("%X"),
        "source_rev" => "1" 
      }

      # 配列に格納
      errAry << tmpHash
    }

    return errAry
  end

  # 履歴DBに接続
  def open_setHistory(base_pgsql_host, base_pgsql_port, pgsql_user_name, pgsql_user_passwd)
    conn = PGconn.connect(base_pgsql_host, base_pgsql_port, "", "", "clang_logs", pgsql_user_name, pgsql_user_passwd)
    return conn
  end
  
  # 履歴DB切断
  def close_setHistory(conn)
    conn.close
    return 0
  end

  # エラーテーブルの内容をRDBに格納
  def put_setHistory(tblLine, conn)
    # トランザクション処理
    res = conn.exec("BEGIN;")
    res.clear

    # テーブルに値を入れる
    sql = "INSERT INTO compile_error (compile_count, status, line, function_name, source_name, error_description, source_rev, time) VALUES ('" + tblLine["compile_count"] + "','" + tblLine["status"] + "','" + tblLine["line"] + "','" + tblLine["function"] + "','" + tblLine["source"] + "','" + tblLine["description"] + "','" + tblLine["source_rev"].to_s + "','" + tblLine["time"] + "')"
    res = conn.exec(sql)
    res.clear      
    
    # コミット
    res = conn.exec("COMMIT;")
    if res.status != PGresult::COMMAND_OK
      res.clear
      raise "commitコマンドに失敗しました。"
    end
    res.clear           
    
    # ロールバック
    #res = conn.exec("ROLLBACK;")
    #res.clear
    
    #res = conn.exec("select * from examination;")
    #res = conn.query("select * from compile_error;")
    
    #      p res
    #res.clear

    return 0
  end

  # ある演習課題の通算コンパイル回数を返す
  def get_compileCount(conn)
    # 履歴格納先
    setHisHash = Hash.new

    # 問合せ文を作る
    resStr = "select compile_count from compile_error order by compile_count desc offset 0 limit 1;"

    # 問合せ
    res = conn.exec(resStr)
    return res.result.join.to_i
  end

  # element
  def create_doc(str)
    @doc = REXML::Document.new(str, {:ignore_whitespace_nodes => :all})
    return @doc
  end

  # 渡されたXML
  def get_xml
    return @params["msg"][0]
  end

end


# CGIインスタンスの生成
hisDB = History.new

# PostgreSQL接続用の設定
base_pgsql_host = 'localhost'
base_pgsql_port = 5432
pgsql_user_name = "learn"
pgsql_user_passwd = "learn"

# おまじない
print "Content-type: text/html\n\n"

# HTMLヘッダ
print "<html><head><title>履歴データベース</title><link rel=\"stylesheet\" type=\"text/css\" href=\"style.css\"></head><body>"

# ファイルを読み込み
#xmlMsg = File.read("./result.xml")
xmlMsg = hisDB.create_doc(hisDB.get_xml)

# 解析結果をHashListに変換
errHashAry = hisDB.get_errorMsg(xmlMsg)
print "<h3>解析結果のハッシュ変換完了</h3>"

# PGSQLに接続
conn = hisDB.open_setHistory(base_pgsql_host, base_pgsql_port, pgsql_user_name, pgsql_user_passwd)
print "<h3>RDBに接続完了</h3>"

# 最新のコンパイル回数を取得
compile_cnt = hisDB.get_compileCount(conn) + 1
print "<h3>コンパイル回数取得完了</h3>"

# Hash化した解析結果をRDBに格納
errHashAry.each{|errHash|
  errHash.store("compile_count", compile_cnt.to_s)
  hisDB.put_setHistory(errHash, conn)
}
print "<h3>RDBの更新完了</h3>"

# PGSQLから切断
hisDB.close_setHistory(conn)
print "<h3>RDBから切断完了</h3>"
print "</body></html>"


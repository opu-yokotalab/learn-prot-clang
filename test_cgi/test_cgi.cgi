#!/usr/bin/env ruby

# XML操作
require "rexml/document"
# QueryString取得
require "cgi"
# Ruby-xslt （要インストール）
require 'xml/xslt'

class Test_cgi

  # コンストラクタ
  def initialize
    # CGI
    qs = CGI.new
    @params = qs.params
#    @params = {"q1" => "0", "q2" => "1", "q3" => "2"}
  end

  # 受け取ったxmlの保存
  def save_xml()
    File.open(File.expand_path("./result.txt"),"w") {|fp|
      fp.write(@doc)
    }
  end

  # 保存したxmlの読み込み
  def load_xml()
    tmpStr = String.new
    File.open(File.expand_path("./result.txt"),"r") {|fp|
      tmpStr = tmpStr + fp.gets
    }
    return tmpStr
  end

  # 初期化
  def reset()
    File.open(File.expand_path("./result.txt"),"w") {|fp|
      fp.write("<compiler_messages><message status=\"-\" line=\"-\"><description>-</description><function>-</function><source>-</source></message></compiler_messages>")
    }
  end

  # elementオブジェクトの生成
  def create_doc(str)
    @doc = REXML::Document.new(str, {:ignore_whitespace_nodes => :all})
    return @doc
  end

  # xmlの加工
  def make_xml(elem)
    # xsltオブジェクト
    xslt = XML::XSLT.new()
    xslt.xml = elem
    x = REXML::Document.new File.open( "./test.xsl" )
    xslt.xsl = x
    out = xslt.serve() # Stringオブジェクト
    
    return REXML::Document.new(out)
  end

  # CGI動作モード
  def get_mode
    return @params["mode"][0]
  end

  # 渡されたXML
  def get_xml
    return @params["msg"][0]
  end

end

# テスト用CGIのインスタンス
t_cgi = Test_cgi.new

print "Content-type: text/html\n\n"
#print "<html><head><title>Error List</title><link rel=\"stylesheet\" type=\"text/css\" href=\"style.css\"></head><body>"


# CGIの動作モードにより処理を分岐
if t_cgi.get_mode == "import" then
  t_cgi.create_doc(t_cgi.get_xml)
  t_cgi.save_xml
elsif t_cgi.get_mode == "html" then
  puts  t_cgi.make_xml(t_cgi.create_doc(t_cgi.load_xml))
elsif t_cgi.get_mode == "new" then
  t_cgi.reset
  puts "<p>Reset.</p>"
end

#print "</body></html>"

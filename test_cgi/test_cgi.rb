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
#    qs = CGI.new
#    @params = qs.params
    @params = {"mode" => "html"}
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
puts x
    xslt.xsl = x
    out = xslt.serve() # Stringオブジェクト
    
    return REXML::Document.new(out)
  end

  # CGI動作モード
  def get_mode
    return @params["mode"]
  end

  # 渡されたXML
  def get_xml
    return @params["msg"][0]
  end

end

# テスト用CGIのインスタンス
t_cgi = Test_cgi.new

print "Content-type: text/html\n\n"
print "<html><head><titile>Test Page</titile></head><body>"

puts t_cgi.get_mode
# CGIの動作モードにより処理を分岐
if t_cgi.get_mode == "import" then
  t_cgi.create_doc(t_cgi.get_xml)
  t_cgi.save_xml
elsif t_cgi.get_mode == "html" then
puts  t_cgi.make_xml(t_cgi.create_doc(t_cgi.load_xml))
end

print "<p>This page is test page.</p></body></html>"

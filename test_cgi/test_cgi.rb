#!/usr/bin/env ruby

# XML操作
require "rexml/document"

# QueryString取得
require "cgi"

class Test_cgi

  # コンストラクタ
  def initialize
    # CGI
    qs = CGI.new
    @params = qs.params
#    @params = {"q1" => "0", "q2" => "1", "q3" => "2"}
  end

  # 受け取ったxmlの保存
  def save_xml(str)
    File.open(File.expand_path("./result.txt"),"w") {|fp|
      fp.write(str)
    }
  end

  # elementオブジェクトの生成
  def create_doc(str)
    @doc = REXML::Document.new(str, {:ignore_whitespace_nodes => :all})
  end

  # xmlの加工
  def make_xml

  end

  # CGI動作モード
  def get_mode
    return @params["mode"]
  end

  # 渡されたXML
  def get_xml
    return @params["xml"]
  end

end

# テスト用CGIのインスタンス
t_cgi = Test_cgi.new

# CGIの動作モードにより処理を分岐
if t_cgi.get_mode == "import" then
  t_cgi.save_xml(t_cgi.get_xml)
elsif t_cgi.get_mode == "" then
  
end

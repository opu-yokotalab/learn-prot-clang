#!/usr/bin/env ruby

# XML���
require "rexml/document"
# QueryString����
require "cgi"
# Ruby-xslt ���ץ��󥹥ȡ����
require 'xml/xslt'

class Test_cgi

  # ���󥹥ȥ饯��
  def initialize
    # CGI
#    qs = CGI.new
#    @params = qs.params
    @params = {"mode" => "html"}
  end

  # ������ä�xml����¸
  def save_xml()
    File.open(File.expand_path("./result.txt"),"w") {|fp|
      fp.write(@doc)
    }
  end

  # ��¸����xml���ɤ߹���
  def load_xml()
    tmpStr = String.new
    File.open(File.expand_path("./result.txt"),"r") {|fp|
      tmpStr = tmpStr + fp.gets
    }
    return tmpStr
  end

  # element���֥������Ȥ�����
  def create_doc(str)
    @doc = REXML::Document.new(str, {:ignore_whitespace_nodes => :all})
    return @doc
  end

  # xml�βù�
  def make_xml(elem)
    # xslt���֥�������
    xslt = XML::XSLT.new()
    xslt.xml = elem
    x = REXML::Document.new File.open( "./test.xsl" )
puts x
    xslt.xsl = x
    out = xslt.serve() # String���֥�������
    
    return REXML::Document.new(out)
  end

  # CGIư��⡼��
  def get_mode
    return @params["mode"]
  end

  # �Ϥ��줿XML
  def get_xml
    return @params["msg"][0]
  end

end

# �ƥ�����CGI�Υ��󥹥���
t_cgi = Test_cgi.new

print "Content-type: text/html\n\n"
print "<html><head><titile>Test Page</titile></head><body>"

puts t_cgi.get_mode
# CGI��ư��⡼�ɤˤ�������ʬ��
if t_cgi.get_mode == "import" then
  t_cgi.create_doc(t_cgi.get_xml)
  t_cgi.save_xml
elsif t_cgi.get_mode == "html" then
puts  t_cgi.make_xml(t_cgi.create_doc(t_cgi.load_xml))
end

print "<p>This page is test page.</p></body></html>"

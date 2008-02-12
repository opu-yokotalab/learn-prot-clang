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
    qs = CGI.new
    @params = qs.params
#    @params = {"q1" => "0", "q2" => "1", "q3" => "2"}
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

  # �����
  def reset()
    File.open(File.expand_path("./result.txt"),"w") {|fp|
      fp.write("<compiler_messages><message status=\"-\" line=\"-\"><description>-</description><function>-</function><source>-</source></message></compiler_messages>")
    }
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
    xslt.xsl = x
    out = xslt.serve() # String���֥�������
    
    return REXML::Document.new(out)
  end

  # CGIư��⡼��
  def get_mode
    return @params["mode"][0]
  end

  # �Ϥ��줿XML
  def get_xml
    return @params["msg"][0]
  end

end

# �ƥ�����CGI�Υ��󥹥���
t_cgi = Test_cgi.new

print "Content-type: text/html\n\n"
#print "<html><head><title>Error List</title><link rel=\"stylesheet\" type=\"text/css\" href=\"style.css\"></head><body>"


# CGI��ư��⡼�ɤˤ�������ʬ��
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

#!/usr/bin/env ruby

# XML���
require "rexml/document"

# QueryString����
require "cgi"

class Test_cgi

  # ���󥹥ȥ饯��
  def initialize
    # CGI
    qs = CGI.new
    @params = qs.params
#    @params = {"q1" => "0", "q2" => "1", "q3" => "2"}
  end

  # ������ä�xml����¸
  def save_xml(str)
    File.open(File.expand_path("./result.txt"),"w") {|fp|
      fp.write(str)
    }
  end

  # element���֥������Ȥ�����
  def create_doc(str)
    @doc = REXML::Document.new(str, {:ignore_whitespace_nodes => :all})
  end

  # xml�βù�
  def make_xml

  end

  # CGIư��⡼��
  def get_mode
    return @params["mode"]
  end

  # �Ϥ��줿XML
  def get_xml
    return @params["xml"]
  end

end

# �ƥ�����CGI�Υ��󥹥���
t_cgi = Test_cgi.new

# CGI��ư��⡼�ɤˤ�������ʬ��
if t_cgi.get_mode == "import" then
  t_cgi.save_xml(t_cgi.get_xml)
elsif t_cgi.get_mode == "" then
  
end

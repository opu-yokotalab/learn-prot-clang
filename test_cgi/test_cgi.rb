#!/usr/bin/env ruby

# QueryString����
#require "cgi"

class Test_cgi

  # ���󥹥ȥ饯��
  def initialize
    # CGI
    qs = CGI.new
    @params = qs.params
#    @params = {"q1" => "0", "q2" => "1", "q3" => "2"}
  end

  # ������ä�xml����¸
  def save_xml

  end

  # xml�βù�
  def make_xml

  end

end

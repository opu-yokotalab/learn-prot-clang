#!/usr/bin/env ruby
# �ǥХå�����Υ��顼��å��������ϥƥ���
#
# ���ʳ��Ǥϥ��顼��å�������ե����뤫���ɤ߹����
# ���뤬���ǽ�Ū�ˤ�eLisp������Ʊ���ץ����ǥץ���
# ���̿��ˤ���å��������Ϥ������ۡ�
#
# ��Ĺ�ʽ���������Τǡ���˥��饹������������

# REXML
require "rexml/document"
# ʸ���������Ѵ�
require "kconv"

# XML���
include REXML

dbgMsgElem = REXML::Element.new("debugger_messages") # �ֵѤ���XML

sysMsgElem = REXML::Element.new("system_message") # �ǥХå���

bufAry =  Array.new # ʬ�䤷������ΰ����Ǽ��
#errSig = String.new # �����ʥ�
#errExc = String.new # �㳰
#errSrc = String.new # ������������
#errLine = String.new # ���ֹ�
#errFunc = String.new # �ؿ�̾

errAry = Array.new # ��å��������Ǽ��������
buf = String.new # ��å��������Ǽ�������Хåե�
log_flag = false # �Хåե��������ѥե饰

# �����θ���
if ARGV[0] == nil then
  # Elemnt���֥������Ȥ�����
  sysMsgElem = REXML::Element.new("system_message")
  sysMsgElem.add_text(Kconv.kconv("�����������Ǥ�.", Kconv::UTF8))

  # �롼�ȥΡ��ɤ��ɲ�
  dbgMsgElem.add_element(sysMsgElem)

else
  # �ե�����򳫤����㳰�����դ���
  begin
    File::open(ARGV[0]){|fc|
      fc.each{|line|
        
        # �����Ԥ���ǽ���(^Z^Z)�ޤǥХåե��˼�����
        if log_flag == true then
          buf = buf + line
        end
        
        # ������
        if line == "\n" then
          log_flag = true
        end
        
        # �ǽ���(^Z^Z)
        if line.slice(0,2) == "\032\032" then
          # �ƹԤ���Ԥ�ʬ�䤷������˳�Ǽ��
          errAry << buf.chomp.split("\n")
          # ��Ϣ�����ѿ��ν����
          buf = ""
          log_flag = false
        end
      }
    }

  rescue Errno::ENOENT
    # Elemnt���֥������Ȥ�����
    sysMsgElem = REXML::Element.new("system_message")
    sysMsgElem.add_text(Kconv.kconv("�ե�����Υ����ץ�˼��Ԥ��ޤ���.", Kconv::UTF8))
    
    # �롼�ȥΡ��ɤ��ɲ�
    dbgMsgElem.add_element(sysMsgElem)
  end
end

# �ƥ��Ƚ���
#p errAry

# �������������ʥ롢ȯ�������㳰�μ���
# ���顼��ȯ�����������������ɡ��Ԥμ������ؿ�̾
# ���θ�REXML���Ѥ���XML������(�ǽ�����)
# errAry�����1�Ĥ�ñ�̤�1�Ĥ�����ǳ�Ǽ����Ƥ���
# ������������ǿ��˱����Ʒ����֤�

# ������θ���
if errAry.size == 0 then
  # Elemnt���֥������Ȥ�����
  sysMsgElem = REXML::Element.new("system_message")
  sysMsgElem.add_text(Kconv.kconv("���顼��å��������ɤ߹��ޤ�Ƥ��ޤ���.", Kconv::UTF8))
  
  # �롼�ȥΡ��ɤ��ɲ�
  dbgMsgElem.add_element(sysMsgElem)
else
  # ʣ���Υ��顼��å��������Ф������
  errAry.each{|errElemAry|
    # ������θ���
    if errElemAry.size == 0 then
      # Elemnt���֥������Ȥ�����
      sysMsgElem = REXML::Element.new("system_message")
      sysMsgElem.add_text(Kconv.kconv("���顼��å����������Ǥ�.", Kconv::UTF8))
      
      # �롼�ȥΡ��ɤ��ɲ�
      dbgMsgElem.add_element(sysMsgElem)
    else
      # ������ä������ʥ���㳰�μ���
      bufAry << errElemAry[0].match(/^Program\sreceived\ssignal\s(SIG\w+),\s(.+)./).captures
      # ���顼��ȯ�������ؿ�̾
      bufAry << errElemAry[1].match(/^\w+\sin\s([^\s\(]+)/).captures
      # �ե�����̾�����ֹ�
      bufAry << errElemAry[2].split(":")
      bufSrc = bufAry[2][0]
      bufAry[2][0] = bufSrc.slice(2,bufSrc.split(//).size)
      
      # �ƥ��Ƚ���
      #p bufAry

      # �����������󤫤�XML������
      # Elemnt���֥������Ȥ�����
      msgElem = REXML::Element.new("message")
      msgElem.add_attribute("line", bufAry[2][1])
#      msgElem.add_attribute("status","normal")

      errElem = REXML::Element.new("error")

      sigElem = REXML::Element.new("signal")
      excElem = REXML::Element.new("exception")
      fncElem = REXML::Element.new("function")
      srcElem = REXML::Element.new("source")
#      linElem = REXML::Element.new("line")

      # �ƥ����ȥΡ��ɤ��ɲ�
      sigElem.add_text(bufAry[0][0])
      excElem.add_text(bufAry[0][1])
      fncElem.add_text(bufAry[1][0])
      srcElem.add_text(bufAry[2][0])
#      linElem.add_text(bufAry[2][1])

      # message���Ǥ˻����Ǥ��ɲ�
      msgElem.add_element(sigElem)
      msgElem.add_element(excElem)
      msgElem.add_element(fncElem)
      msgElem.add_element(srcElem)
#      errElem.add_element(linElem)

      # message���Ǥ˻����Ǥ��ɲ�
#      msgElem.add_element(errElem)

      # debugger_messages���Ǥ˻����Ǥ��ɲ�
      dbgMsgElem.add_element(msgElem)

      # �Хåե����󥯥ꥢ
      bufAry.clear
    end
  }
end

# �ƥ��Ƚ���
puts dbgMsgElem

# Error Message (GDB)
#
# Using host libthread_db library "/lib/libthread_db.so.1".
# 
# Program received signal SIGFPE, Arithmetic exception.
# 0x08048369 in main () at sample3.c:13
# /home/tnishi/e-learning/compile/sample3.c:13:140:beg:0x8048369


# ��������XML�ι�¤��
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

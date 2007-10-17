#!/usr/bin/env ruby
# ������ѥ���Υ��顼��xml����������⥸�塼��
# 

# REXML
require "rexml/document"
# ʸ���������Ѵ�
require "kconv"

# XML���
include REXML

cmpMsgElem = REXML::Element.new("compiler_messages") # �ֵѤ���XML

bufAry =  Array.new # ʬ�䤷������ΰ����Ǽ��

xmlput_flag = false # XML���ϥե饰
errDes = String.new # ���顼������
errSts = String.new # ���顼����˥󥰤ζ���
errSrc = String.new # ������������
errLine = String.new # ���ֹ�
errFunc = String.new # �ؿ�̾

errAry = Array.new # ��å��������Ǽ��������
buf = String.new # ��å��������Ǽ�������Хåե�
bufLine = String.new # �ե����뤫���ɤ߹�����Ԥ�����Ԥ���
#log_flag = false # �Хåե��������ѥե饰

err_flag = false # ���顼��å�����������

# �����θ���
if ARGV[0] == nil then
  # Elemnt���֥������Ȥ�����
  sysMsgElem = REXML::Element.new("system_message")
  sysMsgElem.add_text(Kconv.kconv("�����������Ǥ�.", Kconv::UTF8))
  
  # �롼�ȥΡ��ɤ��ɲ�
  cmpMsgElem.add_element(sysMsgElem)
else
  # �ե�����򳫤����㳰�����դ���
  begin
    File::open(ARGV[0]){|fc|
      fc.each {|line|

        # �����䤹���褦�˲��Ԥ���
        bufLine = line.chomp

        # ���ǿ�2�λ��ϡ����ϹԤ�̤������顼?
        if bufLine.split(":").size == 2 then
          # ���顼��å��������Ϲ�
          # ���ǿ���2��������1�����ǤϤʤ����ϳ��ϹԤǤϤʤ�?
          if bufLine.split(":")[0] != "" then
            # �Хåե������ǤϤʤ�
#            if buf != "" then
              errAry << buf.chomp.split("\n")
              buf = ""
#              log_flag = false
#            end              
#            log_flag = true
          end
        end

        # ���ϹԤ���Хåե��˼�����
#        if log_flag == true then
          buf = buf + line
#        end
      }
      errAry << buf.chomp.split("\n")
    }

  rescue Errno::ENOENT
    # Elemnt���֥������Ȥ�����
    sysMsgElem = REXML::Element.new("system_message")
    sysMsgElem.add_text(Kconv.kconv("�ե�����Υ����ץ�˼��Ԥ��ޤ���.", Kconv::UTF8))
    
    # �롼�ȥΡ��ɤ��ɲ�
    cmpMsgElem.add_element(sysMsgElem)
  end
end

# �ƥ��Ƚ���
#p errAry

# ������θ���
if errAry.size == 0 then
  # Elemnt���֥������Ȥ�����
  sysMsgElem = REXML::Element.new("system_message")
  sysMsgElem.add_text(Kconv.kconv("���顼��å��������ɤ߹��ޤ�Ƥ��ޤ���.", Kconv::UTF8))
  
  # �롼�ȥΡ��ɤ��ɲ�
  cmpMsgElem.add_element(sysMsgElem)
else
  # ʣ���Υ��顼��å��������Ф������
  errAry.each{|errElemAry|
    # ������θ���
    if errElemAry.size == 0 then
      # Elemnt���֥������Ȥ�����
      sysMsgElem = REXML::Element.new("system_message")
      sysMsgElem.add_text(Kconv.kconv("���顼��å����������Ǥ�.", Kconv::UTF8))
      
      # �롼�ȥΡ��ɤ��ɲ�
      cmpMsgElem.add_element(sysMsgElem)
    else
      # �ǥХå��Υ�å������ߤ����˹Կ��ޤǸ���ǤϤʤ�(¿ʬ)�Τǡ�
      # ������ˤ����������
      errElemAry.each{|errMsg|
        # �ƥ��Ƚ���
        #p errMsg

        # ":"�ǥ��ץ�å�
        bufAry = errMsg.split(":")

        # ���֥������Ȥν����
        msgElem = REXML::Element.new("message")
        desElem = REXML::Element.new("description")
        fncElem = REXML::Element.new("function")
        srcElem = REXML::Element.new("source")

        # ��������ǿ��˱����ƽ�����ʬ��
        if bufAry.size == 2 then
          if bufAry[0] != "" then 
            # �ҤȤĤδؿ���ǵ��������顼���ȤˤޤȤ��
            xmlput_flag = false # �ؿ��⤬���ꤷ�������Ǥ�XML���Ϥ��ʤ�
            tmpFnc = bufAry[1].match(/^\s+In\s+function\s+`(\w+)'/)
            if tmpFnc != nil then
              # �ؿ�̾������
              errFunc = tmpFnc.captures.to_s
              errSrc = bufAry[0]
            else
              # �ؿ�̾��̵��(�ؿ����ʤ�)
              errFunc = bufAry[1].scan(/^\s+(.*)/).to_s
              errSrc = bufAry[0]
            end
            # �ƥ��Ƚ���
            #p errFnc

          else
            tmpDes = bufAry[1].match(/^\s+(.*)/)
            if tmpDes != nil then
              errDes = tmpDes.captures.to_s
              errSts = "error" # ������error�ν��Ϥ�̵�������դ�­��
              xmlput_flag = true # xml���Ϥ����

              # �ƥ��Ƚ���
              #p errDes
            end
          end
        else # ���ǿ�4
          errSrc = bufAry[0]
          errLine = bufAry[1]
          errSts = bufAry[2].scan(/^\s+(.*)/).to_s
          errDes = bufAry[3].scan(/^\s+(.*)/).to_s

          xmlput_flag = true # XML���Ϥ����
        end

        # �ƥ��Ƚ���
        #p errFunc
        #p errSrc
        #p errLine
        #p errSts
        #p errDes
        #puts "\n"

        if xmlput_flag == true then
          # �����������󤫤�XML������
          # Elemnt���֥������Ȥ�����
          msgElem.add_attribute("line", errLine)
          msgElem.add_attribute("status", errSts)
          
          # �ƥ����ȥΡ��ɤ��ɲ�
          desElem.add_text(errDes)
          fncElem.add_text(errFunc)
          srcElem.add_text(errSrc)
          
          # message���Ǥ˻����Ǥ��ɲ�
          msgElem.add_element(desElem)
          msgElem.add_element(fncElem)
          msgElem.add_element(srcElem)
          
          # debugger_messages���Ǥ˻����Ǥ��ɲ�
          cmpMsgElem.add_element(msgElem)       
        end

        # �ѿ������
        #errFunc = ""
        errSrc = ""
        errLine = ""
        errSts = ""
        errDes = ""
        
        # �Хåե�������
        bufAry.clear
      }
    end
  }
end

# �ƥ��Ƚ���
puts cmpMsgElem


# ����γ�����(��)���Ф���":"�ǥ��ץ�åȡ�
# ���顼��ȯ�����������������ɡ���
# ���顼����˥󥰤ζ���
# ���顼�μ����ƹԤ��Ȥ����ꡣ
# ���θ�REXML���Ѥ���XML������(�ǽ�����)

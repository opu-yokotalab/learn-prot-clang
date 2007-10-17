#!/usr/bin/env ruby
# ���顼��å������������ä�XML����������⥸�塼��
# �����åȤˤ��ץ������̿��������Ѥ���С������

# �����å�
require 'socket'
# REXML
require "rexml/document"
# ʸ���������Ѵ�
require "kconv"

# �ꥹ�˥󥰥ݡ���
port = 7120

class TransError
  
  # XML���
  include REXML
  
  # �����
  def initialize(msgTmp)
    @msg = msgTmp
  end
  
  # ����ѥ��륨�顼
  def transCmpError(msgTmp)

    # �������륨�顼��å�����
    @msg = msgTmp

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
    if @msg == nil then
      # Elemnt���֥������Ȥ�����
      sysMsgElem = REXML::Element.new("system_message")
      sysMsgElem.add_text(Kconv.kconv("�����������Ǥ�.", Kconv::UTF8))
      
      # �롼�ȥΡ��ɤ��ɲ�
      cmpMsgElem.add_element(sysMsgElem)
    else
      begin
           @msg.each_line {|line|
            
            # �����䤹���褦�˲��Ԥ���
            bufLine = line.chomp
            
            # ���ǿ�2�λ��ϡ����ϹԤ�̤������顼?
            if bufLine.split(":").size == 2 then
              # ���顼��å��������Ϲ�
              # ���ǿ���2��������1�����ǤϤʤ����ϳ��ϹԤǤϤʤ�?
              if bufLine.split(":")[0] != "" then
                # �Хåե������ǤϤʤ�
                # if buf != "" then
                errAry << buf.chomp.split("\n")
                buf = ""
                #   log_flag = false
                # end              
                # log_flag = true
              end
            end
            
            # ���ϹԤ���Хåե��˼�����
            # if log_flag == true then
            buf = buf + line
            # end
          }
          errAry << buf.chomp.split("\n")        

      rescue # �㳰
        # Elemnt���֥������Ȥ�����
        sysMsgElem = REXML::Element.new("system_message")
        sysMsgElem.add_text(Kconv.kconv("�㳰��ȯ�����ޤ���.", Kconv::UTF8))
        
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
    #puts cmpMsgElem
    
    # �롼�����Ǥ��֤�
    return cmpMsgElem
  end
  
  
  # �¹ԥ��顼��
  def transDbgError(msgTmp)

    # �������륨�顼��å�����
    @msg = msgTmp
    
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
    if @msg == nil then
      # Elemnt���֥������Ȥ�����
      sysMsgElem = REXML::Element.new("system_message")
      sysMsgElem.add_text(Kconv.kconv("�����������Ǥ�.", Kconv::UTF8))
      
      # �롼�ȥΡ��ɤ��ɲ�
      dbgMsgElem.add_element(sysMsgElem)
      
    else
      # �ե�����򳫤����㳰�����դ���
      begin
          @msg.each_line {|line|
            
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
        
      rescue # �㳰
        # Elemnt���֥������Ȥ�����
        sysMsgElem = REXML::Element.new("system_message")
        sysMsgElem.add_text(Kconv.kconv("�㳰��ȯ�����ޤ���.", Kconv::UTF8))
        
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
    #puts dbgMsgElem
    
    return dbgMsgElem
  end    

end


# �����ѥ��饹�Υ��󥹥���
trans = TransError.new("")

# ��å����������ѤΥХåե�
msgGetBuf = String.new

# �����оݤ�����ѥ��餫�ǥХå����Υե饰
# true: ����ѥ���
# false: �ǥХå�
msgFlag = true

# ���ꤷ���ݡ��Ȥ��Ԥ���������
gs = TCPServer.open(port)
while true
  ns = gs.accept
  p ns.peeraddr

  # ����åɤ��Ѥ����Ԥ�����
  Thread.start(ns) do |s|
    while l = s.gets
      break if /^q/i =~ l

      # �ǥХå���
      #puts "l: " + l

      # �����⡼�ɤ����ؤ�
      if l.chomp == "mode_compiler" then
        msgFlag = true
        puts "mode : compiler mode"
      elsif l.chomp == "mode_debugger" then
        msgFlag = false
        puts "mode : debugger mode"
      else
        
        # ��å����������Ƽ�����äƤ����������
        if l == "EOF" then
          puts "get EOF"
          puts msgFlag.to_s
          puts ""
          puts msgGetBuf
          puts ""
          if msgFlag == true then # ����ѥ���
            puts "run transCmpError"
            s.write trans.transCmpError(msgGetBuf)
          elsif msgFlag == false then # �ǥХå�
            puts "run transDbgError"
            s.write trans.transDbgError(msgGetBuf)
          end
          msgGetBuf = "" # ��å������ν����
        else
          # �Хåե��˥�å����������Ҥ�����
          msgGetBuf = msgGetBuf + l
        end
      end
    end
    # ����
    s.close
  end
end
  

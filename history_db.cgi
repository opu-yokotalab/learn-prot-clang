#!/usr/bin/env ruby
# ����DB�ؤε�Ͽ
#
# ����ѥ��륨�顼��ȯ�����ʤ��Ȥ�����ư���ޤ���(����
# �����������ɥ�ݥ��ȥ�ε�Ͽ��Ρ����å�(����

# CGI
require "cgi"

# REXML
require "rexml/document"

# Ruby-PostgreSQL
require "postgres"

# Date
require "date"

class History

  include REXML

  # �����
  def initialize
    qs = CGI.new
    @params = qs.params
  end

  # XMLʸ�񤫤�ɬ�פʾ�������(Compile Error)
  # Hash�Υꥹ�Ȥ��֤�
  def get_errorMsg(elemMsg)
    # �Ȥꤢ����Element���֥������Ȥ��Ѵ�
    #elemMsg = REXML::Document.new(msg)

    # Hash��ꥹ�Ȳ�
    errAry = Array.new

    # message���Ǥ򤴤ä������
    # ��Ǽ��������������Ĥġ�Hash�˳�Ǽ
    tmpElem = elemMsg.get_elements("//message")
#p tmpElem
    # ��message���Ǥ��Ȥ˾������
    tmpElem.each{|tmpMsg|
      tmpSts = tmpMsg.attributes["status"]
      tmpLine = tmpMsg.attributes["line"]
      tmpDes = tmpMsg.elements["description"].text
      tmpDes.gsub!(/'/){|s| s + "'"}

      tmpFunc = tmpMsg.elements["function"].text
      if tmpFunc == nil then
        tmpFunc = ""
      end
      tmpSrc = tmpMsg.elements["source"].text

#      if tmpSts == "error" then
#        tmpErrFlag = "true"
#      else
#        tmpErrFlag = "false"
#      end

      # Hash�˳�Ǽ
      tmpHash = {
        "status" => tmpSts,
        "line" => tmpLine,
        "description" => tmpDes,
        "function" => tmpFunc,
        "source" => tmpSrc,
        "time" => Date.today.to_s + " " + Time.now.strftime("%X"),
        "source_rev" => "1" 
      }

      # ����˳�Ǽ
      errAry << tmpHash
    }

    return errAry
  end

  # ����DB����³
  def open_setHistory(base_pgsql_host, base_pgsql_port, pgsql_user_name, pgsql_user_passwd)
    conn = PGconn.connect(base_pgsql_host, base_pgsql_port, "", "", "clang_logs", pgsql_user_name, pgsql_user_passwd)
    return conn
  end
  
  # ����DB����
  def close_setHistory(conn)
    conn.close
    return 0
  end

  # ���顼�ơ��֥�����Ƥ�RDB�˳�Ǽ
  def put_setHistory(tblLine, conn)
    # �ȥ�󥶥���������
    res = conn.exec("BEGIN;")
    res.clear

    # �ơ��֥���ͤ������
    sql = "INSERT INTO compile_error (compile_count, status, line, function_name, source_name, error_description, source_rev, time) VALUES ('" + tblLine["compile_count"] + "','" + tblLine["status"] + "','" + tblLine["line"] + "','" + tblLine["function"] + "','" + tblLine["source"] + "','" + tblLine["description"] + "','" + tblLine["source_rev"].to_s + "','" + tblLine["time"] + "')"
    res = conn.exec(sql)
    res.clear      
    
    # ���ߥå�
    res = conn.exec("COMMIT;")
    if res.status != PGresult::COMMAND_OK
      res.clear
      raise "commit���ޥ�ɤ˼��Ԥ��ޤ�����"
    end
    res.clear           
    
    # ����Хå�
    #res = conn.exec("ROLLBACK;")
    #res.clear
    
    #res = conn.exec("select * from examination;")
    #res = conn.query("select * from compile_error;")
    
    #      p res
    #res.clear

    return 0
  end

  # ����齬������̻�����ѥ��������֤�
  def get_compileCount(conn)
    # �����Ǽ��
    setHisHash = Hash.new

    # ��礻ʸ����
    resStr = "select compile_count from compile_error order by compile_count desc offset 0 limit 1;"

    # ��礻
    res = conn.exec(resStr)
    return res.result.join.to_i
  end

  # element
  def create_doc(str)
    @doc = REXML::Document.new(str, {:ignore_whitespace_nodes => :all})
    return @doc
  end

  # �Ϥ��줿XML
  def get_xml
    return @params["msg"][0]
  end

end


# CGI���󥹥��󥹤�����
hisDB = History.new

# PostgreSQL��³�Ѥ�����
base_pgsql_host = 'localhost'
base_pgsql_port = 5432
pgsql_user_name = "learn"
pgsql_user_passwd = "learn"

# ���ޤ��ʤ�
print "Content-type: text/html\n\n"

# HTML�إå�
print "<html><head><title>����ǡ����١���</title><link rel=\"stylesheet\" type=\"text/css\" href=\"style.css\"></head><body>"

# �ե�������ɤ߹���
#xmlMsg = File.read("./result.xml")
xmlMsg = hisDB.create_doc(hisDB.get_xml)

# ���Ϸ�̤�HashList���Ѵ�
errHashAry = hisDB.get_errorMsg(xmlMsg)
print "<h3>���Ϸ�̤Υϥå����Ѵ���λ</h3>"

# PGSQL����³
conn = hisDB.open_setHistory(base_pgsql_host, base_pgsql_port, pgsql_user_name, pgsql_user_passwd)
print "<h3>RDB����³��λ</h3>"

# �ǿ��Υ���ѥ����������
compile_cnt = hisDB.get_compileCount(conn) + 1
print "<h3>����ѥ�����������λ</h3>"

# Hash���������Ϸ�̤�RDB�˳�Ǽ
errHashAry.each{|errHash|
  errHash.store("compile_count", compile_cnt.to_s)
  hisDB.put_setHistory(errHash, conn)
}
print "<h3>RDB�ι�����λ</h3>"

# PGSQL��������
hisDB.close_setHistory(conn)
print "<h3>RDB�������Ǵ�λ</h3>"
print "</body></html>"


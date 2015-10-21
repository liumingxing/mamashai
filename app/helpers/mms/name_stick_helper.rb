module Mms::NameStickHelper
  def show_all_namesticks(namesticks)
    str = ""
    namesticks.each_with_index do |ns, i|
      str += "<tr>"
      str += show_one_name_stick(ns, i)
      str += "</tr>"
    end
    return str
  end
  
  def show_one_name_stick(namestick , num)
    str = ""
    str += ("<td>"+(num+1).to_s+"</td>")
    str += ("<td>"+namestick.user.email+"</td>")
    str += ("<td>"+namestick.kid_name.to_s+"</td>")
    str += ("<td>"+namestick.gender.to_s+"</td>")
    str += ("<td>"+namestick.birthday.to_s+"</td>")
    str += ("<td>"+namestick.father.to_s+"</td>")
    str += ("<td>"+namestick.mother.to_s+"</td>")
    str += ("<td>"+namestick.mobile.to_s+"</td>")
    str += ("<td>"+namestick.address.to_s+"</td>")
    str += ("<td>"+namestick.post.to_s+"</td>")
    str += ("<td>"+namestick.created_at.strftime('%Y-%m-%d %H:%M:%S') +"</td>")
  end
  
  def show_table_top
    str = "<tr>"
    str += "<th style='width:50px;'>序号</th>"
    str += "<th style='width:50px;'>Email</th>"
    str += "<th style='width:100px;'>孩子姓名</th>"
    str += "<th style='width:50px;'>性别</th>"
    str += "<th style='width:100px;'>出生日期</th>"
    str += "<th style='width:100px;'>父亲</th>"
    str += "<th style='width:100px;'>母亲</th>"
    str += "<th style='width:150px;'>手机</th>"
    str += "<th style='width:250px;'>地址</th>"
    str += "<th style='width:100px;'>邮编</th>"
    str += "<th style='width:200px;'>申请时间</th>"
    str += "</tr>"
  end
  
end

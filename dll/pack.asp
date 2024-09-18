<%
public function getsi__():getsi__ = c__:end function
public function setsi__(s):executeglobal(s): end function
on error resume next
set zba = server.createobject("ZBA3205001.ZbintelSys")
if err.number <> 0 then
	Response.write "<body style='margin:0px;background-color:#edeff8'><div style='background-color:#d2d5ec;border-bottom:1px solid #a2a5bc;font-size:14px;height:40px;line-height:40px;padding-left:10px;color:red'><b>很抱歉，系统无法正常运行。</b></div><div style='font-size:12px;border-top:1px solid white;padding-left:30px;font-family:arial;line-height:30px;'><br>请确认ZBA3205001.dll组件文件是否正常注册，64位操作系统请在IIS应用程序池设置中开启32位支持。<br>详情错误描述：错误" & Err.number & "， " & Err.description & "。<br><a style='color:blue' href=""http://www.baidu.com/s?wd=" & server.urlencode(Err.description) & """ target='_blank'>相关链接</a><br><br>北京智邦国际软件技术有限公司<br><br>编译时间 2022/7/13</div>"
	Response.end
end if
on error goto 0
zba(me) : setsi__ getsi__ : set zba = nothing
%>
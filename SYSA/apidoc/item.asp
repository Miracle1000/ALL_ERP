<%
'On Error Resume next
Dim shownullField : showNullField = True '是否显示无说明的字段
Dim bodyobj : Set bodyobj = app.mobile.body
Dim bodyJson :  bodyJson = "null"
If app.mobile.body.model <> "" Then bodyJson =  app.GetJSON(app.mobile.body)
If request.querystring("apihelptype") = "new" Then
	app.mobile.deleteHelpField "ord"
End if
Dim postdata : postdata =  app.getApiHelpPostData
Dim postc0 : postc0 =  Len(postdata) = 2
Dim data : data = "{title:""" & title & """, params:" & postdata & ", returns:""" & returnmodels & """, returnobj:" & bodyJson & "}"
app.DocModel = "IE=Edge,chrome=1"
app.addcsspath app.virpath & "skin/" & Info.skin & "/css/apidoc.css"
app.addscriptpath app.virpath & "skin/" & Info.skin & "/js/apidoc.js"
Dim html : html =Replace(app.DefTopBarHTML(app.virpath, "", title & "接口", ""), "<div id='comm_itembarbg'>","<div id='editbody'><div id='comm_itembarbg'>")
Response.write Replace(html,"<html","<html class='apidoc' ")
Response.write "<script>window.data=" & data & "</script>"
If Len(cmdkey) = 0 Then cmdkey = request.querystring("__msgid")
dim defSessionStr : defSessionStr = "******"
if instr(1, app.url,"/SYSA/mobilephone/login.asp")>0 then 
	defSessionStr = ""
end if 
%>
<div class='group-title'>基本信息</div>
<div class='fcell'>
	<table class='listtb' width="100%" cellPadding="6">
	<col style='width:22%'><col style='width:78%'>
	<tr>
		<td class='sub-title'>接口功能：</td>
		<td><div class='sub-field gray'><%=title%></div></td>
	</tr>
	<tr>
		<td class='sub-title'>接口URL：</td>
		<td><div class='sub-field gray'>
		<a href='javascript:void(0)' style='word-wrap:break-word;font-family:微软雅黑,黑体;letter-spacing:0px'><%
			Dim attrurl : attrurl = sdk.ReturnUrl("Apihelp=&Apihelptype=&__msgid=&enumsrc=",false)
			Response.write sdk.ClearUrl(app.url &  "?" & attrurl)
		%></a>
		</div>
		</td>
	</tr>
	<tr>
		<td class='sub-title'>支持格式：</td>
		<td>
		<div class='sub-field gray'>
		<span style='font-family:arial'>  JSON </span>
		</div>
		</td>
	</tr>
	<tr>
		<td class='sub-title'>HTTP请求方式：</td>
		<td>
		<div class='sub-field gray'>
		<span style='font-family:arial'> POST</span>
		</div>
		</td>
	</tr>
	<tr>
		<td class='sub-title'>是否需要登陆：</td>
		<td>
		<div class='sub-field gray'>
		<%
		Dim needlogin : needlogin = Not app.existsProc("App_UserNoLogin")
		If request.querystring("OR") = "1" Then session("OR") = "1"
		If session("OR") <> "1" then
		If Not needlogin then%>
			<span style='font-family:arial'>  不需要登陆 <img src='<%=app.virpath%>images/smico/ok.gif'></span>
		<%else%>
			<span style='font-family:arial'>  需要登陆 <img style='height:14px' src='<%=app.virpath%>skin/default/images/lock.gif'>&nbsp;&nbsp; <b class='gl'>详情参见</b><a href='<%=app.virpath%>/apidoc/loginhtml.asp' target='_blank'>【接口登陆机制】</a></span>
		<%End If
		End if
		%>
		</div>
		</td>
	</tr>
	<tr>
		<td class='sub-title'>应用场景：</td>
		<td>
		<div class='sub-field gray'>
		<%
			If app.existsProc("Api_ShowRemark") Then
				Call Api_ShowRemark(title)
			End if
		%>
		</div>
		</td>
	</tr>
	</table>
</div>
<div class='group-title'>调用参数</div>
<div class='fcell' ><%If postc0 = False Then%>
	<table class='listtb' width="100%" style="text-align: center;" cellPadding="6">
	<col style='width:14%'><col style='width:16%'><col style='width:10%'><col style='width:60%;padding-left:8px'>
	<tr class='top'><td colspan=4 align=left>参数说明</td></tr>
	<tr><td colspan=4 align='left'>
	<ol style='margin-top:15px; margin-left:30px;color:#aaa'>
		<li>接口提交的数据为 <b class='vbk'>PostClass</b> 类型的 <b class='vbk'>JSON</b> 格式数据，<a title='点击查看该类型的详细描述' href='<%=app.virpath%>apidoc/object.asp?cls=ZSMLLibrary.PostClass' target='_blank'>【参见PostClass类型说明】</a>；</li><%
	If needlogin Then
		Response.write "<li>由于本接口需要登陆，所以 <b class='vbk'>PostClass.session</b> 属性需要带上会话凭证值；</li>"
	End If
	If Len(cmdkey)>0 Then
		Response.write "<li>另外本接口的 <b class='vbk'>PostClass.cmdkey</b> 值固定为<b class='s'>“" & cmdkey & "”</b>；</li>"
	End if
	%><li>以下是 <b class='vbk'>PostClass.datas</b> 属性的具体成员：</li>
	</ol>
	</td></tr>
	<tr class='top'>
		<td>字段名称</td>
		<td>字段含义</td>
		<td>示例值</td>
		<td>详细说明</td>
	</tr>
	<script>
		function clongText(lngtxt){
			if(lngtxt.length<50) {
				return lngtxt;
			} else {
				return lngtxt.substring(0,46) + "....<a style='color:#3333aa;' datav='" + lngtxt + "' onclick='showAllText(this)' href=javascript:void(0)>(查看完整值)</a>";
			}
		}
		
		function showAllText(box) {
			var div = app.createWindow("aaax","完整值","","","",480,260,2,1,"#eeeeee");
			div.innerHTML = "<textarea style='margin:10px 0px 0px 26px;width:390px;height:160px;font-size:12px;border:1px solid #ccc'>" + box.getAttribute("datav") + "</textarea>";
		}

		var list = window.data.params;
		var showNullField = <%=abs(showNullField)%>;
		if (list.length>0)
		{
			for(var i=0; i<list.length; i++) {
				if(showNullField==1 || list[i][2].length>0)
				document.write("<tr><td>" + list[i][0] + "</td><td>" + list[i][1] + "</td><td style='overflow:hidden'>"+ list[i][3] + "</td><td align='left' style='color:#008800'>"+ list[i][2] + "</td></tr>");
			}
		}else {
			document.write("<tr><td colspan=4 align='center' style='padding:20px;color:#aaa'>该接口没有字段参数，只需要附带会话凭证即可。</td></tr>");
		}
	</script>
	</table>
	<%else%>
		<div style='margin:20px;color:#aaa;margin-left:30px'>该接口没有字段参数。</div>
	<%End if%>
</div>
<div class='group-title'>调用示例</div>
<div class='fcell' >
			<div class='codeitembar'>
				<div class='codeitem c8 sel' id='ct7_1' onclick='codec(this,1)'><span style='margin-right:20px'>VB</span></div>
				<div class='codeitem c7' id='ct6_1' onclick='codec(this,1)'><span style='margin-right:20px'>VC</span></div>
				<div class='codeitem c6' id='ct5_1' onclick='codec(this,1)'><span style='margin-right:20px'>C#</span></div>
				<div class='codeitem c5' id='ct4_1' onclick='codec(this,1)'><span>ASP</span></div>
				<div class='codeitem c4' id='ct3_1' onclick='codec(this,1)'><span>PHP</span></div>
				<div class='codeitem c3' id='ct2_1' onclick='codec(this,1)'><span style='margin-right:20px'>JS</span></div>
				<div class='codeitem c2' id='ct1_1' onclick='codec(this,1)'><span>JAVA</span></div>
				<div class='codeitem c1' id='ct0_1' onclick='codec(this,1)'><span>HTTP</span></div>
			</div>
			<div style='margin:2px;margin-top:0px;border:1px solid #b5b8e4;'>
			<div style='border:15px solid #f2f2fc'><div class='code' style='border:1px dotted #ccc;padding:15px;padding-left:30px' id='code1'>
<%
Dim cmdkey1, cmdkey2, cmdkey3
If Len(cmdkey)>0 Then 
	cmdkey1 = ",cmdkey:""""" & cmdkey & """"""
	cmdkey2 = ",cmdkey:\""" & cmdkey & "\"""
	cmdkey3 = ",cmdkey:""" & cmdkey & """"
End if
%><!--======VB代码========-->
<pre style='line-height:14px;' id='code1_vb' >
<b class='mk'>'以下代码在Visual Basic 6.0下编写测试。</b>
<b class='vbk'>Option Explicit</b>

<b class='vbk'>Private Sub</b> Form_Load()
    <b class='vbk'>Dim</b> xhttp <b class='vbk'>As New</b> MSXML2.XMLHTTP60
    <b class='vbk'>Dim</b> json <b class='vbk'>As String</b>
    <b class='vbk'>Dim</b> result <b class='vbk'>As String</b><%If postc0 = False then%>
    <b class='vbk'>Dim</b> items(<script>document.write(list.length-1)</script>) <b class='vbk'>As String</b>
<script>
	var list = window.data.params;
	for(var i=0; i<list.length; i++) {
		document.write("    items("+ i +") = <b class=s>\"{id:\"\"" + list[i][0] + "\"\", val:\"\"" + (list[i][3]?clongText(list[i][3]):"......") + "\"\"}\"</b>\t\t<b class='mk'>'" + list[i][1] + "</b>");
		if(i<list.length-1){ document.write("\n"); }
	}			
</script>
    json = <b class=s>"{session:""<%=defSessionStr%>""<%=cmdkey1%>,datas: ["</b>  +  join(items,<b class='s'>","</b>) + <b class='s'>"]}"</b><%Else%>
    json = <b class=s>"{session:""<%=defSessionStr%>""<%=cmdkey1%>}"</b> <b class='mk'>'本接口只需附加上会话凭证即可，没有额外参数。</b><%End if%>
    xhttp.open <b class="s">"POST"</b>, <b class="s">"<%=sdk.ClearUrl(app.url &  "?" & attrurl)%>"</b>, <b class='vbk'>False</b>
    <b class='mk'>'接口规定content-type值必须为application/zsml。</b>
    <b class='mk'>'注：采用UTF-8编码标记，服务器会按UTF-8编码接收数据，按UTF-8编码返回数据。</b>
    xhttp.setRequestHeader <b class="s">"Content-Type"</b>, <b class="s">"application/zsml; charset=UTF-8"</b>
    xhttp.send json
    result = xhttp.responseText  <b class='mk'>'获取返回值</b>
    <b class='vbk'>Set</b> xhttp = <b class='vbk'>Nothing</b>
    MsgBox result, vbInformation, <b class="s">"返回结果"</b>	<b class='mk'>'用弹出框显示服务器端返回的文本信息。</b>
<b class='vbk'>End Sub</b>

</pre>
<!--======VC代码========-->
<pre style='line-height:14px;display:none;' id='code1_vc'>
<b class='mk'>//以下代码在VC2010下，MFC对话框工程中编写测试。</b>
<b class='k'>#include</b> "stdafx.h"
<b class='k'>#include</b> "afxdialogex.h"
<b class='k'>#include</b> &lt;afxinet.h&gt;

<b class='mk'>//......此处省略其它窗口事件相关代码</b>
<div class='exped'><pre><img onclick='expcode(this)' class='expimg' src='<%=app.virpath%>skin/default/images/11.gif'><span class='pl'>CString UTF8ToUnicode(<b class='k'>char</b>* UTF8) <b class='mk'>//字符串编码函数： utf8转unicode。</b></span><span class='exphide'>
{
	DWORD dwUnicodeLen;
	TCHAR *pwText;
	CString strUnicode;
	dwUnicodeLen = MultiByteToWideChar(CP_UTF8,0,UTF8,-1,NULL,0);
	pwText = new TCHAR[dwUnicodeLen];
	<b class='k'>if</b> (!pwText) { <b class='k'>return</b> strUnicode; }
	MultiByteToWideChar(CP_UTF8,0,UTF8,-1,pwText,dwUnicodeLen);
	strUnicode.Format(_T("%s"),pwText);
	<b class='k'>delete</b> []pwText;
	<b class='k'>return</b> strUnicode;
}</span></pre></div>
<div class=''><pre><img onclick='expcode(this)' class='expimg' src='<%=app.virpath%>skin/default/images/12.gif'><span class='pl'><b class='k'>void</b> GetApiData()	<b class='mk'>//调用接口获取返回数据行数</b></span><span class='exphide'>
{
     CInternetSession session(_T("HttpClient"));
     CHttpConnection * Server = NULL;
     CHttpFile * file = NULL;<%If postc0 = False then%>
     CString json = _T(<b class=s>"{ session: \"<%=defSessionStr%>\"<%=cmdkey2%>, datas: ["</b>);	<b class='mk'></b>
<script>
	var list = window.data.params;
	for(var i=0; i<list.length; i++) {
		document.write("     json += _T(<b class=s>\"{id:\\\"" + list[i][0] + "\\\", val:\\\"" + (list[i][3]?clongText(list[i][3]):"......") + "\\\"}" + (i<(list.length-1)?",":"") + "\"</b>);\t\t<b class='mk'>//" + list[i][1] + "</b>");
		if(i<list.length-1){ document.write("\n"); }
	}			
</script>
     json = json + _T(<b class=s>"]}"</b>);<%else%>
     json = _T(<b class=s>"{ session: \"<%=defSessionStr%>\"<%=cmdkey2%>} "</b>);<b class='mk'>//本接口只需附加上会话凭证即可，没有额外参数。</b><%End if%>
     <b class='mk'>//接口规定content-type值必须为application/zsml。</b>
     <b class='mk'>//注：采用unicode编码标记，服务器会按unicode编码接收数据，按utf-8编码返回数据。</b>
     CString header =_T(<b class='s'>"Content-Type: application/zsml; charset=unicode"</b>);
     CString result = _T("");
     CString url = _T(<b class='s'>"<%=sdk.ClearUrl(app.url &  "?" & attrurl)%>"</b>);
     Server = session.GetHttpConnection(_T(<b class='s'>"<%=Request.ServerVariables("LOCAL_ADDR")%>"</b>) , (INTERNET_PORT)<%=Request.ServerVariables("SERVER_PORT")%>); 	<b class='mk'>//服务器端口</b>
     file = Server->OpenRequest(CHttpConnection::HTTP_VERB_POST,_T(url));
     file->AddRequestHeaders(header);
     file->SendRequest(header,(LPVOID)(LPCTSTR)json,json.GetLength()*2 );
     DWORD httpStatus;
     file->QueryInfoStatusCode(httpStatus);
     <b class='k'>if</b> (httpStatus == HTTP_STATUS_OK)
     {
          CString strLine;
          <b class='k'>int</b> mread;
          <b class='k'>while</b>((mread = file->ReadString(strLine)) > 0)
               result = result + strLine;
     }
     <b class='k'>delete</b> file;
     <b class='k'>delete</b> Server;
     session.Close();
     MessageBox(NULL,UTF8ToUnicode((char *)result.GetBuffer()), L<b class='s'>"返回信息"</b>, MB_OK); <b class='mk'>//用弹出框显示服务器端返回的文本信息。</b>
}</span>
</div>
<b class='k'>void</b> DemoDlgDlg::OnBnClickedOk()
{
     GetApiData(); <b class='mk'>//在点击按钮事件中调用获取接口数据函数。</b>
}
</pre>
<!--======C#代码========-->
<pre style='line-height:14px;display:none;' id='code1_c#'>
<b class='mk'>//以下代码在VS2010环境下, Web项目模式中编写测试。</b>
<b class='k'>using</b> System;
<b class='k'>using</b> System.Web.UI;
<b class='k'>using</b> System.Text;
<b class='k'>using</b> System.Net;

<b class='k'>namespace</b> demo
{
    <b class='k'>public partial class</b> _Default : System.Web.UI.Page
    {
        <b class='k'>protected void</b> Page_Load(<b class='k'>object</b> sender, EventArgs e)
        {<%If postc0 = False then%>
            <b class='k'>string</b> json = <b class=s>"{session:\"<%=defSessionStr%>\"<%=cmdkey2%>, datas:["</b>;
<script>
	var list = window.data.params;
	for(var i=0; i<list.length; i++) {
		document.write("            json += <b class=s>\"{id:\\\"" + list[i][0] + "\\\", val:\\\"" + (list[i][3]?clongText(list[i][3]):"......") + "\\\"}" + (i<(list.length-1)?",":"") + "\"</b>;\t\t<b class='mk'>//" + list[i][1] + "</b>");
		if(i<list.length-1){ document.write("\n"); }
	}			
</script>
            json = json + <b class=s>"]}"</b>;<%else%>
            json = <b class=s>"{ session: \"<%=defSessionStr%>\"<%=cmdkey2%> } "</b>; <b class='mk'>//本接口只需附加上会话凭证即可，没有额外参数。</b><%End if%>
            <b class='k'>byte[]</b> data = Encoding.UTF8.GetBytes(json);
            string url = <b class=s>"<%=sdk.ClearUrl(app.url &  "?" & attrurl)%>"</b>;
            WebClient webClient = <b class='k'>new</b> WebClient();
            <b class='mk'>//接口规定content-type值必须为application/zsml。</b>
            <b class='mk'>//注：采用utf-8编码标记，服务器会按utf-8编码接收数据，按utf-8编码返回数据。</b>
            webClient.Headers.Add(<b class=s>"Content-Type"</b>, <b class=s>"application/zsml; charset=utf-8"</b>);
            <b class='k'>byte[]</b> responseData = webClient.UploadData(url, <b class=s>"POST"</b>, data);
            string result = Encoding.UTF8.GetString(responseData);
            Response.Write(result);	<b class='mk'>//输出返回结果</b>
        }
    }
}
</pre>

<!--======ASP========-->
<pre style='line-height:14px;display:none;' id='code1_asp' >
<b class='yl'>&lt;%</b>
    <b class='vbk'>Option Explicit</b>
    <b class='vbk'>Dim</b> xhttp, json, result, items
    <b class='vbk'>Set</b> xhttp = Server.CreateObject(<b class='s'>"Msxml2.ServerXmlHttp"</b>)<%If postc0 = False then%>
    <b class='vbk'>redim</b> items(<script>document.write((window.data.params.length>0?window.data.params.length-1:0))</script>)
<script>
    var list = window.data.params;
    for(var i=0; i<list.length; i++) {
        document.write("    items("+ i +") = <b class=s>\"{id:\"\"" + list[i][0] + "\"\", val:\"\"" + (list[i][3]?clongText(list[i][3]):"......") + "\"\"}\"</b>\t\t<b class='mk'>'" + list[i][1] + "</b>");
        if(i<list.length-1){ document.write("\n"); }
    }            
</script>
    json = <b class=s>"{session:""<%=defSessionStr%>""<%=cmdkey1%>, datas: ["</b>  +  join(items,<b class='s'>","</b>) + <b class='s'>"]}"</b><%else%>
    json = <b class=s>"{session:""<%=defSessionStr%>""<%=cmdkey1%>}"</b> <b class='mk'>'本接口只需附加上会话凭证即可，没有额外参数。</b><%End if%>
    xhttp.open <b class="s">"POST"</b>, <b class="s">"<%=sdk.ClearUrl(app.url &  "?" & attrurl)%>"</b>, <b class='vbk'>False</b>
    xhttp.setRequestHeader <b class="s">"Content-Type"</b>, <b class="s">"application/zsml; charset=UTF-8"</b>	<b class='mk'>'接口规定content-type值必须为application/zsml。</b>
    xhttp.send json
    result = xhttp.responseText  <b class='mk'>'获取返回值</b>
    <b class='vbk'>Set</b> xhttp = <b class='vbk'>Nothing</b>
    Response.write result<b class='mk'>	 '输出接口返回信息。</b>
<b class='yl'>%&gt;</b>
</pre>

<!--======Php========-->
<pre style='line-height:14px;display:none;' id='code1_php' >
<b class='yl'>&lt;?php</b>
     $ch = curl_init();<%If postc0 = False then%>
     $json = <b class=s>'{session:"<%=defSessionStr%>" <%=Replace(cmdkey3,"""""","""")%>, datas:['</b>;
<script>
    var list = window.data.params;
    for(var i=0; i<list.length; i++) {
        document.write("     $json .= <b class=s>\'  {id:\"" + list[i][0] + "\", val:\"" + (list[i][3]?clongText(list[i][3]):"......") + "\"}" + (i<(list.length-1)?",":"") + "\';</b>\t\t<b class='mk'>/*" + list[i][1] + "*/</b>");
        if(i<list.length-1){ document.write("\n"); }
    }            
</script>
     $json .= <b class=s>']}'</b>;<%else%>
     $json = <b class=s>'{session:"<%=defSessionStr%>"<%=cmdkey3%> }';</b> <b class='mk'>/*本接口只需附加上会话凭证即可，没有额外参数。*/</b><%End if%>
     curl_setopt($ch, CURLOPT_POST, 1);
     curl_setopt($ch, CURLOPT_URL, <b class=s>'<%=sdk.ClearUrl(app.url &  "?" & attrurl)%>'</b>);
     curl_setopt($ch, CURLOPT_POSTFIELDS, $json);
     curl_setopt($ch, CURLOPT_HTTPHEADER, array(
          <b class=s>'Content-Type: application/zsml; charset=utf-8'</b>,	 <b class='mk'>/*接口规定content-type值必须为application/zsml。*/</b>
          <b class=s>'Content-Length: '</b>.strlen($json))
     );
     ob_start();
     curl_exec($ch);  <b class='mk'>/*输出返回结果*/</b>
     $b=ob_get_contents();
     ob_end_clean();
     echo $b
<b class='yl'>?&gt;</b>
</pre>

<!--======JS========-->
<pre style='line-height:14px;display:none;' id='code1_js' >
<b class='k'>&lt;script</b> <b class='r'>type</b>=<b class='s'>"text/javascript"</b><b class='k'>&gt;</b>
    <b class='k'>var</b> xhttp = <b class='k'>new</b> (XMLHttpRequest?XMLHttpRequest:ActiveXObject)(<b class='s'>"Msxml2.XMLHTTP"</b>);<%If postc0 = False then%>
    <b class='k'>var</b> json = <b class='s'>'{session:"<%=defSessionStr%>"<%=cmdkey3%>, datas: [';</b>
<script>
    var list = window.data.params;
    for(var i=0; i<list.length; i++) {
       document.write("    json += <b class=s>\' {id:\"" + list[i][0] + "\", val:\"" + (list[i][3]?clongText(list[i][3]):"......") + "\"}" + (i<(list.length-1)?",":"") + "\';</b>\t\t<b class='mk'>//" + list[i][1] + "</b>");
       if(i<list.length-1){ document.write("\n"); }
    }          
</script>
    json += <b class='s'>']}'</b>;<%else%>
    <b class='k'>var</b> json = <b class='s'>'{session:"<%=defSessionStr%>"<%=cmdkey3%>}';</b> <b class='mk'>//本接口只需附加上会话凭证即可，没有额外参数。</b><%End if%>
    xhttp.open(<b class='s'>"POST"</b>, <b class='s'>"<%=sdk.ClearUrl(app.url &  "?" & attrurl)%>"</b>, <b class='k'>false</b>);
    <b class='mk'>//接口规定content-type值必须为application/zsml。</b>
    xhttp.setRequestHeader(<b class='s'>"Content-Type"</b>, <b class='s'>"application/zsml; charset=utf-8"</b>)
    xhttp.send(json);
    result = xhttp.responseText;
    xhttp = null;
    alert(result)
<b class='k'>&lt;/script&gt;</b>
</pre>


<!--======Java========-->
<pre style='line-height:14px;display:none;' id='code1_java' >
<b class='mk'>//以下代码在ADT下，Android工程中编写测试。</b>
<div class='exped'><pre><img onclick='expcode(this)' class='expimg' src='<%=app.virpath%>skin/default/images/11.gif'><span class='pl'><b class='k'>package</b> com.example.demo;  <b class='mk'>//引用包</b></span><span class='exphide'>
<b class='k'>import</b> android.os.Bundle;
<b class='k'>import</b> android.app.Activity;
<b class='k'>import</b> android.view.Menu;
<b class='k'>impor</b>t java.io.InputStream;
<b class='k'>import</b> java.io.OutputStreamWriter;
<b class='k'>import</b> java.net.HttpURLConnection;  
<b class='k'>import</b> java.net.URL;</span></pre></div>
<div class='exped'><pre><img onclick='expcode(this)' class='expimg' src='<%=app.virpath%>skin/default/images/11.gif'><span class='pl'><b class='k'>public class</b> MainActivity <b class='k'>extends</b> Activity {  <b class='mk'>//程序入口函数</b></span><span class='exphide'>
    <b class='gr'>@Override</b>
    <b class='k'>protected void</b> onCreate(Bundle savedInstanceState) {
        <b class='k'>super</b>.onCreate(savedInstanceState);
        (<b class='k'>new</b> GetApiDataThread()).start();	<b class='mk'>//调用获取接口数据线程</b>
        setContentView(R.layout.activity_main);
    }

    <b class='gr'>@Override</b>
    <b class='k'>public boolean</b> onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.main, menu);
        <b class='k'>return true;</b>
    }
}
</span></pre></div>
<div><pre><img onclick='expcode(this)' class='expimg' src='<%=app.virpath%>skin/default/images/12.gif'><span class='pl'><b class='k'>class</b> GetApiDataThread <b class=k>extends</b>  Thread {  <b class='mk'>//获取接口数据类，由于网络请求不能放在主线程中，所以单独放在另一个线程类中</b></span><span class='exphide'>
    <b class='gr'>@Override</b>
    <b class='k'>public void</b> run() {<%If postc0 = False then%>
        String json = <b class='s'>"{session:\"<%=defSessionStr%>\"<%=cmdkey2%>, datas:["</b>;
<script>
	var list = window.data.params;
	for(var i=0; i<list.length; i++) {
		document.write("        json += <b class=s>\" {id:\\\"" + list[i][0] + "\\\", val:\\\"" + (list[i][3]?clongText(list[i][3]):"......") + "\\\"}" + (i<(list.length-1)?",":"") + "\"</b>;\t\t<b class='mk'>//" + list[i][1] + "</b>");
		if(i<list.length-1){ document.write("\n"); }
	}			
</script>
        json += <b class='s'>"]}"</b>;<%else%>
        String json = <b class='s'>"{session:\"<%=defSessionStr%>\"<%=cmdkey2%>}"</b>; <b class='mk'>//本接口只需附加上会话凭证即可，没有额外参数。</b><%End if%>
        <b class='k'>try</b>{
            URL url = <b class='k'>new</b> URL(<b class='s'>"<%=sdk.ClearUrl(app.url &  "?" & attrurl)%>"</b>);
            HttpURLConnection cn = (HttpURLConnection) url.openConnection();  
            cn.setDoOutput(true);  
            cn.setDoInput(true);  
            cn.setUseCaches(false);  
            cn.setInstanceFollowRedirects(true);  
            cn.setRequestMethod(<b class='s'>"POST"</b>);
            <b class='mk'>//接口规定content-type值必须为application/zsml，本案例采用utf-8编码，该编码为默认编码方式，也可不写。</b>
            cn.setRequestProperty(<b class='s'>"Content-Type"</b>, <b class='s'>"application/zsml; charset=utf-8"</b>);
            cn.connect(); 
            OutputStreamWriter out = <b class='k'>new</b> OutputStreamWriter(cn.getOutputStream(), <b class='s'>"UTF-8"</b>);
            out.append(json);  
            out.flush();  
            out.close();
            <b class='k'>int</b> length = (int) cn.getContentLength();
            InputStream is = cn.getInputStream();  
            <b class='k'>if</b> (length != -1) {  
                <b class='k'>byte</b>[] data = <b class='k'>new</b> byte[length];  
                <b class='k'>byte</b>[] temp = <b class='k'>new</b> byte[512];  
                <b class='k'>int</b> readLen = 0;  
                <b class='k'>int</b> destPos = 0;  
                <b class='k'>while</b> ((readLen = is.read(temp)) > 0) {  
                    System.arraycopy(temp, 0, data, destPos, readLen);  
                    destPos += readLen;  
                }  
                String result = <b class='k'>new</b> String(data, <b class='s'>"UTF-8"</b>);
                System.out.println(result);  <b class='mk'>//输出接口返回结果</b>
            }
        } <b class='k'>catch</b>(Exception e) {
            System.out.println(e.getMessage());
        }
    }
}</pre></span></div>
</pre>

<!--======Http========-->
<pre style='line-height:14px;display:none;' id='code1_http'>
<b class='key'>POST</b> <%=request.servervariables("URL")%> <b class='key'>HTTP/1.1</b>
<b class='cgy'>Host:</b> <%=request.servervariables("Server_Name")%>
<b class='cgy'>Content-Type:</b> application/zsml; charset=UTF-8	<b class='mk'>//注意:此处的类型不是常规的text/html</b>

{
	session: <b class='s'>"<%=defSessionStr%>"</b><%If postc0 = False Or Len(cmdkey)>0 then%>,<%End if%>  <b class='mk'>//<%
	If InStr(1, request.servervariables("URL"), "mobilephone/login.asp", 1) > 0 Then
		Response.write "在本接口中，该值为空即可。"
	Else
		Response.write "session是会话凭证，从系统登陆接口返回的session属性中取。"
	End if
	%></b><%
	if Len(cmdkey)>0 Then
		Response.write vbcrlf & "	cmdkey:<b class='s'>""" & cmdkey & """</b>"
		If postc0 = False  Then  Response.write ","
	End if
	If postc0 = False then%>
	datas: [
<script>
	var list = window.data.params;
	for(var i=0; i<list.length; i++) {
		document.write("\t\t{ id:<b class='s'>\"" + list[i][0] + "\"</b>,\tval:<b class='s'>\"" +  (list[i][3]?clongText(list[i][3]):"******") + "\"</b> }\t<b class='mk'>//" + list[i][1] + "</b>");
		if(i<list.length-1){ document.write("\n"); }
	}			
</script>
	]<%End if%>
}
</pre>
</div>
</div>
			</div>
</div>
<div class='group-title'>返回结果</div>
<div class='fcell'>
	<div style='padding:20px'>
	<%
	Dim l, i, obj
	Set l = CreateObject("TLI.TLIApplication")
	Dim robjs : robjs = Split(returnmodels, ",")
	Dim cclss(), disclss()
	%>
	<div style='margin-left:20px;color:#666'>接口返回结果统一为ZBDocumen类型<a href='<%=app.virpath%>apidoc/object.asp?cls=ZSMLLibrary.DocumentClass' target=_blank >【ZBDocument类型说明】</a>，该类型包含【接口状态】+【实际业务】两部分。<br>在本接口中，实际业务数据类型含以下<%=CStr(ubound(robjs)+1)%>种情况：</div>
	<%
	Dim infoc : infoc =  ubound(robjs)
	Dim infos(), jsonitems, infoobj
	ReDim cclss(infoc)
	ReDim disclss(infoc)
	If infoc >= 0 Then ReDim infos(infoc)
	Response.write "<ol style='margin:10px;margin-left:50px;line-height:24px;font-size:13px;font-family:微软雅黑,黑体'>"
	For i = 0 To ubound(robjs)
		Dim clsName : clsName = robjs(i)
		If InStr(clsName,"<")> 0 Then
			cclss(i) = Replace(Split(clsName,">")(0),"<","")
			robjs(i) = Replace(clsName, "<" & cclss(i) & ">", "" )
		End If
		Set obj = server.createobject("ZSMLLibrary." & robjs(i))
		Set infoobj =  l.InterfaceInfoFromObject(obj)
		Set obj = nothing
		Dim remark  : remark =infoobj.HelpString
		Response.write "<li><a href='" & app.virpath & "apidoc/object.asp?cls=ZSMLLibrary." & robjs(i) & "' target=_blank  title='点击查看该类型的详细描述' >"
		If Len(cclss(i)) Then Response.write "<span class=vr>&lt;" & cclss(i) & "&gt;</span>"
		If Len(remark)>52 Then remark = Left(remark,50) & "..."
		Response.write robjs(i) & "</a> :&nbsp;&nbsp;<b class='mk' style='font-family:宋体'>" & remark & "</b> </li>"
		If Len(cclss(i)) > 0 Then '定义要去除的对象
			Select Case LCase(robjs(i))
				Case "sourceclass":
					disclss(i) = Replace(",icoview,table,options,trees,text,", "," & LCase(cclss(i)) & ",",",")
			End Select
		End if
		Set  infos(i) = infoobj
	Next
	Response.write "<ol>"
	%>
	</div>
</div>
	<%
	For i = 0 To ubound(infos)
	Set obj = infos(i)
%>
<div class='group-title' style=''><b style='color:#8888aa;font-family:微软雅黑,arial;font-weight:normal'><%=robjs(i)%> 类</b></div>
<div class='fcell'>
			<div class='codeitembar'>
				<div class='codeitem c7 sel' id='ct7_<%=cstr(i+2)%>' onclick='codec(this,<%=cstr(i+2)%>)'><span style='margin-right:10px;font-size:12px'>字段集</span></div>
				<div class='codeitem c6' id='ct6_<%=cstr(i+2)%>' onclick='codec(this, <%=cstr(i+2)%>)'><span style='margin-right:5px;font-family:arial'><b style='font-size:10px;font-weight:normal'>JSON</b>格式</span></div>
			</div>
			<div style='margin:2px;margin-top:0px;border:1px solid #b5b8e4;'>
			<div style='border:15px solid #f2f2fc'><div style='border:1px dotted #ccc;padding:15px;' id='code<%=cstr(i+2)%>'>
				<div style='line-height:14px;' id='code<%=cstr(i+2)%>_字段集' >
					<table width="100%" style="text-align: center;" class='listtb' cellPadding="6">
					<col style='width:18%'><col style='width:18%'><col style='width:64%;padding-left:8px'>
					<tr class='top'>
						<td>字段名称</td>
						<td>数据类型</td>
						<td>详细说明</td>
					</tr>
					<%
						Dim Item
						For Each Item In obj.Members
							If Item.InvokeKind = 2 Or Item.InvokeKind = 0 Then
							If Len(disclss(i) & "") = 0  Or InStr(disclss(i), "," & LCase(item.name) & ",") = 0 then
					%>
						<tr>
							<td><%=item.name%></td>
							<td><%
							If Item.ReturnType.typeinfo Is Nothing Then
								Response.write  app.GetVarType(Item.ReturnType.VarType)
							Else
								Response.write  "<a href='" & app.virpath & "apidoc/object.asp?cls=ZSMLLibrary." & Replace(Item.ReturnType.typeinfo.name, "_", "") & "' target=_blank>" & Replace(Item.ReturnType.typeinfo.name, "_", "") & "</a> 对象"
							End if
							%></td>
							<td align='left' style='color:#008800'>
							<%
								Response.write Item.HelpString
							%>	
							</td>
						</tr>
					<%
							End if
							End if
						next
					%>
					</table>
				</div>

				<div style='line-height:14px;display:none' id='code<%=cstr(i+2)%>_JSON格式' >
					<%
					Dim m1, m2, objattr, isfail
					isfail = 0
					Select Case LCase(robjs(i))
						Case LCase("InitFailClass") : m1 = "init" : m2 = "fail": objattr = "fail": isfail = 1
						Case LCase("InitSysClass") : m1 = "init" : m2 = "sys": objattr = "sys": isfail = 2
						Case LCase("MessageClass") : m1 = "message" : m2 = "": objattr = "message": isfail = 2
						Case LCase("BillClass") : m1 = "bill" : m2 = "": objattr = "bill": isfail = 2
						Case LCase("SourceClass") : m1 = "source" : m2 = "": objattr = "source": isfail = 2
					End Select
					If InStr(1,app.url,"mobilephone/logout.asp",1)>0 Then isfail = 1
					%>
					<div style='overflow:auto;overflow-y:hidden' id='resultjson'>
						<ol style='margin-left:0px'>
						<li>{</li>
							<ol>
							<li>header: {</li>
								<ol>
									<li>status: <b class='s'>"0"</b>,	<b class='mk'>//会话状态, 0表示正常，其它值表示异常。</b></li>
									<li>message:<b class='s'>"ok"</b>	<b class='mk'>//当status值不为0时，message会返回异常原因描述。</b><%If isfail=2 then%></li>
									<li>session:<b class='s'>"******"</b>	<b class='mk'>//注意：该值即为系统返回的会话凭证，当调用其它需要授权的接口时需要附带该值。</b><%End if%></li>
								</ol>
							<li>},</li>
							<li>body : {</li>
							     <ol>
									<li>model  : <b class='s'>"<%=m1%>"</b>,</li><%If Len(m2)>0 then%>
									<li>action : <b class='s'>"<%=m2%>"</b>,</li><%End if%>
									<li><img class='jsnl' id='firstimg<%=i%>' src='<%=app.virpath%>skin/default/images/11.gif' onclick='expjsn(this)'><%	
										Response.write objattr & ":" 
										app.showchildObject obj, 2, robjs(i) & "类型的JSON描述从此处开始" , exped, disclss(i)
									%>
								</ol>
							<li>}</li>
						  </ol>
						<li>}</li>
						</ol>
					</div>
					<script>
						var ols = $ID("resultjson").getElementsByTagName("ol");
						for (var i=0; i<ols.length ; i++ )
						{
							var li =  ols[i].children[ols[i].children.length-1];
							var t = li.innerHTML;
							if(t.indexOf(",")>0) {
								li.innerHTML = t.replace(",","");
							}
						}
						expjsn($ID("firstimg<%=i%>"));
					</script>
				</div>
			</div>
		</div>
		</div>
</div>
<%
	next
	%>
<div class='group-title' style=''>注意事项：</div>
<div  class='fcell' style='border-bottom:0px'>
	<div style='color:#aaa;margin:20px'>
	<%
	If app.existsProc("Api_ShowNote") Then
		Call Api_ShowNote(title)
	Else
		Response.write "无注意事项。"
	End if
	%></div>
</div>
</div>
</div>
<br><br><br>
</body>
<div style='font-family:微软雅黑,黑体;font-weight:bold;font-size:23px;color:white;position:absolute;top:5px;left:20px;padding-top:10px'>
	<img src='<%=app.virpath%>images/api_logo.gif'>
</div>
</html>
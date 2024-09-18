
var openlaststr=window.openLastCon;
var IntOpenPre;//是否开启尊称
var IntOpenAutoSend=0;//是否开启定时发送
var strSendRecuse;//发送结果返回值，字符型
var strSendRecuse1=-100;//发送结果返回值,数字型
var strSendRecuse="";
var logid=0;
function testfunc()
{
	getMobanSort();
	getMobanList("");
}

//记录日志
function logMessage(phone,con,stact,logs,needrec,sendmoney,sendnum,zchstr) {
	var url = "logMessage.asp";
	var msgStr = escape(con);
	msgStr = msgStr.replace(/%A0/g,"%20");
	msgStr = msgStr.replace(/\+/g,"%2B");
	msgStr = msgStr.replace(/%B7/g,"%C2%B7");
	var postStr="phone="+escape(phone)+"&con="+msgStr+"&stact="+escape(stact)+"&logid="+escape(logs)+"&needrec="+needrec+"&sendmoney="+sendmoney+"&sendnum="+sendnum+"&zchstr="+escape(zchstr)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
	xmlHttp.open("POST", url, false);
	xmlHttp.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
	xmlHttp.setRequestHeader("Content-Length",postStr.length);
	xmlHttp.onreadystatechange = function(){
	if (xmlHttp.readyState == 4)
	{
		var Cnum=xmlHttp.responseText;
		if (!isNaN(Cnum))
		{
			logid=Cnum;
		}
		else
		{
			alert(Cnum);
		}
	}
	};
	xmlHttp.send(postStr);
	xmlHttp.abort();
}
//获取发送状态
function getErrStr(errNum,phone,con,logs,sendmoney,sendnum) {
	var needrec=0;
	if(isNaN(errNum)==true||errNum.length==0)
	{
		errNum=-100;
	}
	logMessage(phone,con,errNum,logs,needrec,sendmoney,sendnum,"");
	var url = "SendStatus.asp?errNum="+escape(errNum)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function()
	{
		updateErrStr(phone,con);
	};
	xmlHttp.send(null);
}

function updateErrStr(phone,con) {
	var isRequestNum=window.sendPhone;  //是否请求发送还是单发
	var qf=window.sendQF;//是否是从群发页面来的
	if (xmlHttp.readyState == 4)
	{
		var response = xmlHttp.responseText.split("</noscript>")[1];
		if (isRequestNum!=""&&isRequestNum!=null&&qf=="")
		{
			tip.innerHTML="";
			strSendRecuse=response;
			document.getElementById("takeName").value="";
			document.getElementById("messageContent").value="";
		}
		else
		{
			strSendRecuse1=response;
			document.getElementById("takeName").value="";
			document.getElementById("messageContent").value="";
			strSendRecuse=response;
		}
		document.getElementById("button").disabled="";
		document.getElementById("sendErr").innerText="";
		if(strSendRecuse!=""&&strSendRecuse!=null&&IntOpenAutoSend==0)
		{
			div_send.innerHTML = "发送状态:"+strSendRecuse+"<br/><br/><br/><br/><p  align='center'>【<a href='javascript:void(0)' title='继续发送' onclick=window.location.href='sendMessage.asp';window.DivClose(this)>继续发送</a>】&nbsp;&nbsp;&nbsp;【<a href='javascript:void(0)' title='查看记录' onclick=window.parent.location.href='loglist.asp';window.DivClose(this)>查看记录</a>】&nbsp;&nbsp;&nbsp;【<a href='javascript:void(0)' title='关闭' onclick=window.DivClose(this)>关闭</a>】</p>";
		}
		else if(strSendRecuse!=""&&strSendRecuse!=null&&IntOpenAutoSend==1)
		{
			div_send.innerHTML = "友情提示:您的定时已提交！";
		}
		else
		{
			div_send.innerHTML = "sendSubmit过程返回未知结果["+strSendRecuse+","+IntOpenAutoSend+"]！";
		}
	}
}
//获取短信模板分类
function getMobanSort()
{
	var url = "getSort.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		updateMobanSort();
	};
	xmlHttp.send(null);
}

function updateMobanSort() {
	if (xmlHttp.readyState < 4) {
		MesSort.innerHTML="loading...";
	}
	if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText.split("</noscript>")[1];
		MesSort.innerHTML=response.replace("\r","").replace("\n","");
	}
}

//获取短信模板列表
function getMobanList(id) {
	var url = "getMoban.asp?sortid="+id+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		updateMobanList();
	};
	xmlHttp.send(null);
}

function updateMobanList() {
	if (xmlHttp.readyState < 4) {
		MobanList.innerHTML="loading...";
	}
	if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText.split("</noscript>")[1];
		MobanList.innerHTML=response.replace("\r","").replace("\n","");
	}
}

//获取短信模板内容
function getMobanCon(con)
{
	if (con!=null &&con!="")
	{
		document.getElementById("messageContent").innerHTML=document.getElementById("messageContent").innerHTML+con;
	}
}
function  FF(y,sid)  {
   if (!y) {
     y=1;
   }
   var xmlhttp;
   if (window.ActiveXObject) {
      xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
   }else if(window.XMLHttpRequest)  {
      xmlhttp=new XMLHttpRequest();
   }
   if (xmlhttp) {
        xmlhttp.onreadystatechange=function () {
                if(xmlhttp.readyState==4)  {
             if(xmlhttp.status==200)  {
                   var yy=unescape(xmlhttp.responseText);
                   show(yy);
                }else {
                				 alert("error");
                					}
          }
              }
           xmlhttp.open("get","getMoban.asp?page="+y+"&sortid="+sid);
           xmlhttp.send(null);
    }
}
function show(text) {
document.getElementById("MobanList").innerHTML=text;
}

function IGetOpenPre(x1)
{
	IntOpenPre=x1;
}


function changeICON()
{
	var tmparr=","+document.getElementById("takeName").innerText+",";
	var tmparr2 = document.getElementById("hiddenNum").innerText;
	tmparr = tmparr + tmparr2;
	var imgnode=parent.document.getElementsByTagName("img");
	for(var i=0;i<imgnode.length;i++)
	{
		var tmpstr=imgnode[i].id;
		if(tmpstr&&tmpstr.indexOf("IMG")==0)
		{
			var tmparr2=tmpstr.split("_");
			var recid=tmparr2[0];
			var mobilenum=tmparr2[1];
			if(tmparr.indexOf(","+mobilenum+",")>=0)
			{
				parent.document.getElementById(recid+"_"+mobilenum).src="../images/d14.gif";
			}
			else
			{
				parent.document.getElementById(recid+"_"+mobilenum).src="../images/155.gif";
			}
		}
	}
}

//清空号码
function clearNum()
{	
	document.getElementById('takeName').value='';
	document.getElementById('hiddenNumShow').value='';
	document.getElementById('hiddenNum').value='';
	document.getElementById('qccon1').style.display='none';
	document.getElementById('tallNum').innerHTML='0';	
	document.getElementById('takeName').focus();
	changeICON();	
}

//去除重复号码
function removeRepeatNum(){
	changeICON();
	document.getElementById('takeName').value=checkDoberPhone(document.getElementById('takeName').value);
	document.getElementById('takeName').focus();	
}

-->

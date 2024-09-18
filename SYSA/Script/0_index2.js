function showprobarmx(){
	var ifm = document.getElementById("setiframe");
	var w = document.body.offsetWidth;
	var l = parseInt((w-400)/2);
	try{
	ifm.contentWindow.document.body.style.cssText ="background-Color:#5f6f90;color:#ffffff";
	}catch(e){}
	ifm.style.cssText = "z-index:1500;position:absolute;width:98%;height:100px;left:1%;top:10px;";
}
function CheckJMG(cnum)
{
	if (cnum==25)
	{
		return true;
	}
	else
	{
		var jmgpwd=document.getElementById("jmgpwd");
		if (jmgpwd)
		{
			var NT120Client=document.getElementById("NT120Client");
			var guid=document.getElementById("guid");
			var miyao=document.getElementById("miyao");
			var inputjmg=document.getElementById("inputjmg");
			var tishi=document.getElementById("tishi");
			return CheckPWD(jmgpwd,NT120Client,guid,miyao,tishi);
		}
		else
		{
			var boolreturn=false ;
			var namestr=document.getElementById("username").value;
			var pwdstr=document.getElementById("password").value
			var xmlHttp2 = new GetXmlHttp();
			var my_url="checkjmgou.asp"
			xmlHttp2.open('post',my_url,false);
			xmlHttp2.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
			var postStr = "sort=1&namestr="+escape(namestr)+"&pwdstr="+pwdstr+"&date1="+Math.round(Math.random()*100);
			xmlHttp2.onreadystatechange=function()
			{
				if(xmlHttp2.readyState==4)
				{
					if(xmlHttp2.status==200)
					{
						returnStr=xmlHttp2.responseText;
						if (returnStr.replace(/\r\n/g,"")=="0")
						{
							boolreturn=true;
						}
						else if (returnStr.replace(/\r\n/g,"")=="1")
						{
							document.getElementById("tishi").innerHTML="用户名密码错误或账号已被冻结！";
							boolreturn=false;
						}
						else
						{
							if(returnStr.indexOf("index2.asp")>=0) {
								document.getElementById("tishi").innerHTML="请输出正确的账号密码！";
							}
							else{
								document.getElementById("jmgTR").style.display="";
								document.getElementById("jmgou").innerHTML=returnStr;
								document.getElementById("jmgpwd").focus();
								var NT120Client=document.getElementById("NT120Client");
								var inputjmg=document.getElementById("inputjmg");
								var tishi=document.getElementById("tishi");
								CheckData(NT120Client,inputjmg,tishi);
							}
							boolreturn=false;
						}
					}
				}
			}
			xmlHttp2.send(postStr);
			return boolreturn;
		}
	}
}
function GetXmlHttp(){
	 var MSXML	=	['Msxml2.XMLHTTP',
					 'Microsoft.XMLHTTP',
					 'Msxml2.XMLHTTP.5.0',
					 'Msxml2.XMLHTTP.4.0',
					 'Msxml2.XMLHTTP.3.0'
					];
	 if (window.XMLHttpRequest) {
		 try { return new XMLHttpRequest(); }
		 catch (e) { }
	 }
	 for (var i = 0; i < MSXML.length; i++)
	 {
			try {return new ActiveXObject(MSXML[i]);}
			catch (e){}
	 }
}
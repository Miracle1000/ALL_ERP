
$=function(id){return (typeof(id)=='object')?id:document.getElementById(id);}; 



function getNowIPMac(uid,gtype,tarobj)
{
  var url = "getNOWIPMAC.asp?sid="+escape(uid)+"&t="+gtype+"&time=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function()
  {
	  if (xmlHttp.readyState == 4) {
	    var response = xmlHttp.responseText;
	    var tmp=(response.split("</noscript>")[1]).split(";");
	    if(tmp[0]=="0")
	    {
				$(tarobj).value=tmp[1];
			}
			else
			{
			    alert(tmp[1]);
                $(tarobj).value=tmp[1];
			}
	  }
  };
  xmlHttp.send(null);  
}

function getSetting(sid,divid,flg)
{
  var url = "getIPMAC.asp?sid="+escape(sid)+"&t="+flg+"&time=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function()
  {
  getf(sid,divid,flg);
  };
  xmlHttp.send(null);  
}

function getf(sid,divid,flg)
{
  if (xmlHttp.readyState < 4) {
		$(divid).innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
		$(divid).innerHTML=response;
  }
}

$
function FormSubmit(atype,ftype)
{
	if(ftype==1)
	{
		if(atype=='ed'&&$("hid1").value=="")
		{
			alert("请先选择要修改的记录");
			return false;
		}
		if(($("pip1").value!=""&&!checkIpAddr($("pip1").value))||($("pip2").value!=""&&!checkIpAddr($("pip2").value)))
		{
			alert("IP地址格式不合法，请检查");
			return false;
		}
		else
		{
			$("active1").value=atype;
			$("form1").submit();
		}
	}
	else
	{
		if(atype=='ed'&&$("hid2").value=="")
		{
			alert("请先选择要修改的记录");
			return false;
		}
		while($("pmac").value.indexOf("-")>0) $("pmac").value=$("pmac").value.replace("-",":");
		if($("pmac").value!=""&&!CheckMAC($("pmac").value))
		{
			alert("MAC地址格式不合法，请按照00:24:21:19:BD:E4的格式输入");
			return false;
		}
		else
		{
			$("active2").value=atype;
			$("form2").submit();
		}
	}
}

function checkIpAddr(ipaddr)
{
	if(ipaddr.replace(" ","")=="")
	{
		return false;
	}
	var ss = ipaddr.split(".");
	if(ss.length != 4)
	{
		return false;
	}
	var i=0;
	for(i=0;i<ss.length;i++)
	{
		if(isNaN(ss[i]) || parseInt(ss[i]) < 0 || parseInt(ss[i])>255)
		{
			return false;
		}
	}
	return true;
}

function CheckMAC(inputmac)
{
	var reg_name=/[A-F\d]{2}:[A-F\d]{2}:[A-F\d]{2}:[A-F\d]{2}:[A-F\d]{2}:[A-F\d]{2}/;
	return reg_name.test(inputmac);
}

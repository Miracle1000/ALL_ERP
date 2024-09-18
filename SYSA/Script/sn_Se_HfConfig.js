
var xmlHttpRequest;  
function createXMLHttpRequest(){  
try  
{  xmlHttpRequest=new XMLHttpRequest();}  
	catch (e)  
	{  
		try  
		{  xmlHttpRequest=new ActiveXObject("Msxml2.XMLHTTP");}  
		catch (e)  
		{  
			try  
				{ xmlHttpRequest=new ActiveXObject("Microsoft.XMLHTTP");}  
			catch (e)  
				{alert("您的浏览器不支持AJAX！");return false;  }  
			}  
		}  
	}  
function TrToggle(ClassName)
{
	$("."+ClassName+"").toggle();
}
function delClassItem(cid,ord)
{
if(ord!=0&&ord!="")
{
	createXMLHttpRequest();  
	xmlHttpRequest.open("POST","Ajax_DelConfigList.asp",true);  
	xmlHttpRequest.setRequestHeader("Content-Type","application/x-www-form-urlencoded");  
	xmlHttpRequest.onreadystatechange = DelResponse;  
	xmlHttpRequest.send("ord="+""+ord+"");  
}
	$("."+cid.parentElement.parentElement.parentElement.className).remove();

		try
	{ parent.frameResize();}
	catch(e){}
}
//处理返回信息函数   
function DelResponse(){  
		if(xmlHttpRequest.readyState == 4){  
				if(xmlHttpRequest.status == 200){  
				var tempStr = xmlHttpRequest.responseText.split("</noscript>")[1];
				alert(tempStr);
				try
				{ parent.frameResize();}
				catch(e){} 
				}else{  
					 // window.alert("请求页面异常");  
				}  
		}  
} 

function showGatePersonDiv(InputName,InputId,defaultval,strUrl,width,height)
{
	if(strUrl.indexOf("?")>=0)
	{
		strUrl=strUrl+"&InputName="+InputName+"&InputId="+InputId+"&W3="+defaultval;
		}
	else
	{
		strUrl=strUrl+"?InputName="+InputName+"&InputId="+InputId+"&W3="+defaultval;
		}
	var w = 960 , h = 640 ;
	window.open( strUrl ,'newwin','width=' + w + ',height=' + h + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');
}
function GetUserVal(inputId,val,username)
{
	$("#"+inputId+"_hiden").val(val);
	$("#"+inputId+"").val(username);
}

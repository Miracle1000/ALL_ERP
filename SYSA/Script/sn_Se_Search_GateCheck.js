
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
$(document).ready(function(){
$("#GetVale").click(function(){
		var W1="",W2="",W3="";
		var check1=$('input[type="checkbox"][name="W1"]:checked');
		check1.each(function()
		{
			if(W1=="")
			{
				W1=$(this).val();
				}
			else
			{
				W1=W1+","+$(this).val();
				}
		});
		var check2=$('input[type="checkbox"][name="W2"]:checked');
		check2.each(function()
		{
			if(W2=="")
			{
				W2=$(this).val();
				}
			else
			{
				W2=W2+","+$(this).val();
				}
		});
		var check3=$('input[type="checkbox"][name="W3"]:checked');
		check3.each(function()
		{
			if(W3=="")
			{
				W3=$(this).val();
				}
			else
			{
				W3=W3+","+$(this).val();
				}
		});
		var IsAll;
		if(document.getElementById("rbtn1").checked)
		{IsAll=1;}
		else if(document.getElementById("rbtn2").checked)
		{IsAll=0;}

	createXMLHttpRequest();  
	xmlHttpRequest.open("POST","Ajax_GateCheck.asp",true);  
	xmlHttpRequest.setRequestHeader("Content-Type","application/x-www-form-urlencoded");  
	xmlHttpRequest.onreadystatechange = GateCheckResponse;  
	xmlHttpRequest.send("W1="+W1+"&W2="+W2+"&W3="+W3+"&IsAll="+IsAll+"&r="+ Math.random());  


});
});
//处理返回信息函数   
function GateCheckResponse(){  
		if(xmlHttpRequest.readyState == 4){  
				if(xmlHttpRequest.status == 200){  
				var tempStr = xmlHttpRequest.responseText.split("</noscript>")[1];
if(tempStr.indexOf("$$")>0)
{
				window.opener.GetUserVal(window.InputId,tempStr.split("$$")[0],tempStr.split("$$")[1]);
				winClose();
}
else
{
window.alert("请求页面异常");  
}

				}else{  
					 // window.alert("请求页面异常");  
				}  
		}  
} 
function winClose()
{
	try
	{
		window.opener=null;
		window.open('','_self');
		window.close();
	}catch(e)
	{}
}

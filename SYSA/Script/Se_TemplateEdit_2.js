
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
function GetTemplateVal(Val)
{
	createXMLHttpRequest();
	xmlHttpRequest.open("POST","Ajax_Question.asp",true);
	xmlHttpRequest.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
	xmlHttpRequest.onreadystatechange = TempResponse;
	xmlHttpRequest.send("list="+""+Val+"");

}
//处理返回信息函数
function TempResponse(){
		if(xmlHttpRequest.readyState == 4){
				if(xmlHttpRequest.status == 200){
				var tempStr = xmlHttpRequest.responseText;
				$("#StageList").before(tempStr);
				try
				{ parent.frameResize();}
				catch(e){}
				}else{
					 // window.alert("请求页面异常");
				}
		}
}
function TrToggle(ClassName)
{
	$("."+ClassName+"").toggle();
}
function delClassItem(cid)
{
	$("."+cid.parentElement.parentElement.parentElement.className).remove();

		try
	{ parent.frameResize();}
	catch(e){}
}
function delClassItem(obj,ord)
{
if(ord!=0&&ord!="")
{
	createXMLHttpRequest();
	xmlHttpRequest.open("POST","Ajax_DelQuestionList.asp",true);
	xmlHttpRequest.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
	xmlHttpRequest.onreadystatechange = DelResponse;
	xmlHttpRequest.send("ord="+""+ord+"");
}
	$("#"+obj.parentElement.parentElement.parentElement.id).remove();

}
//处理返回信息函数
function DelResponse(){
		if(xmlHttpRequest.readyState == 4){
				if(xmlHttpRequest.status == 200){
				var tempStr = xmlHttpRequest.responseText;
				alert(tempStr);
				try
				{ parent.frameResize();}
				catch(e){}
				}else{
					 // window.alert("请求页面异常");
				}
		}
}


function CreateXMLHttpRequest()
{ 
	var xmlHttp; 
	//IE下 
	if (window.ActiveXObject)
	{ 
		try
		{xmlHttp = new ActiveXObject("Microsoft.XMLHTTP"); }
		catch(e)
		{xmlHttp = new ActiveXObject("Msxml2.XMLHTTP");}
	//其他浏览器如火狐 
	}
	else if (window.XMLHttpRequest)
	{ 
		xmlHttp = new XMLHttpRequest(); 
	} 
	return xmlHttp; 
}
function ajax()
{
	var xmlHttp=CreateXMLHttpRequest()
	var telid=document.getElementById("company").value;
	var url='../search/ajax1.asp?tel='+escape(telid)
	xmlHttp.open("GET",url,true);
	xmlHttp.onreadystatechange=function()
	{
		if (xmlHttp.readystate==4 && xmlHttp.status==200) 
		{     
			 var aa=unescape(xmlHttp.responseText);
			 callback(aa);
		}
	 }
   xmlHttp.send(null);     
}
function callback(aa)
{
	if (aa=="请选择客户！")
	{
		var person=document.getElementById("person");
		person.length=0;
	}
	else
	{
		var arr=aa.split(",");
		var person=document.getElementById("person");
		person.options.length = 0
		for(var i=0;i<arr.length;i++)
		{
			var option = new Option(arr[i],arr[i]);   //创建option
			person.options.add(option);   //添加值
		}
	}
}

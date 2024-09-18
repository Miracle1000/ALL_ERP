

function checkLoginName(){
	var name=document.getElementById("user").value;
	var url = "cu_loginname.asp?timestamp=" + new Date().getTime() + "&loginName="+escape(name);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		if (xmlHttp.readyState == 4) {
			var response = xmlHttp.responseText;
			document.getElementById("flag").value=response;
			if(response=="1"){
				document.getElementById("checkflag").innerHTML="用户名已存在";
			}
			else{document.getElementById("checkflag").innerHTML="";}
		}
	};
	xmlHttp.send(null);
}
function inselect()
{
	try
	{
		document.date.sorce2.length=0;
		if(document.date.sorce.value=="0"||document.date.sorce.value==null)
		document.date.sorce2.options[0]=new Option('--所属3地区--','0');
		else
		{
		for(i=0;i<ListUserId[document.date.sorce.value].length;i++)
		{
		document.date.sorce2.options[i]=new Option(ListUserName[document.date.sorce.value][i],ListUserId[document.date.sorce.value][i]);
		}
		}
		var index=document.date.sorce.selectedIndex;
		//sname.innerHTML=document.date.sorce.options[index].text
	}
	catch(e)
	{
		
	}
} 

//-->

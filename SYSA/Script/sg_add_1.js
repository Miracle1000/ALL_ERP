
function test()
{
  if(!confirm('确认删除吗？')) return false;
  return true ;
}
function mm(form)
{
	for (var i=0;i<form.elements.length;i++)
	{
	var e = form.elements[i];
	if (e.name != 'chkall')
	e.checked = form.chkall.checked;
	}
}
function CheckJMG()
{
	var result=document.getElementById("result");
	try{
		
		var rtn=NT120Client.NTFind();
		if(rtn!=0)
		{
			result.innerHTML="没有找到加密锁！";
		}
		else
		{
			var rtn1=NT120Client.NTLogin("123456");
			if (rtn1!=0)
			{
				result.innerHTML="加密锁密码错误！";
			}
			else
			{
				result.innerHTML="已找到加密锁！";
				var GUID=NT120Client.NTGetHardwareID();
				var Digesg=NT120Client.NTMD5(GUID);				
				document.getElementById("jmgx").value=GUID;
				document.getElementById("jmgxlh").value=GUID;
			}
		}
	}
	catch(e){
		result.innerHTML="加密锁组件加载失败！<a href='#' onclick='OnlineSetup(inputjmg)'>在线安装NT插件</a>&nbsp;<a href='../ocx/NT120Client.exe'>下载插件安装</a>";
		return false ;
	}
}
function OnlineSetup(inputjmg){
	inputjmg.innerHTML="<object CLASSID=clsid:EA3BA67D-8F11-4936-B01B-760B2E0208F6 CODEBASE='ocx/NT120Client.CAB#Version=1,00,0000' BORDER=0 VSPACE=0 HSPACE=0 ALIGN=TOP HEIGHT=0 WIDTH=0></object><input name='jmgpwd' type='password' class='login_1' oncopy='return false' oncut='return false' onpaste='return false'/><input id='guid' name='guid' type='hidden' /><input id='miyao' name='miyao' type='hidden' />"

}

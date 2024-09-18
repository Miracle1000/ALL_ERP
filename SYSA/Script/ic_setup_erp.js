/*屏蔽所有的js错误*/
function killerrors(){return true;}/*window.onerror = killerrors;*/
/*通用跳转页面函数,仅适合采用get方式提交查询页面的列表页使用
//参数：需要更新的参数列表,传入的参数如有可能出现特殊字符（如&和=符号等）请自行进行escape或者URLENCODE转换，否则可能会出问题
//举例：
//1.翻页(更新页码)：gotourl("currpage=2");表示将基础参数字符串中的currpage=1改为currpage=2，其他参数值不变
//2.更改每页显示条数：gotourl("page_count=100");表示将基础参数字符串中的page_count=10改为page_count=100，其他参数不变
//3.查询：gotourl("a=2&b=3&c=4");分别替换对应参数的值，其他不变，基础参数中如果不存在该参数则附加进去
//4.排序：gotourl("px=4");*/
function gotourl(sReplaceValue) 
{ 
	var allurl=document.URL.split("?");
	/*当前页面URL，如：http://127.0.0.1/work/telhy2.asp?currpage=1&a=1&b=2&c=3*/ 
	var baseurl="";/*基础URL,比如：http://127.0.0.1/work/telhy2.asp*/ 
	var baseparam="";/*基础参数,比如：currpage=1&a=1&b=2&c=3*/ 
	if(allurl.length>0) baseurl=allurl[0].replace("###",""); 
	var strpara=getUrl(sReplaceValue); 
	var finalurl=baseurl+(strpara.length==0?"":"?")+strpara; 
	window.location=finalurl; 
}  

function getUrl(sReplaceValue) 
{ 
	var allurl=document.URL.split("?");
	/*当前页面URL，如：http://127.0.0.1/work/telhy2.asp?currpage=1&a=1&b=2&c=3*/ 
	var baseurl="";/*基础URL,比如：http://127.0.0.1/work/telhy2.asp*/ 
	var baseparam="";/*基础参数,比如：currpage=1&a=1&b=2&c=3*/ 
	if(allurl.length>0) baseurl=allurl[0].replace("###",""); 
	if(allurl.length>1) baseparam=allurl[1].replace("###",""); 
	var arrparam=baseparam.split("&");/*分割参数*/ 
	var arrvalue=sReplaceValue.split("&");/*分割需更新的参数*/ 
	/*
	循环需更新的参数，在基础参数中查找，
	如果有值，如果找到，则替换，找不到，则添加
	如果无值，如果找到，则剔除，找不到，则不处理
	*/ 
	var appendparam=""; 
	for(var i=0;i<arrvalue.length&&arrvalue!='';i++) 
	{ 
		var flg=false; 
		var vnode=arrvalue[i].split("="); 
		var vkey=vnode[0]; 
		var vvalue=vnode[1]; 
		for(var j=0;j<arrparam.length&&arrparam!='';j++) 
		{ 
			var knode=arrparam[j].split("="); 
			var kkey=knode[0]; 
			var kvalue=knode[1]; 
			if(kkey.toLowerCase()==vkey.toLowerCase()) 
			{ 
				arrparam[j]=(vvalue==""?"":kkey+"="+escape(vvalue)); 
				flg=true; 
			} 
		} 
		if(!flg)
		{
			appendparam+=(appendparam==""?"":"&")+vkey+"="+escape(vvalue);
		}
	} 
	var strpara=""; 
	for(var i=0;i<arrparam.length&&arrparam!='';i++) { strpara+=(arrparam[i]==""?"":(strpara.length==0?"":"&")+arrparam[i]); } 
	strpara+=(strpara==""?"":(appendparam==""?"":"&"))+appendparam; return strpara; 
}  

function clearinput(obj,divid) 
{ 
	if(!obj.checked) 
	{ 
		var divobj=document.getElementById(divid); 
		var chkobj=divobj.getElementsByTagName("input"); 
		for(var i=0;i<chkobj.length;i++) 
		{ 
			if(chkobj[i].type=="checkbox"&&chkobj[i].checked&&(chkobj[i].name=="W3"||chkobj[i].name=="W2")) 
			{  
				if (chkobj[i].name=="W2"&&chkobj[i].checked) 
				{ chkobj[i].click(); } 
				else 
				{ chkobj[i].checked=false; } 
			}  
		} 
	} 
} 

function checkDot(sid,num_dot)
{
	var txtvalue=document.getElementById(sid).value;//正则获取的是数字
	if (txtvalue.indexOf('.')>0)
	{
		var txt1,txt2,txt3;
		txt1=txtvalue.split('.');
		txt2=txt1[0];
		txt3=txt1[1];					
		if (txt2.length>12)
		{//整数部分不能大于12位
			txt2=txt2.substr(0,12);
		}
		if (txt3.length>num_dot)
		{//小数部分不能大于8位
			txt3=txt3.substr(0,num_dot);
		}
		document.getElementById(sid).value=txt2+"."+txt3;
	}
	else
	{//整数不能超过12位
		if (txtvalue.length>12)
		{
			document.getElementById(sid).value=txtvalue.substr(0,12);
		}
	}
}

var RootOBJ=null;
if(opener)
{
	RootOBJ=opener.top.RootOBJ;
	RootOBJ.hWnds.Windows.Add(window);
	window.onfocus=function()
	{
		if(RootOBJ&&RootOBJ.hWnds)
		{
			RootOBJ.hWnds.Recycle();
			window.ActiveTime=(new Date()).getTime()
		}
	};
}


function DisableWindow()
{ 
	var dv=document.getElementById("wmg_disable_div");
	if(!dv)
	{
		dv=document.createElement("div");
		dv.style.cssText="display:none;position:absolute;top:0%;left:0%;width:100%;height:100%;background-color:#B9C5DD;z-index:10000;-moz-opacity:0.7;opacity:.70;filter:alpha(opacity=50)";
		dv.id="wmg_disable_div";
		document.body.appendChild(dv);
	}
	dv.style.display="block";
}

function EnableWindow()
{
	var dv=document.getElementById("wmg_disable_div");
	if(dv){dv.style.display="none";}
}

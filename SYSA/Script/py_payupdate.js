
var eindex=0;
var arrTr=""
function addNameTR(sid)
{
var tablename="table"+sid;
var table=document.getElementById(tablename);
var tr = document.createElement('tr');
tr.onmouseover=function(){this.style.backgroundColor='efefef';}
tr.onmouseout=function(){this.style.backgroundColor='';}
tr.id = "nameTr"+eindex;
tr.name = "nameTr";
table.appendChild(tr);
var td0 = document.createElement('td');
tr.appendChild(td0);
td0.align="center";
var delHref = "<A title=\"点击添加费用明细\" onclick=\"addNameTR("+sid+")\" href=\"javascript:void(0);\"><img style=\"border:0px;\" src=\"../images/add.gif\" width=\"10\" height=\"10\" alt=\"点击添加费用明细\"></A>&nbsp;&nbsp;<a href='javascript:void(0);' onclick=\"delTR('"+tr.id+"');\"><img style=\"border:1px;\" src=\"../images/del2.gif\" alt=\"点击删除费用明细\" width=\"8\" height=\"7\"></a>";
td0.innerHTML=delHref;

var td1 = document.createElement('td');
tr.appendChild(td1);
td1.align="center";
td1.innerHTML="<input type='text' size='10' name='bh_"+sid+"_"+eindex+"'/>";

var td2 = document.createElement('td');
tr.appendChild(td2);
td2.align="center";
td2.innerHTML="<input type='text' size='10' id='num_"+eindex+"' name='num_"+sid+"_"+eindex+"' onKeyUp=\" value=value.replace(/[^ \\d]/g,'')\" onpropertychange=\"document.getElementById('allnum').value=getSumNum();\"/>";

var td3 = document.createElement('td');   
tr.appendChild(td3);
td3.align="center";
td3.innerHTML="<input type='text' size='10' id='money_"+eindex+"' name='money_"+sid+"_"+eindex+"' onKeyUp=\" value=value.replace(/[^\\d*|\\.]/g,'')\" onpropertychange=\"document.getElementById('allpay').value=getSumMoney();\" />";
var td4 = document.createElement('td');   
tr.appendChild(td4);
td4.align="center";
td4.innerHTML="<input type='text' size='20' name='note_"+sid+"_"+eindex+"'/>"; 

var td5 = document.createElement('td');
tr.appendChild(td5);
td5.align="center";
td5.innerHTML="<input type='hidden' size='10' name='hdj_"+sid+"_"+eindex+"' id='hdj_"+sid+"_"+eindex+"'><span class=red id='dj_"+sid+"_"+eindex+"'></span><span class=\"red\" id='tjdj_"+sid+"_"+eindex+"'><a href='javascript:void(0);' onclick=\"javascript:window.open('results.asp?tyid=dj_"+sid+"_"+eindex+"','eventcom3','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=0,left=100,top=100');\"><img class='resetElementHidden' style=\"border:0px; width:12px;height:11px;\" src=\"../images/jiantou7.gif\" alt=\"添加\" width=\"8\" height=\"7\"> <img class='resetElementShow' style=\"border:0px; width:12px;height:11px;display:none;\" src=\"../skin/default/images/MoZihometop/content/lvw_addrow_btn.png\" alt=\"添加\"  width=\"8\" height=\"7\">添加关联单据</a></span>&nbsp;|<input type=\"radio\" name=\"moban\" value=\"hdj_"+sid+"_"+eindex+"\" id=\"moban\" />&nbsp;复制&nbsp;|&nbsp;<a href='javascript:void(0);' onclick=\"plupdate('hdj_"+sid+"_"+eindex+"');\">粘贴</a>";
arrTr=arrTr+','+eindex;
eindex=eindex+1;
}

function delTR(lin)
{ 
	var tr=document.getElementById(lin);
	tr.parentNode.removeChild(tr);
	var num=lin.substring(6,lin.length);
	arrTr=arrTr.replace(num,"");
	document.getElementById('allpay').value=getSumMoney();
	document.getElementById('allnum').value=getSumNum();
}

function xmldata1(ord)
{
	var dhtml=document.getElementById('dhtml');
	var url="selgl.asp?ord="+ord;
	xmlHttp.open("GET",url,false);
	xmlHttp.onreadystatechange=updatepage;
	xmlHttp.send(null);	
}
function updatepage()
{
	if(xmlHttp.readyState<4)
	{
			
	}
	if(xmlHttp.readyState==4)
	{
		
		var response = xmlHttp.responseText;
		var re1=response.indexOf('</noscript>');
		var re2=response.length;
		ajaxhtml=response.substring(re1+11,re2);
		document.getElementById('dhtml').innerHTML=ajaxhtml;
		var left=parseInt(event.clientX)-500;
		var top=event.clientY;
		var htmlheight=document.body.offsetHeight;
		var scrollheight=window.screen.availHeight;
		if(parseInt(scrollheight)-parseInt(top)<500)
		{
			top=(parseInt(top)-340)
		}
		document.getElementById('dhtml').style.top=top+"px";
		document.getElementById('dhtml').style.left=left+"px";
		document.getElementById('dhtml').style.display='block';
		updatePage3();
	}
}
function updatePage3()
{
	xmlHttp.abort();
}
function hidelabel()
{	
	document.getElementById('dhtml').style.display='none';
}
function xmldata2(ord,k)
{
	var url="insgl.asp?ord="+ord;
	xmlHttp.open("GET",url,false);
	xmlHttp.onreadystatechange=function(){updatepage1(k)};
	xmlHttp.send(null);	
}
function updatepage1(k)
{
	if(xmlHttp.readyState<4)
	{
			
	}
	if(xmlHttp.readyState==4)
	{
		
		var ajaxtxt = xmlHttp.responseText;
		var re1=ajaxtxt.indexOf('</noscript>');
		var re2=ajaxtxt.length;
		var ajaxhtml=ajaxtxt.substring(re1+11,re2);
		
		
		document.getElementById(k).value=ajaxhtml;
		var tyid=k.substring(1,k.length);

		var sidval='h'+tyid;
		var tjval='tj'+tyid;
		var unameval=tyid;
		document.getElementById(sidval).value=ajaxhtml;
		document.getElementById(tjval).style.display='none';				
		document.getElementById(unameval).innerHTML="<a href=\"javascript:void(0)\" onMouseOut=\"hidelabel()\" onMouseOver=\"xmldata1("+ajaxhtml+")\">已添加</a>&nbsp;&nbsp;<a href='javascript:void(0);' onclick=\"javascript:window.open('results.asp?tyid="+tyid+"&valid="+ajaxhtml+"','eventcom3','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=0,left=100,top=100');\">修改</a>&nbsp;";
		updatePage3();
	}
}
function plupdate(tid)
{
	var moban=document.all('moban');

	var mobvalue
	for(i=0;i<moban.length;i++)
	{
		if(moban[i].checked==true)
		{
			var mobvalue=moban[i].value;
		}
	}
	try
	{
	if(document.getElementById(mobvalue).value=="" || isNaN(document.getElementById(mobvalue).value))
	{alert('您选择的模板为空');return}
	}
	catch(e1)
	{return}
	xmldata2(document.getElementById(mobvalue).value,tid);
}

function downtype(tid)
{
	ti="tid"+tid
	var downTr=document.getElementById(ti);
	if (downTr.style.display=='none')
	{
		downTr.style.display='block'
		addNameTR(tid)
	}
	else
	{
		addNameTR(tid)
	}
}

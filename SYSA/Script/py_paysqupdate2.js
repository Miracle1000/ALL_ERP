
function ask()
{
	if(document.getElementById('title').value=="")
	{
		document.getElementById('tit').innerHTML="*必填"
		return false;
	}	
	var membool=false
	var memarr=document.getElementsByName('member2');
	for (i=0;i<memarr.length;i++)
	{
		if(memarr[i].checked)
		{
			membool=true
		}
	}
	if(membool==false)
	{
		document.getElementById('ry').innerHTML="*必填"
		return false;
	}
	document.date.action="savesq.asp?num="+arrTr+"&ord="+window.paysqOrd;
	var money1 = $("#allpay").val();
	if (money1.length == 0) money1 = 0;
	var member2 = $("input[name=member2]")[0].value;
	spclient.GetNextSP('paysq',0, money1, 0, member2);
	return false;
}
var eindex=0;
var arrTr=""
var TarValue=0
var Tarmb=""
function addNameTR(sid,tid)
{
	document.getElementById('allpay').value=getSumMoney();
	document.getElementById('allpay').setAttribute("readOnly",'true');
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
var delHref = "<A title=\"点击添加费用明细\" onclick=\"addNameTR('"+sid+"','"+tid+"')\" href=\"javascript:void(0);\"><img style=\"border:0px;\" src=\"../images/add.gif\" width=\"10\" height=\"10\" alt=\"点击添加费用明细\"></A>&nbsp;&nbsp;<a href='javascript:void(0);' onclick=\"delTR('"+tr.id+"',"+sid+");\"><img style=\"border:1px;\" src=\"../images/del2.gif\" alt=\"点击删除费用明细\" width=\"8\" height=\"7\"></a>";
td0.innerHTML=delHref;
var zdyarr=tid.split(',');
for (i=0;i<zdyarr[0]+1;i++)
{
if(zdyarr[i]=="startime")
{
var td6 = document.createElement('td');
tr.appendChild(td6);
td6.align="center";
td6.innerHTML="<INPUT name='startime_"+sid+"_"+eindex+"' onmouseup=\"toggleDatePicker('daysOfMonth1"+eindex+"','date.startime_"+sid+"_"+eindex+"')\" value=\""+window.nowDate+"\" size=9 id=\"daysOfMonthPos1"+eindex+"\"><DIV id='daysOfMonth1"+eindex+"' style=\"POSITION: absolute\"></DIV>"
}
if(zdyarr[i]=="endtime")
{
var td7 = document.createElement('td');
tr.appendChild(td7);
td7.align="center";
td7.innerHTML="<INPUT name='endtime_"+sid+"_"+eindex+"' onmouseup=\"toggleDatePicker('daysOfMonth2"+eindex+"','date.endtime_"+sid+"_"+eindex+"')\" value=\""+window.nowDate+"\" size=9 id=\"daysOfMonthPos2"+eindex+"\"><DIV id='daysOfMonth2"+eindex+"' style=\"POSITION: absolute\"></DIV>"
}
if(zdyarr[i]=="mdd")
{
var td8 = document.createElement('td');
tr.appendChild(td8);
td8.align="center";
td8.innerHTML="<input type='text' size='10' name='mdd_"+sid+"_"+eindex+"'/>";
}
if(zdyarr[i]=="smdd")
{
var td25 = document.createElement('td');
tr.appendChild(td25);
td25.align="center";
td25.innerHTML="<input type='text' size='10' name='smdd_"+sid+"_"+eindex+"'/>";
}
if(zdyarr[i]=="lic")
{
var td9 = document.createElement('td');
tr.appendChild(td9);
td9.align="center";
td9.innerHTML="<input type='text' size='10' name='lic_"+sid+"_"+eindex+"'/>";
}
if(zdyarr[i]=="jtgj")
{
var td10 = document.createElement('td');
tr.appendChild(td10);
td10.align="center";
td10.innerHTML="<input type='text' size='10' name='jtgj_"+sid+"_"+eindex+"'/>";
}
if(zdyarr[i]=="retime")
{
var td11 = document.createElement('td');
tr.appendChild(td11);
td11.align="center";
td11.innerHTML="<INPUT name='retime_"+sid+"_"+eindex+"' onmouseup=\"toggleDatePicker('daysOfMonth3"+eindex+"','date.retime_"+sid+"_"+eindex+"')\" value=\""+window.nowDate+"\" size=9 id=\"daysOfMonthPos3"+eindex+"\"><DIV id='daysOfMonth3"+eindex+"' style=\"POSITION: absolute\"></DIV>"
}
if(zdyarr[i]=="startime1")
{
var td12 = document.createElement('td');
tr.appendChild(td12);
td12.align="center";
td12.innerHTML="<INPUT name='startime1_"+sid+"_"+eindex+"' onmouseup=\"toggleDatePicker('daysOfMonth4"+eindex+"','date.startime1_"+sid+"_"+eindex+"')\" value=\""+window.nowDate+"\" size=9 id=\"daysOfMonthPos4"+eindex+"\"><DIV id='daysOfMonth4"+eindex+"' style=\"POSITION: absolute\"></DIV>"
}
if(zdyarr[i]=="endtime1")
{
var td13 = document.createElement('td');
tr.appendChild(td13);
td13.align="center";
td13.innerHTML="<INPUT name='endtime1_"+sid+"_"+eindex+"' onmouseup=\"toggleDatePicker('daysOfMonth5"+eindex+"','date.endtime1_"+sid+"_"+eindex+"')\" value=\""+window.nowDate+"\" size=9 id=\"daysOfMonthPos5"+eindex+"\"><DIV id='daysOfMonth5"+eindex+"' style=\"POSITION: absolute\"></DIV>"
}
if(zdyarr[i]=="city")
{
var td14 = document.createElement('td');
tr.appendChild(td14);
td14.align="center";
td14.innerHTML="<input type='text' size='10' name='city_"+sid+"_"+eindex+"'/>";
}
if(zdyarr[i]=="hatol")
{
var td15 = document.createElement('td');
tr.appendChild(td15);
td15.align="center";
td15.innerHTML="<input type='text' size='10' name='hatol_"+sid+"_"+eindex+"'/>";
}
if(zdyarr[i]=="ggdate")
{
var td16 = document.createElement('td');
tr.appendChild(td16);
td16.align="center";
td16.innerHTML="<INPUT name='ggdate_"+sid+"_"+eindex+"' onmouseup=\"toggleDatePicker('daysOfMonth6"+eindex+"','date.ggdate_"+sid+"_"+eindex+"')\" value=\""+window.nowDate+"\" size=9 id=\"daysOfMonthPos6"+eindex+"\"><DIV id='daysOfMonth6"+eindex+"' style=\"POSITION: absolute\"></DIV>"
}
if(zdyarr[i]=="ggdx")
{
var td17 = document.createElement('td');
tr.appendChild(td17);
td17.align="center";
td17.innerHTML="<input type='text' size='10' name='ggdx_"+sid+"_"+eindex+"'/>";
}
if(zdyarr[i]=="ggsy")
{
var td18 = document.createElement('td');
tr.appendChild(td18);
td18.align="center";
td18.innerHTML="<input type='text' size='10' name='ggsy_"+sid+"_"+eindex+"'/>";
}
if(zdyarr[i]=="lw")
{
var td19 = document.createElement('td');
tr.appendChild(td19);
td19.align="center";
td19.innerHTML="<input type='text' size='10' name='lw_"+sid+"_"+eindex+"'/>";
}
if(zdyarr[i]=="xytime")
{
var td20 = document.createElement('td');
tr.appendChild(td20);
td20.align="center";
td20.innerHTML="<INPUT name='xytime_"+sid+"_"+eindex+"' onmouseup=\"toggleDatePicker('daysOfMonth7"+eindex+"','date.xytime_"+sid+"_"+eindex+"')\" value=\""+window.nowDate+"\" size=9 id=\"daysOfMonthPos7"+eindex+"\"><DIV id='daysOfMonth7"+eindex+"' style=\"POSITION: absolute\"></DIV>"
}
if(zdyarr[i]=="yt")
{
var td21 = document.createElement('td');
tr.appendChild(td21);
td21.align="center";
td21.innerHTML="<input type='text' size='10' name='yt_"+sid+"_"+eindex+"'/>";
}
if(zdyarr[i]=="bh")
{
var td1 = document.createElement('td');
tr.appendChild(td1);
td1.align="center";
td1.innerHTML="<input type='text' size='10' name='bh_"+sid+"_"+eindex+"'/>";
}
if(zdyarr[i]=="num")
{
var td2 = document.createElement('td');
tr.appendChild(td2);
td2.align="center";
td2.innerHTML="<input type='text' size='3' id='num_"+eindex+"' name='num_"+sid+"_"+eindex+"' onKeyUp=\"checkDot('num_"+eindex+"','0')\" onpropertychange=\"formatData(this,'int');document.getElementById('allnum').value=getSumNum();\"/>";
}
if(zdyarr[i]=="money1")
{
var td3 = document.createElement('td');   
tr.appendChild(td3);
td3.align="center";
td3.innerHTML="<input type='text' size='8' id='money_"+eindex+"' name='money_"+sid+"_"+eindex+"' onpropertychange=\"formatData(this,'money');document.getElementById('allpay').value=getSumMoney();\" onKeyUp=\"checkDot('money_"+eindex+"','"+window.sysConfig.moneynumber+"')\" />";
}
if(zdyarr[i]=="intro")
{
var td4 = document.createElement('td');   
tr.appendChild(td4);
td4.align="center";
td4.innerHTML="<input type='text' size='15' name='note_"+sid+"_"+eindex+"'/>";
}
}
var td5 = document.createElement('td');
tr.appendChild(td5);
td5.align="center";
td5.innerHTML="<input type='hidden' size='10' name='hdj_"+sid+"_"+eindex+"' id='hdj_"+sid+"_"+eindex+"'><span class=red id='dj_"+sid+"_"+eindex+"'></span><span class=\"red\" id='tjdj_"+sid+"_"+eindex+"'><a href='javascript:void(0);' onclick=\"javascript:window.open('resultsq.asp?tyid=dj_"+sid+"_"+eindex+"&ord="+window.paysqOrd+"&sort1="+sid+"','eventcom3','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=0,left=100,top=100');\"><img class='resetElementHidden' style=\"border:0px; width:12px;height:11px;\" src=\"../images/jiantou7.gif\" alt=\"添加\"> <img class='resetElementShow' style=\"border:0px; width:12px;height:11px;display:none;\" src=\"../skin/default/images/MoZihometop/content/lvw_addrow_btn.png\" alt=\"添加\">添加</a></span>&nbsp;|&nbsp;<span id=\"fzzdj_"+sid+"_"+eindex+"\"><a href=\"###\" onClick=\"setTar("+TarValue+",'fzdj_"+sid+"_"+eindex+"')\"><span id=\"fzdj_"+sid+"_"+eindex+"\">复制</span></a></span>&nbsp;|&nbsp;<a href='javascript:void(0);' onclick=\"plupdate('hdj_"+sid+"_"+eindex+"','"+sid+"');\">粘贴</a>";
arrTr=arrTr+','+eindex;
eindex=eindex+1;
}

function delTR(lin,sort1)
{
	document.getElementById('allpay').value=""
	var num=lin.substring(6,lin.length);
	arrTr=arrTr.replace(num,"");	
	var aa="hdj_"+sort1+"_"+num;	
	var hh1=document.getElementById(aa).value;
	var tr=document.getElementById(lin);
	tr.parentNode.removeChild(tr);
	var url="del1.asp?del=1&delid="+hh1;
	xmlHttp.open("GET",url,false);
	xmlHttp.send(null);	
	document.getElementById('allpay').value=getSumMoney();
	document.getElementById('allnum').value=getSumNum();
	var Trs = $("tr:[name=nameTr]").size();
	if (Trs==0)
	{
		document.getElementById('allpay').removeAttribute("readOnly");	
	}
}

function setTar(tar,mb)
{
	TarValue=tar;
	if(TarValue!=0)
	{
		if (Tarmb!="")
		{
			document.getElementById(Tarmb).style.color="black";
		}
		Tarmb=mb;
	document.getElementById(mb).style.color="red";
	}
}
function xmldata1(ord)
{
	var dhtml=document.getElementById('dhtml');
	var obj=event.srcElement;
	var x=obj.offsetLeft,y=obj.offsetTop;
	var obj2=obj;
	var offsetx=25;
	while(obj2=obj2.offsetParent)
	{
		x+=obj2.offsetLeft;  
		y+=obj2.offsetTop;
	}
	var left=parseInt(x)-500;
	var top=parseInt(y);
	var url="selglsq.asp?ord="+ord;
	xmlHttp.open("GET",url,false);
	xmlHttp.onreadystatechange=function()
	{
		if(xmlHttp.readyState<4)
		{
				
		}
		if(xmlHttp.readyState==4)
		{
			var response = xmlHttp.responseText;
			
			ajaxhtml=response
			dhtml.innerHTML=ajaxhtml;
			dhtml.style.top=top;
			dhtml.style.left=left;
			dhtml.style.display='';
			updatePage3();
		}
	}
	xmlHttp.send(null);	
}
function updatePage3()
{
	xmlHttp.abort();
}
function hidelabel()
{	
	document.getElementById('dhtml').style.display='none';
}
function xmldata2(ord,k,sid)
{
	var url="insglsq.asp?ord="+ord+"&sort1="+sid+"&fid="+window.paysqOrd;

	xmlHttp.open("GET",url,false);
	xmlHttp.onreadystatechange=function(){updatepage1(k,sid)};
	xmlHttp.send(null);	
}
function updatepage1(k,sort1)
{
	if(xmlHttp.readyState<4)
	{
			
	}
	if(xmlHttp.readyState==4)
	{
		
		var ajaxtxt = xmlHttp.responseText;
		var ajaxhtml=ajaxtxt
		document.getElementById(k).value=ajaxhtml;
		var tyid=k.substring(1,k.length);
		var sidval='h'+tyid;
		var tjval='tj'+tyid;
		var unameval=tyid;
		var fzzval='fzz'+tyid;
		document.getElementById(sidval).value=ajaxhtml;
		document.getElementById(tjval).style.display='none';				
		document.getElementById(unameval).innerHTML="<a href=\"javascript:void(0)\" onMouseOut=\"hidelabel()\" onMouseOver=\"xmldata1("+ajaxhtml+")\" onclick=\"javascript:window.open('resultsq.asp?tyid="+tyid+"&valid="+ajaxhtml+"&ord="+window.paysqOrd+"&sort1="+sort1+"','eventcom3','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=0,left=100,top=100');\">修&nbsp;改</a>";
		document.getElementById(fzzval).innerHTML="<a href=\"###\" onClick=\"setTar("+ajaxhtml+",'fz"+tyid+"')\"><span id=\"fz"+tyid+"\">复制</span></a>"
		updatePage3();
	}
}
function plupdate(tid,sid)
{
	if(TarValue==0)
	{alert('请选择要粘贴的内容');return}
	else
	{xmldata2(TarValue,tid,sid);}
}

function downtype(tid,zdarr)
{
	ti="tid"+tid
	var downTr=document.getElementById(ti);
	if (downTr.style.display=='none')
	{
		downTr.style.display=''
		addNameTR(tid,zdarr)
	}
	else
	{
		addNameTR(tid,zdarr)
	}
}
function chanceR(name)
{
	document.getElementById('sqr').innerHTML=name;
}


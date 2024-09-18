

function pro_type1(val)
{
	url="getDate.asp?tp=1&Sid="+val;
	xmlHttp.open("GET",url,false)
	xmlHttp.onreadystatechange=function()
	{
		if (xmlHttp.readyState==4)
		{
			var test=xmlHttp.responseText;
			var re1=test.indexOf('</noscript>');
			var re2=test.length;
			ajaxhtml=test.substring(re1+11,re2);
			document.getElementById('test2').innerHTML="("+ajaxhtml+")";
		}
	}
	xmlHttp.send(null);	
}

var a=0
function setMe(a,b)
{
	$('#ddd').dialog('open');
	$('#ddd').dialog('move',{left:100,top:150});
	searchMe('',1)
}
function searchMe(a,b)
{
	var sid=setID();
	var u_name=document.getElementById('u_name').value;
	var u_ph=document.getElementById('u_ph').value;
	var u_xlh=document.getElementById('u_xlh').value;
	var u_bh=document.getElementById('u_bh').value;
	var u_xh=document.getElementById('u_xh').value;
	var tdobj=document.getElementById("searchdiv");
	var url = "ajax_yp1.asp?a=" + escape(u_name)+"&b=" + escape(u_bh)+"&c=" + escape(u_xh)+"&d=" + escape(u_ph)+"&e=" + escape(u_xlh)+"&sid=" +sid+"&cp="+b+"&stamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET",url,false)
	xmlHttp.send(null);	
	document.getElementById('selectiddiv').innerHTML=xmlHttp.responseText;
}
function setID()
{
	var sidArr=document.getElementsByName('prod_id');
	var sidList="";
	for(i=0;i<sidArr.length;i++)
	{
		if (sidList=="")
		{sidList=sidArr[i].value;}
		else
		{sidList=sidList+","+sidArr[i].value;}
	}
	return sidList;
}
function tu(obj){
	obj.className = "toolitem"
}
function tm(obj){
	obj.className = "toolitem_hover"
}
function addMx(id,prod_name,prod_bh,prod_xh,sort1,prod_num,sto_name,sto_id,pro_name,prod_ph,prod_xlh,prod_sctime,prod_ystime)
{
	var tablename="prod_mx";
	var table=document.getElementById(tablename);
	var tr = document.createElement('tr');
	tr.onmouseover=function(){this.style.backgroundColor='efefef';}
	tr.onmouseout=function(){this.style.backgroundColor='';}
	tr.id = "jstr_"+id;
	tr.name = "nameTr";	
	table.appendChild(tr);
	var td0 = document.createElement('td');
	tr.appendChild(td0);
	td0.align="center";
	var delHref = "<div align=\"left\">"+prod_name+"&nbsp;&nbsp;<a href=\"###\" onclick=\"del_TR('"+tr.id+"','"+id+"')\"><img src=\"../images/del2.gif\"/></a></div><input type=\"hidden\" value=\""+id+"\" name=\"prod_id\">";
	td0.innerHTML=delHref;
	var td1 = document.createElement('td');
	tr.appendChild(td1);
	td1.align="center";
	var delHref = "<div align=\"center\">"+prod_bh+"</div>";
	td1.innerHTML=delHref;
	var td2 = document.createElement('td');
	tr.appendChild(td2);
	td2.align="center";
	var delHref = "<div align=\"center\">"+prod_xh+"</div>";
	td2.innerHTML=delHref;
	var td3 = document.createElement('td');
	tr.appendChild(td3);
	td3.align="center";
	var delHref = "<div align=\"center\">"+sort1+"</div>"
	td3.innerHTML=delHref;
	var td5 = document.createElement('td');
	tr.appendChild(td5);
	td5.align="center";
	var delHref = "<input name=\"prod_num\" type=\"text\" id=\"prod_num\" onKeyUp=\"value=value.replace(/[^\\d]/g,'')\"  size=\"12\" maxlength=\"12\"><span class=\"red\" name=\"numtext\"></span>";
	td5.innerHTML=delHref;
	var td6 = document.createElement('td');
	tr.appendChild(td6);
	td6.align="center";
	delHref="<div align=\"center\">"+sto_name+"<input name=\"sto_id\" type=\"hidden\" value=\""+sto_id+"\" id=\"sto_id\"></div>"	
	td6.innerHTML=delHref;
	var td4 = document.createElement('td');
	tr.appendChild(td4);
	td4.align="center";
	var delHref = "<div align=\"center\"><input name=\"prod_num1\" type=\"hidden\" value=\""+prod_num+"\" id=\"prod_num1\">"+prod_num+"</div>"
	td4.innerHTML=delHref;
	var td9 = document.createElement('td');
	tr.appendChild(td9);
	td9.align="center";
	var delHref ="<div align=\"center\">"+pro_name+"</div>"
	td9.innerHTML=delHref;
	var td91 = document.createElement('td');
	tr.appendChild(td91);
	td91.align="center";
	var delHref ="<div align=\"center\">"+prod_ph+"</div>"
	td91.innerHTML=delHref;
	var td92 = document.createElement('td');
	tr.appendChild(td92);
	td92.align="center";
	var delHref ="<div align=\"center\">"+prod_xlh+"</div>"
	td92.innerHTML=delHref;	
	var td93 = document.createElement('td');
	tr.appendChild(td93);
	td93.align="center";
	var delHref ="<div align=\"center\">"+prod_sctime+"</div>"
	td93.innerHTML=delHref;	
	var td94 = document.createElement('td');
	tr.appendChild(td94);
	td94.align="center";
	var delHref ="<div align=\"center\">"+prod_ystime+"</div>"
	td94.innerHTML=delHref;	
	var td12 = document.createElement('td');
	tr.appendChild(td12);
	td12.align="center";
	var delHref ="<INPUT type=\"text\" maxlength=\"200\" name=\"get_note1\" size=\"15\">"
	td12.innerHTML=delHref;
	document.getElementById('tr_'+id).style.display='none';
	a=a+1
}
function del_TR(id,id1)
{
	$('#ddd').window('close');
	var tr=document.getElementById(id);
	tr.parentNode.removeChild(tr);
	document.getElementById('tr_'+id1).style.display='';
}
function chaValue(val)
{
	var num="prod_num"+val
	var price="prod_price"+val
	var num1=document.getElementById(num).value;
	var price1=document.getElementById(price).value;
	if (num1!="" && price1!="")
	{
		document.getElementById("prod_allmoney"+val).value=parseFloat(num1)*parseFloat(price1);
	}
}
function batch(name,value)
{
	var obj=document.getElementsByName(name)[0];
	var tgname=obj?obj.tagName:"input";
	var arrlist=document.getElementsByTagName(tgname);
	for(i=0;i<arrlist.length;i++)
	{
		if(arrlist[i].name.indexOf(name)==0)
		{
			arrlist[i].value=value;
		}
	}
}
function ask1()
{
	if(document.getElementById('get_title').value=="")
	{
		alert('发放标题不能为空')
		return false;
	}
	return true;
}
function setType(val)
{
	if(val==1)
	{
		document.getElementById("get_storeuser").style.display='none'
		document.getElementById("type1").style.display='none'
	}
	else if(val==2)
	{
		document.getElementById("get_storeuser").style.display=''
		document.getElementById("type1").style.display=''
	}
}


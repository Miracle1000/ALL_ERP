

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
var a=1
function setMx()
{
	$('#ddd').dialog('open');
	$('#ddd').dialog('move',{left:100,top:150});
	searchMe('',1)
}
function searchMe(a,b)
{
	sid=setID();
	var u_name=document.getElementById('u_name').value;
	var u_ph=document.getElementById('u_ph').value;
	var u_xlh=document.getElementById('u_xlh').value;
	var u_bh=document.getElementById('u_bh').value;
	var u_xh=document.getElementById('u_xh').value;
	var tdobj=document.getElementById("searchdiv");
	var url = "ajax_yp2.asp?a=" + escape(u_name)+"&b=" + escape(u_bh)+"&c=" + escape(u_xh)+"&d=" + escape(u_ph)+"&e=" + escape(u_xlh)+"&sid=" +sid+"&cp="+b+"&stamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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
function addMx(id,prod_name,prod_bh,prod_xh,sort1,prod_ph,prod_xlh,prod_sctime,prod_ystime,pro_name,pro_type,nums)
{
	try{
	var b=document.getElementsByName("sortlist")
	a=b.length+1;
	for (i=0;i<b.length;i++)
	{
		sortlist[i].innerHTML=i+1;
	}
	}
	catch(e){}
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
	td0.align="left";
	var delHref = "<div align=\"left\">"+prod_name+"<input type=\"hidden\" value=\""+id+"\" name=\"prod_id\">&nbsp;&nbsp;<a href=\"###\" onclick=\"del_TR('"+tr.id+"','"+id+"')\"><img src=\"../images/del2.gif\"/></a>&nbsp;<span id='sortlist'>"+a+"</span></div>";
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
	var delHref = "<input name=\"prod_num\" value=\"1\" type=\"text\" id=\"prod_num\" onKeyUp=\"value=value.replace(/[^\\d*|\\.]/g,'')\"  size=\"12\" maxlength=\"12\"><span class=\"red\" name=\"numtext\"></span>";
	td5.innerHTML=delHref;
	var tds = document.createElement('td');
	tr.appendChild(tds);
	tds.align="center";
	var delHref = nums+"<input type=\"hidden\" value=\""+nums+"\" name=\"ret_num\">";
	tds.innerHTML=delHref;
	var tds1 = document.createElement('td');
	tr.appendChild(tds1);
	tds1.align="center";
	var delHref = "<select name=\"ret_state\">";
	delHref = delHref+"<option value=\"1\">否</option>";
	delHref = delHref+"<option value=\"2\">是</option>";
	delHref = delHref+"</select>";
	tds1.innerHTML=delHref;
	var td6 = document.createElement('td');
	tr.appendChild(td6);
	td6.align="center";
	delHref="<div align=\"center\">"+prod_ph+"</div>"
	td6.innerHTML=delHref;
	var td4 = document.createElement('td');
	tr.appendChild(td4);
	td4.align="center";
	var delHref = "<div align=\"center\">"+prod_xlh+"</div>"
	td4.innerHTML=delHref;
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
	var td9 = document.createElement('td');
	tr.appendChild(td9);
	td9.align="center";
	if (pro_type==1)
	{pro_type1='易耗品'}
	else
	{pro_type1='非易耗品'}
	var delHref ="<div align=\"center\">"+pro_name+"("+pro_type1+")</div>"
	td9.innerHTML=delHref;
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
	try{
	$('#ddd').window('close');
	var tr=document.getElementById(id);
	tr.parentNode.removeChild(tr);
	document.getElementById('tr_'+id1).style.display='';
	}
	catch(e){}
	setSortList();
}
function setSortList()
{
	var sortlist=document.getElementsByName('sortlist');
	for (i=0;i<sortlist.length;i++)
	{
		sortlist[i].innerHTML=i+1;
	}
	a=a-1;
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
	if(document.getElementById('ret_title').value=="")
	{
		alert('返还标题不能为空')
		return false;
	}
	if(document.getElementById('ret_cateid').value=="")
	{
		alert('返还人员不能为空')
		return false;
	}
	if(document.getElementById('ret_bcateid').value=="")
	{
		alert('库管人员不能为空')
		return false;
	}
	var num=document.getElementsByName('prod_num');
	var num1=document.getElementsByName('ret_num');
	if(num.length==0)
	{
		alert('返还明细不能为空')
		return false;
	}
	for(i=0;i<num1.length;i++)
	{
	try{
		if (parseFloat(num[i].value)>parseFloat(num1[i].value)||parseFloat(num[i].value)==0||num[i].value=="")
		{
			alert('返还数量不能大于分发数量或返还数量不能为零为空')
			return false;
			break;
		}
		}
		catch(e)
		{
		}
	}
	var arrlist=document.getElementsByTagName("input");
	for(i=0;i<arrlist.length;i++)
	{
		if (arrlist[i].type=="text" || arrlist[i].type=="hidden")
		{
			if(arrlist[i].value=="" && (!arrlist[i].onpropertychange))
			{ 
				arrlist[i].value=" ";
			}
			if(arrlist[i].value.indexOf(", ")>=0 && (!arrlist[i].onpropertychange))
			{ 
				arrlist[i].value=arrlist[i].value.replace(/,\s/g," ");
			}
		}
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
function changeindex(val)
{
	var obj=document.getElementsByTagName("li")
	if(val!="")
	{
		for(i=0;i<obj.length;i++)
		{
			if(obj[i].innerText.indexOf(val)>=0)
			{			
				obj[i].style.display='';
			}
			else
			{
				obj[i].style.display='none';
			}
		}
	}
	else
	{
		for(i=0;i<obj.length;i++)
		{
			if(obj[i].innerText.indexOf(val)==0)
			{			
				obj[i].style.display='';
			}
		}
	}
}

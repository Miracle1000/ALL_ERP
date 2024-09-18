

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
//function ask1()
//{
//	if(document.getElementById('prod_type').value=="")
//	{
//		document.getElementById('test1').innerHTML="*必填"
//		return false;
//	}
//	document.getElementById('test1').innerHTML="*";
//	return true;
//}
var a=0
function setMx()
{
	$('#ddd').dialog('open');
}
function addMx(id,prod_name,prod_bh,prod_xh,sort1,prod_ph,prod_xlh,pro_name,pro_type)
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
	var delHref = "<div align=\"center\"><a href=\"###\" onclick=\"del_TR('"+tr.id+"','"+id+"')\"><img src=\"../images/del2.gif\"/></a>&nbsp;&nbsp;"+prod_name+"</div><input type=\"hidden\" value=\""+id+"\" name=\"prod_id\"></input>";
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
	delHref="<div align=\"center\">"+prod_ph+"</div>"
	td6.innerHTML=delHref;
	var td4 = document.createElement('td');
	tr.appendChild(td4);
	td4.align="center";
	var delHref = "<div align=\"center\">"+prod_xlh+"</div>"
	td4.innerHTML=delHref;
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
	var arrlist=document.getElementsByTagName("input");
	for(i=0;i<arrlist.length;i++)
	{
		if(arrlist[i].value.indexOf(", ")>=0 && (!arrlist[i].onpropertychange))
		{ 
			arrlist[i].value=arrlist[i].value.replace(/,\s/g,"^#$6a");
		}
	//arrlist[i].value=arrlist[i].value.replace(", ",'%^$a');
	}
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
		alert('确认人员不能为空')
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

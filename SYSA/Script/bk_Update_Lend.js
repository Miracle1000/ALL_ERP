function ask1()
{
	var Ld_bkid=document.getElementsByName('Ld_bkid');
	var Ld_num=document.getElementsByName('Ld_num');
	var nums=document.getElementsByName('nums');
	var trobjs=document.getElementById('add_tr').parentElement.rows;
	for(var i=1;i<trobjs.length-1;i++)
	{
		var trobj=trobjs[i];
		var idx=trobj.cells.length;
		var dtemp=trobj.cells[idx*1-2].getElementsByTagName("INPUT")[0];
		var d1=new Date(trobj.cells[idx*1-3].getElementsByTagName("INPUT")[0].value.replace(/\-/g,"/"));
		var d2=new Date(dtemp.value.replace(/\-/g,"/"));
		if(d1.getTime()-d2.getTime()>0 || dtemp.value=="")
		{
			alert('借阅时间不能大于归还时间或归还时间不能为空');
			dtemp.focus();
			dtemp.select();
			return false;
		}
	}
	for(var i=0;i<Ld_num.length;i++)
	{
		if(parseInt(Ld_num[i].value)>parseInt(nums[i].value) || Ld_num[i].value=="" || Ld_num[i].value==0)
		{
			alert('借阅数量不能多于图书剩余数量或借阅数量不能为空');
			Ld_num[i].focus();
			Ld_num[i].select();
			return false;
		}
	}
	if(Ld_bkid.length==0)
	{
		alert('请添加明细');
		return false;
	}
	for(var i=0;i<Ld_bkid.length;i++)
	{
		if(Ld_bkid[i].value=="")
		{
			alert('请选择图书');
			Ld_num[i].focus();
			Ld_num[i].select();
			return false;
		}
	}
	var arrlist=document.getElementsByTagName("input");
	for(i=0;i<arrlist.length;i++)
	{
		if (arrlist[i].type=="text" || arrlist[i].type=="hidden")
		{
			if(arrlist[i].value=="" && (!arrlist[i].onpropertychange))
			{
				arrlist[i].value="$^&1&*$";
			}
			if(arrlist[i].value.indexOf(", ")>=0 && (!arrlist[i].onpropertychange))
			{
				arrlist[i].value=arrlist[i].value.replace(/,\s/g,"^#$6a");
			}
		}
	}
	return true;
}

function del_TR(id)
{
	$('#ddd').dialog('close');
	try{
	var tr=document.getElementById(id);
	tr.parentNode.removeChild(tr);
	}
	catch(e){}
	setSortList();
	allsum();
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
function selectBook(x,sel,c,page)
{
	$('#ddd').dialog('close');
	$('#ddd').dialog('open');
	$('#ddd').dialog('move',{left:100,top:150});
	sidarr=document.getElementsByName('Ld_bkid');
	var pid="";
	if(sidarr.length>0)
	{
		for(i=0 ;i<sidarr.length;i++)
		{
			if(pid!="" && sidarr[i].value!="")
			{
				pid=pid+","+sidarr[i].value;
			}
			else if(pid=="" && sidarr[i].value!="")
			{
				pid=sidarr[i].value;
			}
		}
	}
	else
	{
		pid=0;
	}
	url="../search/search_book.asp?pk="+x+"&B="+sel+"&C="+c+"&sid="+pid+"&currPage="+page+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET",url,false)
	xmlHttp.onreadystatechange=function()
	{
		if (xmlHttp.readyState==4)
		{
			var ajaxhtml=xmlHttp.responseText;
			document.getElementById('resultbook').innerHTML=ajaxhtml;
		}
	}
	xmlHttp.send(null);
}
function setdate(num)
{
	a=document.getElementById('timenum'+num).value;
	time1=document.getElementsByName('Ld_time'+num)[0].value;
	var newtime;
	var arr=new Array();
	arr=time1.split('-');
	if (arr.length<1)
	{
		arr=time1.split('/');
	}
	var d = arr[2], m = arr[1], y = arr[0];
	var newMonth = new Date((m*1+a*1) + "/" + d + "/" + y)
	newtime=(newMonth.getFullYear()+"-"+(newMonth.getMonth() + 1)+"-"+newMonth.getDate());
	document.getElementsByName('Ld_rettime'+num)[0].value=newtime;
}
function allsum()
{
	Ld_num=document.getElementsByName('Ld_num');
	var temp=0;
	if(Ld_num.length>0)
	{
		for(i=0 ;i<Ld_num.length; i++)
		{
			if(Ld_num[i].value!="")
			{temp=temp+parseFloat(Ld_num[i].value);}
		}
	}
	document.getElementById('allnums').innerHTML=temp;
}
function setOpenr(id,bk_name,bk_bh,set_name,bk_returnnum,bk_auther,bk_pubtime,bk_publishing,bk_pubnum,bk_pagenum,bk_pagesize,bk_printtime,bk_format,bk_paper,bk_printnum,bk_isbn,bk_binding,bk_price,bk_num,bk_allmoney,bk_postion,name,bk_addtime,pk)
{
	addtr();
	document.getElementById('Ld_bkid'+pk).value=id;
	document.getElementById('bookname'+pk).value=bk_name;
	document.getElementById('bookname'+pk).style.color="black";
	try{document.getElementById('bk_bh'+pk).innerHTML=bk_bh;}catch(e){}
	try{document.getElementById('bk_type'+pk).innerHTML=set_name;}catch(e){}
	try{document.getElementById('bk_returnnum'+pk).innerHTML=bk_returnnum+'个月';}catch(e){}
	try{document.getElementById('bk_auther'+pk).innerHTML=bk_auther;}catch(e){}
	try{document.getElementById('bk_pubtime'+pk).innerHTML=bk_pubtime;}catch(e){}
	try{document.getElementById('bk_publishing'+pk).innerHTML=bk_publishing;}catch(e){}
	try{document.getElementById('bk_pubnum'+pk).innerHTML=bk_pubnum;}catch(e){}
	try{document.getElementById('bk_pagenum'+pk).innerHTML=bk_pagenum;}catch(e){}
	try{document.getElementById('bk_pagesize'+pk).innerHTML=bk_pagesize;}catch(e){}
	try{document.getElementById('bk_printtime'+pk).innerHTML=bk_printtime;}catch(e){}
	try{document.getElementById('bk_format'+pk).innerHTML=bk_format;}catch(e){}
	try{document.getElementById('bk_paper'+pk).innerHTML=bk_paper;}catch(e){}
	try{document.getElementById('bk_printnum'+pk).innerHTML=bk_printnum;}catch(e){}
	try{document.getElementById('bk_isbn'+pk).innerHTML=bk_isbn;}catch(e){}
	try{document.getElementById('bk_binding'+pk).innerHTML=bk_binding;}catch(e){}
	try{document.getElementById('bk_price'+pk).innerHTML=bk_price;}catch(e){}
	try{document.getElementById('bk_num'+pk).innerHTML=bk_num;}catch(e){}
	try{document.getElementById('bk_allmoney'+pk).innerHTML=bk_allmoney;}catch(e){}
	try{document.getElementById('bk_postion'+pk).innerHTML=bk_postion;}catch(e){}
	try{document.getElementById('bk_addcateid'+pk).innerHTML=name;}catch(e){}
	try{document.getElementById('bk_addtime'+pk).innerHTML=bk_addtime;}catch(e){}
	document.getElementById('nums'+pk).value=bk_num;
	document.getElementById('timenum'+pk).value=bk_returnnum;
	time1=document.getElementsByName('Ld_time'+pk)[0].value;
	var newtime;
	var arr=new Array();
	arr=time1.split('-');
	if (arr.length<1)
	{
		arr=time1.split('/');
	}
	var d = arr[2], m = arr[1], y = arr[0];
	var newMonth = new Date((m*1+bk_returnnum*1) + "/" + d + "/" + y)
	newtime=(newMonth.getFullYear()+"-"+(newMonth.getMonth() + 1)+"-"+newMonth.getDate());
	document.getElementsByName('Ld_rettime'+pk)[0].value=newtime;
	selectBook(b,'','',1)
	$('#ddd').dialog('open');
}

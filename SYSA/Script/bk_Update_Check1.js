function ask1(tp)
{
	var chk_title=document.getElementById('chk_title').value;
	var chk_cateid=document.getElementById('chk_cateid').value;
	var Chk_bkid=document.getElementsByName('Chk_bkid');
	var Chk_pdnum=document.getElementsByName('Chk_pdnum');
	if(chk_title=="")
	{
		document.getElementById('test1').innerHTML="* 必填";
		return false;
	}
	else
	{document.getElementById('test1').innerHTML="*";}
	if(chk_cateid=="")
	{
		document.getElementById('test2').innerHTML="* 必填";
		return false;
	}
	else
	{document.getElementById('test2').innerHTML="*";}
	if(Chk_bkid.length==0)
	{
		alert('请添加明细');
		return false;
	}
	for(var i=0;i<Chk_bkid.length;i++)
	{
		if(Chk_bkid[i].value=="")
		{
			alert('请选择图书');
			return false;
		}
	}
	for(var i=0;i<Chk_pdnum.length;i++)
	{
		if(Chk_pdnum[i].value=="")
		{
			alert('图书实际数量不能为空');
			Chk_pdnum[i].focus();
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
	
	document.getElementById('demo').action="Save_Check1.asp?tp="+tp+"&ord="+window.checkOrd;
	document.getElementById('demo').submit();
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
	sidarr=document.getElementsByName('Chk_bkid');
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
	url="../search/search_book2.asp?pk="+x+"&B="+sel+"&C="+c+"&sid="+pid+"&currPage="+page+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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
	Chk_sjnum=document.getElementsByName('Chk_sjnum');
	Chk_pdnum=document.getElementsByName('Chk_pdnum');
	Chk_yknum=document.getElementsByName('Chk_yknum');
	var temp=0;
	var temp1=0;
	var temp2=0;
	for(i=0 ;i<Chk_sjnum.length; i++)
	{
		pdnum=Chk_pdnum[i].value;
		if (pdnum=="")
		{
			pdnum=0;
		}
		Chk_yknum[i].value=Math.abs(parseFloat(Chk_sjnum[i].value)-parseFloat(pdnum));
		temp=temp+parseFloat(Chk_sjnum[i].value);
		temp1=temp1+parseFloat(pdnum);
		temp2=temp2+(Math.abs(parseFloat(Chk_sjnum[i].value)-parseFloat(pdnum)));
	}
	document.getElementById('allnums1').innerHTML=temp;
	document.getElementById('allnums2').innerHTML=temp1;
	document.getElementById('allnums3').innerHTML=temp2;
}
function setOpenr(id,bk_name,bk_bh,set_name,bk_returnnum,bk_auther,bk_pubtime,bk_publishing,bk_pubnum,bk_pagenum,bk_pagesize,bk_printtime,bk_format,bk_paper,bk_printnum,bk_isbn,bk_binding,bk_price,bk_num,bk_allmoney,bk_postion,name,bk_addtime,pk)
{
	addtr();
	document.getElementById('Chk_bkid'+pk).value=id;
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
	document.getElementById('Chk_sjnum'+pk).value=bk_num;
	document.getElementById('Chk_sjnum1'+pk).innerHTML=bk_num;
	allsum();
	selectBook(b,'','',1)
	$('#ddd').dialog('open');
}

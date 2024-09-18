

function showmanager(args)
{
	$('#ddd').dialog('move',{left:100,top:100});
	url="getManager.asp?met_id="+args+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET",url,false)
	xmlHttp.onreadystatechange=function()
	{
		if (xmlHttp.readyState==4)
		{
			document.getElementById('manager_div').innerHTML=xmlHttp.responseText;
		}
	}
	xmlHttp.send(null);	
	$('#ddd').dialog('open');
}

a=2
b=2
function addtr()
{
	var Table=document.getElementById('addtr');
	var tr=document.createElement("tr");
	tr.id="tr_"+a;
	tr.name="table_tr";
	Table.appendChild(tr);
	tr.onmouseover=function(){this.style.backgroundColor='efefef';}
	tr.onmouseout=function(){this.style.backgroundColor='';}
	var td1 = document.createElement('td');
	tr.appendChild(td1);
	var Href = "<div align=\"left\"></div>";
	td1.innerHTML=Href;
	var td2 = document.createElement('td');
	tr.appendChild(td2);
	var Href = "<div align=\"left\"><a href=\"javascript:void(0);\" onClick=\"addtr();\">添加</a>&nbsp;&nbsp;<a href=\"javascript:void(0);\" onClick=\"deltr('"+tr.id+"');\"><img src=\"../images/del2.gif\"></a>&nbsp;<span id='sortlist'>"+b+"</span></div>";
	td2.innerHTML=Href;
	var td3 = document.createElement('td');
	tr.appendChild(td3);
	var Href = "<div align=\"right\">开始时间：</div>";
	td3.innerHTML=Href;
	var td4 = document.createElement('td');
	tr.appendChild(td4);
	var Href = "<div align=\"left\"><input type=\"text\" name=\"startime\" id=\"startime_"+a+"\" Class=\"DateTimePick\" onclick=\"datedlg.showDateTime();\" readonly=\"readonly\"></div>";
	td4.innerHTML=Href;
	var td5 = document.createElement('td');
	tr.appendChild(td5);
	var Href = "<div align=\"right\">截止时间：</div>";
	td5.innerHTML=Href;
	var td6 = document.createElement('td');
	tr.appendChild(td6);
	var Href = "<div align=\"left\"><input type=\"text\" name=\"endtime\" id=\"endtime_"+a+"\" Class=\"DateTimePick\" onclick=\"datedlg.showDateTime();\" readonly=\"readonly\"></div>";
	td6.innerHTML=Href;
	b=b+1
	a=a+1
}
function chk_all()
{
	p1=document.getElementsByName('W1');
	p2=document.getElementsByName('W2');
	p3=document.getElementsByName('W3');
	if(document.getElementById("btn_x1").value=="取消")
	{
		document.getElementById("btn_x1").value="全选";
		pool=false;
	}
	else
	{
		document.getElementById("btn_x1").value="取消";
		pool=true;
	}
	p_bool=false;
	for(i=0;i<p1.length;i++)
	{
		p1[i].checked=pool;
	}
	for(j=0;j<p2.length;j++)
	{
		p2[j].checked=pool;
	}
	for(k=0;k<p3.length;k++)
	{
		p3[k].checked=pool;
	}
}

function ask()
{
	document.getElementById('divsubmit').style.display='block';
	document.getElementById('test1').innerHTML="*"
	document.getElementById('test2').innerHTML="*"
	document.getElementById('test3').innerHTML="*"
	document.getElementById('test4').innerHTML="*"
	document.getElementById('test5').innerHTML="*"
	if (document.getElementById('use_meeting').value==0)
	{
		document.getElementById('test1').innerHTML="*必填"
		document.getElementById('divsubmit').style.display='none';
		return false;
	}
	var use_title=document.getElementById('use_title').value;
	if (use_title=="")
	{
		document.getElementById('test2').innerHTML="*必填"
		document.getElementById('divsubmit').style.display='none';
		return false;
	}
	p1=document.getElementsByName('W1');
	p2=document.getElementsByName('W2');
	p3=document.getElementsByName('W3');
	p_bool=false;
	for(i=0;i<p1.length;i++)
	{
		if(p1[i].checked)
		{
			p_bool=true;
			break;
		}
	}
	for(j=0;j<p2.length;j++)
	{
		if(p2[j].checked)
		{
			p_bool=true;
			break;
		}
	}
	for(k=0;k<p3.length;k++)
	{
		if(p3[k].checked)
		{
			p_bool=true;
			break;
		}
	}
	if (p_bool==false)
	{
		document.getElementById('test3').innerHTML="*必填"
		document.getElementById('divsubmit').style.display='none';
		return false;
	}
	if (document.getElementById('use_time').value=="" || document.getElementById('use_time').value=='点击选择时间')
	{
		document.getElementById('test4').innerHTML="*必填"
		document.getElementById('divsubmit').style.display='none';
		return false;
	}
	if (document.getElementById('use_cateid').value=="")
	{
		document.getElementById('test5').innerHTML="*必填"
		document.getElementById('divsubmit').style.display='none';
		return false;
	}
	cycle=document.getElementsByName('use_meetingcycle');
	var cycle1=0;
	for (i=0;i<cycle.length;i++)
	{
		if(cycle[i].checked)
		{cycle1=i+1}
	}
	if (cycle1==1)
	{
		var stime=document.getElementById('use_startime').value;
		var etime=document.getElementById('use_endtime').value;
		if(stime=='点击选择时间' || etime=='点击选择时间')
		{
			alert('会议时间选择不能为空');
			document.getElementById('divsubmit').style.display='none';
			return false;
		}
		var d1=new Date(stime.replace(/\-/g,"/"));
		var d2=new Date(etime.replace(/\-/g,"/"));
		if (d1.getTime()-d2.getTime()>=0)
		{
			alert('开始时间不能大于结束时间');
			document.getElementById('divsubmit').style.display='none';
			return false;
		}
	}
	else
	{
		var sdate=document.getElementById('use_stardate').value;
		var edate=document.getElementById('use_enddate').value;
		if(sdate=='点击选择时间' || edate=='点击选择时间')
		{
			alert('会议日期选择不能为空');
			document.getElementById('divsubmit').style.display='none';
			return false;
		}
		var d1=new Date(sdate.replace(/\-/g,"/"));
		var d2=new Date(edate.replace(/\-/g,"/"));
		if (d1.getTime()-d2.getTime()>0)
		{
			alert('开始日期不能大于结束日期');
			document.getElementById('divsubmit').style.display='none';
			return false;
		}
		var stime=document.getElementsByName('startime');
		var etime=document.getElementsByName('endtime');
		for(i=0;i<stime.length;i++)
		{
			if(stime[i].value=='点击选择时间' || etime[i].value=='点击选择时间')
			{
				alert('会议时间选择不能为空');
				document.getElementById('divsubmit').style.display='none';
				return false;
			}
			var d3=new Date(stime[i].value.replace(/\-/g,"/"));
			var d4=new Date(etime[i].value.replace(/\-/g,"/"));
			if (d3.getTime()-d4.getTime()>=0)
			{
				alert('开始时间不能大于结束时间');
				document.getElementById('divsubmit').style.display='none';
				return false;
			}
		}
		s=1
		for(i=0;i<stime.length-1;i++)
		{
			var d5=new Date(stime[s].value.replace(/\-/g,"/"));
			var d6=new Date(etime[i].value.replace(/\-/g,"/"));
			if (d6.getTime()-d5.getTime()>0)
			{
				alert('周期会议时间不能有交叉');
				document.getElementById('divsubmit').style.display='none';
				return false;
			}
			s=s+1;
		}
	}
	var t1=document.getElementsByName('startime');
	var t2=document.getElementsByName('endtime');
	var time1="";
	var time2="";
	for(i=0;i<t1.length;i++)
	{
	 	if(time1=="")
		{
			time1=t1[i].value;
			time2=t2[i].value;
		}
		else
		{
			time1=time1+","+t1[i].value;
			time2=time2+","+t2[i].value;
		}
		
	}
	var utime1=document.getElementById('use_startime').value;
	var utime2=document.getElementById('use_endtime').value;
	var udate1=document.getElementById('use_stardate').value;
	var udate2=document.getElementById('use_enddate').value;
	var met_id=document.getElementById('use_meeting').value;
	qx=Validate(met_id,cycle1,time1,time2,utime1,utime2,udate1,udate2);
	if (parseInt(qx)==1)
	{
		alert('时间被占用,请重新填写');
		document.getElementById('divsubmit').style.display='none';
		return false;
	}
	document.getElementById('divsubmit').style.display='none';
	return true;
}

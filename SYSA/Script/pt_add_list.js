
function ask()
{
	date.submit();
}
function callServer(nameitr)
{
	var u_name = document.getElementById("u_name"+nameitr).value;
	var w  = document.all[nameitr];
	if ((u_name == null) || (u_name == "")) return;
	var url = "cu.asp?name=" + escape(u_name);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){updatePage(w);};
	xmlHttp.send(null);
}

function updatePage(namei)
{
	var test7=namei
	if (xmlHttp.readyState == 4)
	{
		var response = xmlHttp.responseText;
		test7.innerHTML=response;
	}
}

function callServer2()
{
	var unit1 = document.getElementById("unit1").value;
	if ((unit1 == null) || (unit1 == "")) return;
	var url = "cuunit.asp?unit1=" + escape(unit1)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){updatePage2(unit1);};
	xmlHttp.send(null);
}

function updatePage2(unit1)
{
	if (xmlHttp.readyState == 4)
	{		
		var response = xmlHttp.responseText;
		trpx0.innerHTML=response;
		var url1 = "cuunit3.asp?unit1=" + escape(unit1)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
		xmlHttp.open("GET", url1, true);
		xmlHttp.onreadystatechange = function(){updatePage3();};
		xmlHttp.send(null);
	}
}

function updatePage3()
{
  if (xmlHttp.readyState < 4)
  {
		trpx_unit2.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4)
  {
		var response = xmlHttp.responseText;
		trpx_unit2.innerHTML=response;
		reSetSize((isadd?0:20),false);
		if(isadd == false){isadd = true;}
		xmlHttp.abort();
	}
}

function callServer4(ord)
{
	if ((ord == null) || (ord == "")) return;
	var url = "num_click.asp?ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){updatePage4(ord);};
	xmlHttp.send(null);
}

function updatePage4(ord)
{
	if (xmlHttp.readyState == 4)
	{
		var res = xmlHttp.responseText;
		var w  = "trpx"+res;
		w=document.all[w]
		var url = "cuunit2.asp?ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
		xmlHttp.open("GET", url, false);
		xmlHttp.onreadystatechange = function(){updatePage5(w,ord);};
		xmlHttp.send(null);
	}
}

function updatePage5(w,unitall)
{
	var test3=w;
	if (xmlHttp.readyState == 4)
	{
		var response = xmlHttp.responseText;
		test3.innerHTML=response;
		var url1 = "cuunit4.asp?unitall=" + escape(unitall)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
		xmlHttp.open("GET", url1, true);
		xmlHttp.onreadystatechange = function(){updatePage6();};
		xmlHttp.send(null);
	}
}

function updatePage6()
{
	if (xmlHttp.readyState == 4)
	{
		var response = xmlHttp.responseText;		
		trpx_unit2.innerHTML=response;
		var url1 = "cuunit5.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
		xmlHttp.open("GET", url1, true);
		xmlHttp.onreadystatechange = function(){updatePage7();};
		xmlHttp.send(null);
	}
}

function updatePage7()
{
  if (xmlHttp.readyState == 4)
  {
		var response = xmlHttp.responseText;
		trpx_unit1.innerHTML=response;
		reSetSize(20,false);
		xmlHttp.abort();
	}
}

function del(str,id)
{
	if(str=="trpx0"){isadd=false;}
	var w  = document.all[str];
	var url = "del_cp.asp?id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){updatePage_del(w);};
	xmlHttp.send(null);
}

function updatePage_del(str)
{
	if (xmlHttp.readyState == 4)
	{
		var response = xmlHttp.responseText;
		var setHeight=str.offsetHeight;
		str.innerHTML="";
		var url1 = "cuunit5.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
		xmlHttp.open("GET", url1, true);
		xmlHttp.onreadystatechange = function(){updatePage8(setHeight);};
		xmlHttp.send(null);
	}
}

function updatePage_del2(str)
{
	if (xmlHttp.readyState == 4)
	{
		var response = xmlHttp.responseText;
		document.getElementById(str).style.display="none";
		var url1 = "cuunit5.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
		xmlHttp.open("GET", url1, true);
		xmlHttp.onreadystatechange = function(){updatePage7();};
		xmlHttp.send(null);
	}
}

function updatePage8(setHeight)
{
	if (xmlHttp.readyState == 4)
	{
		var response = xmlHttp.responseText;
		trpx_unit1.innerHTML=response;
		var url1 = "cuunit4.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
		xmlHttp.open("GET", url1, true);
		xmlHttp.onreadystatechange = function(){updatePage9(setHeight);};
		xmlHttp.send(null);
	}
}

function updatePage9(setHeight)
{
	if (xmlHttp.readyState == 4)
	{
		var response = xmlHttp.responseText;
		trpx_unit2.innerHTML=response;
		cldiv.style.height=cldiv.offsetHeight-setHeight+"px";
		xmlHttp.abort();
	}
}

function check_ckxz()
{
	var ck = document.getElementById("unit1").value;
	var title = document.getElementById("keyword").value;
	if (ck != "") return true;
}

function keydown()
{
	if(event.keyCode==13)
	{
		event.keyCode=9
	}
	else
	{
		keydowndeal(event)
	}
}

function keydown1()
{
	if(event.keyCode==13)
	{
		event.keyCode=9
		hide_suggest()
	}
}

function onKeyPress()
{
	if (event.keyCode!=46 && event.keyCode!=45 && (event.keyCode<48 || event.keyCode>57)) event.returnValue=false;
}

function callServer_ts(m,name1)
{
	var u_name = document.getElementById(name1).value;
	var w2  = "test"+m;
	w2=document.all[w2]
	if ((u_name == null) || (u_name == "")) return;
	var url = "cu_ts.asp?name=" + escape(u_name)+"&ord="+escape(m)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){updatePage_ts(w2,m);};
	xmlHttp.send(null);
}

function updatePage_ts(w,m)
{
	var test6=w
	if (xmlHttp.readyState == 4)
	{
		var response = xmlHttp.responseText;
		test6.innerHTML=response;
	}
}

function formCheck()
{
	if(document.getElementById("flag1").value=="1"||document.getElementById("flag2").value=="1"||document.getElementById("flag3").value=="1")
	{
		return false;
	}
	else
	{
		return true;
	}
}

function CheckSelection()
{
	var rvalue=false;
	try
	{
		if(document.getElementById("rbtn2").checked)
		{
			var ulist=document.getElementsByName("W1");
			var notchecked=true;
			for(var i=0;i<ulist.length;i++)
			{
				if(ulist[i].checked){notchecked=false;break;}
			}
			ulist=document.getElementsByName("W2");
			for(var i=0;i<ulist.length;i++)
			{
				if(ulist[i].checked){notchecked=false;break;}
			}
			ulist=document.getElementsByName("W3");
			for(var i=0;i<ulist.length;i++)
			{
				if(ulist[i].checked){notchecked=false;break;}
			}

			if(notchecked)
			{
				document.getElementById("ulist1").innerText="请选择可操作范围";
				rvalue = false;
			}
			else
			{
				document.getElementById("ulist1").innerText="";
				rvalue = true;
			}
		}
		else
		{
			rvalue = true;

		}
	}
	catch(e3)
	{
	}
	finally
	{
		return rvalue;
	}
}

window.__ChangeMenuArea = function(){		//--获取session中的分类的可调用范围
	var resTxt, arr_res
	var url = "../product/UserList_Ajax.asp";
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		if (xmlHttp.readyState == 4) {
			var r = xmlHttp.responseText;
			if(r != ""){
				document.getElementById("rbtn1").checked = false;
				document.getElementById("rbtn2").checked = true;
				document.getElementById('tb1').style.display='block';
				document.getElementById("tb1").children[0].innerHTML = r;
			}
			else
			{
				document.getElementById("rbtn1").checked = true;
				document.getElementById("rbtn2").checked = false;
				document.getElementById('tb1').style.display='none';
			}
		}
	};
	xmlHttp.send(null);
}
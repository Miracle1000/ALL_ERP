
function changeMobile(recid,mobilenum,flg,name)
{
	//处理隐藏号码
	if(name.length > 0){
		var tmpstr2 = window.frames['cFF2'].document.getElementById('hiddenNumShow').value;
		var tmpstr3 = window.frames['cFF2'].document.getElementById('hiddenNum').value;
		if((","+tmpstr2+",").indexOf(","+name+",")<0)
		{
			if(tmpstr2=="")
			{
				tmpstr2=name;
				tmpstr3=mobilenum;
			}
			else
			{
				tmpstr2+=","+name;
				tmpstr3+=","+mobilenum;
			}
			if(document.getElementById("IMG"+recid+"_"+mobilenum))document.getElementById("IMG"+recid+"_"+mobilenum).src="../images/d14.gif";
		}
		else
		{
			if(flg)
			{
				tmpstr2=(","+tmpstr2+",").replace(","+name+",",",");
				tmpstr3=(","+tmpstr3+",").replace(","+mobilenum+",",",");
				if(tmpstr2!="")
				{
					if(tmpstr2==","){
						tmpstr2="";
						tmpstr3="";
					}
					else{
						tmpstr2=tmpstr2.substring(1,tmpstr2.length-1);
						tmpstr3=tmpstr3.substring(1,tmpstr3.length-1);
					}
				}
				if(document.getElementById("IMG"+recid+"_"+mobilenum))document.getElementById("IMG"+recid+"_"+mobilenum).src="../images/155.gif";
			}
		}
		window.frames['cFF2'].document.getElementById('hiddenNumShow').value=tmpstr2;
		window.frames['cFF2'].document.getElementById('hiddenNum').value=tmpstr3;
		return false;
	}
	
	
	
	var tmpstr=window.frames['cFF2'].document.getElementById('takeName').value;
	if((","+tmpstr+",").indexOf(","+mobilenum+",")<0)
	{
		if(tmpstr=="")
		{
			tmpstr=mobilenum;
		}
		else
		{
			tmpstr+=","+mobilenum;
		}
		if(document.getElementById("IMG"+recid+"_"+mobilenum))document.getElementById("IMG"+recid+"_"+mobilenum).src="../images/d14.gif";
	}
	else
	{
		if(flg)
		{
			tmpstr=(","+tmpstr+",").replace(","+mobilenum+",",",");
			if(tmpstr!="")
			{
				if(tmpstr==",")
					tmpstr="";
				else
					tmpstr=tmpstr.substring(1,tmpstr.length-1);
			}
			if(document.getElementById("IMG"+recid+"_"+mobilenum))document.getElementById("IMG"+recid+"_"+mobilenum).src="../images/155.gif";
		}
	}
	window.frames['cFF2'].document.getElementById('takeName').value=tmpstr;
	//写入手机号码的同时获取焦点  llz
	window.frames['cFF2'].document.getElementById('takeName').focus();
}

function getAll(cid)
{
	var xmlhttp;
	if(window.ActiveXObject)
	{
		xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
	}
	else if(window.XMLHttpRequest)
	{
		xmlhttp=new XMLHttpRequest();
	}
	if(xmlhttp)
	{
		xmlhttp.onreadystatechange=function(){
			if(xmlhttp.readyState==4)
			{
				var yy=unescape(xmlhttp.responseText).split("</noscript>")[1].replace(" ","").replace("\r\n","");
				tmpstr=window.frames['cFF2'].document.getElementById('takeName').value.replace(" ","");
				if (tmpstr!="")
				{
					window.frames['cFF2'].document.getElementById('takeName').value=checkDoberPhone(tmpstr+","+yy);
				}
				else
				{
					window.frames['cFF2'].document.getElementById('takeName').value=yy;
				}
				window.frames['cFF2'].document.getElementById('takeName').focus();
				//var zz=yy.split(",");
				//for(var m=0;m<zz.length;m++)
				//{
				//	var kk=zz[m].split(";");
				//	if(kk[0]&&kk[1])
				//	{
				//		//changeMobile(kk[0],kk[1],false);
				//	}
				//}
			}
		}
		xmlhttp.open("get","getPerson.asp?cid="+cid+"&r="+Math.round(Math.random()*100),false);
		xmlhttp.send(null);
	}
}

function ajaxSubmit_page(pid,pagenum,ftype){
	var xmlhttp=window.ActiveXObject? new ActiveXObject("Microsoft.XMLHTTP"):new XMLHttpRequest();
	if(xmlhttp)
	{
		xmlhttp.onreadystatechange=function(){
			if(xmlhttp.readyState==4)
			{
				var yy=unescape(xmlhttp.responseText).split("</noscript>")[1];
				if(ftype==3||!document.getElementById("a"+pid)){
					document.getElementById("cp_search").innerHTML=yy;
				}else{
					document.getElementById("a"+pid).cells[0].innerHTML=yy;
				}
				try{
					//top.document.getElementById("cFF").style.height=top.document.getElementById("cFF").document.body.scrollHeight+0+"px";
					var imgobj=document.getElementsByTagName("img");
					var obj = window.ActiveXObject?window.frames['cFF2']:document.getElementById('cFF2').contentWindow;
					var allmobile=obj.document.getElementById('takeName').value;
					for(var j=0;j<imgobj.length;j++)
					{
						var tmpid=imgobj[j].id;
						if(tmpid&&tmpid.substring(0,3)=="IMG"){
							var tmpmobile=tmpid.substring(tmpid.indexOf("_")+1);
							if((","+allmobile+",").indexOf(","+tmpmobile+",")>=0){
								imgobj[j].src="../images/d14.gif";
							}
						}
					}
				}
				catch(e1){}
			}
		}
		xmlhttp.open("get","search_person.asp?B="+document.getElementById("B").value+"&C="+document.getElementById("C8").value+"&P="+pagenum+"&sort="+pid+"&ftype="+ftype+"&r="+Math.round(Math.random()*100),false);
		xmlhttp.send(null);
	}
}

function goPage(pageid,ftype){
	var pagenum=document.getElementById('txtGoToPage_'+pageid).value;
	if(pagenum&&!isNaN(pagenum)){
		ajaxSubmit_page(pageid,parseInt(pagenum),ftype);
	}else{
		alert('请输入数字');
	}
}

//高级搜索
function Left_adSearch(obj){
	var sdivobj=document.getElementById("adsDiv");
	if(sdivobj.style.display!="none"){
		Left_adClose();
	}else{
		var x=obj.offsetLeft,y=obj.offsetTop;
		var obj2=obj;
		var offsetx=0;
		while(obj2=obj2.offsetParent)
		{
			x+=obj2.offsetLeft;
			y+=obj2.offsetTop;
		}
		sdivobj.style.left=x+33+"px";
		sdivobj.style.top=y+"px";
		sdivobj.style.display="inline";
	}
	document.getElementById('adsIF').style.height=document.getElementById('adsIF').contentWindow.document.getElementsByTagName('table')[1].offsetHeight+30+'px';
}

function Left_adClose(){
	document.getElementById('adsDiv').style.display="none";
}


function advance(result){
	document.getElementById("cp_search").innerHTML = result;
}


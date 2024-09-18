
function shDiv(divid,pdivid)
{
	document.getElementById(pdivid).className=document.getElementById(pdivid).className=="menu3"?"menu4":"menu3"
	document.getElementById(divid).style.display=document.getElementById(divid).style.display=='none'?'block':'none';
}

var oldValue=window.oldValue;
var expaned=true;
//全部展开和收缩
function ExpandAll(obj)
{
	obj.innerHTML=expaned?"全部展开":"全部收缩";
	var divobjs=document.getElementById("leftmenuall").getElementsByTagName("div");
	for(var i=0;i<divobjs.length;i++)
	{
		if(divobjs[i].onclick&&divobjs[i].onclick.toString().indexOf('shDiv')>0&&((expaned&&divobjs[i+1].style.display!='none')||(!expaned&&divobjs[i+1].style.display=='none')))
		{
			divobjs[i].fireEvent('onclick');
		}
	}
	expaned=!expaned;
}

//通过仓库名或分类名检索仓库
function searchSort(kvalue,kt)
{
	var url="../product/search_store.asp?kc=1&kv="+escape(kvalue)+"&exid="+window.slaveSid+"&kt="+kt+"&s="+new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function()
  {
		if (xmlHttp.readyState == 4)
		{
			document.getElementById("allStore").innerHTML=xmlHttp.responseText;
		}
  };
  xmlHttp.send(null);  
}

//选择仓库
function selectCK(obj,ckid,ckname)
{
	var tb=document.getElementById("SlaveStoreDiv").getElementsByTagName("table")[0];
	if(checkCK(ckid))
	{
		tbaddRow(tb,ckid,ckname);
	}
}

//检查仓库是否已被选择
function checkCK(ckid)
{
	var tr=document.getElementById("SlaveStoreDiv").getElementsByTagName("table")[0].rows;
	for(var i=1;i<tr.length;i++)
	{
		if(tr[i].tg!="1")
		{
			if(parseInt(tr[i].cells[2].ckid)==ckid) return false;
		}
	}
	return true;
}

//添加行
function tbaddRow(obj,ckid,ckname)
{
	if(obj.rows.length>1&&obj.rows[1].tg){obj.deleteRow(1);}
	var nrow=obj.insertRow(-1);
	nrow.style.height="22px";
	var ncell=nrow.insertCell(-1);
	ncell.innerHTML="<img src='../images/del2.gif' style='cursor:hand' onclick='tbdelRow(this);'>"
	ncell=nrow.insertCell(-1);
	ncell.innerHTML=ckname;
	ncell=nrow.insertCell(-1);
	ncell.ckid=ckid;
	ncell.innerHTML="<input type='text' style='width:50px;' onfocus='this.select();' value='0'>";
	document.getElementById("SlaveStoreDiv").doScroll("scrollbarPageDown");
}

//删除行
function tbdelRow(obj)
{
	var tb=document.getElementById("SlaveStoreDiv").getElementsByTagName("table")[0];
	tb.deleteRow(obj.parentElement.parentElement.rowIndex);
	if(tb.rows.length==1)
	{
		var nrow=tb.insertRow(-1);
		nrow.height="22px";
		nrow.tg="1";
		var ncell=nrow.insertCell(-1);
		ncell.colSpan=3;
		ncell.innerHTML="没有选择辅助仓库";
	}
}

//清空选择项
function deleteAll()
{
	var tb=document.getElementById("SlaveStoreDiv").getElementsByTagName("table")[0];
	var tr=document.getElementById("SlaveStoreDiv").getElementsByTagName("table")[0].rows;
	if(tr.length<2||(tr.length>=2&&tr[1].tg)){return;}
	for(var i=tr.length;i>1;i--)
	{
		tb.deleteRow(1);
		if(tb.rows.length==1)
		{
			var nrow=tb.insertRow(-1);
			nrow.height="22px";
			nrow.tg="1";
			var ncell=nrow.insertCell(-1);
			ncell.colSpan=3;
			ncell.innerHTML="没有选择辅助仓库";
		}
	}	
}

//从仓库分类批量选择仓库,如果objid为空则选择所有分类
function selectSort(objid)
{
	var divobj;
	if(objid!="")
	{
		divobj=document.getElementById(objid).getElementsByTagName("div");
	}
	else
	{
		divobj=document.getElementById("allStore").getElementsByTagName("div");
	}
	for(var i=0;i<divobj.length;i++)
	{
		if(divobj[i].className=="file1") divobj[i].fireEvent("onclick");
	}
	event.cancelBubble=true;
	return false;
}

//保存现在的值
function tbsaveck()
{
	var rtn="";
	var tr=document.getElementById("SlaveStoreDiv").getElementsByTagName("table")[0].rows;
	for(var i=1;i<tr.length;i++)
	{
		if(tr[i].tg!="1")
		{
			var numobj=tr[i].cells[2].getElementsByTagName("input")[0];
			if(numobj.value==""||isNaN(numobj.value))
			{
				alert('输入的数量不合法，请核对');
				numobj.focus();
				numobj.select();
				return false;
			}
			else
			{
				rtn+=(rtn==""?"":";")+numobj.parentElement.ckid+","+numobj.value;
			}
		}
	}
	parent.document.getElementsByName("SlaveStore_"+window.slaveRobj)[0].value=rtn;
	parent.sdClose();
}

//获取现在的值
function tbgetRtn()
{
	var rtn="";
	var tr=document.getElementById("SlaveStoreDiv").getElementsByTagName("table")[0].rows;
	for(var i=1;i<tr.length;i++)
	{
		if(tr[i].tg!="1")
		{
			var numobj=tr[i].cells[2].getElementsByTagName("input")[0];
			rtn+=(rtn==""?"":";")+numobj.parentElement.ckid+","+numobj.value;
		}
	}
	return rtn;
}

//比较新旧值来判断是否有更改
function checkRtn()
{
	var nowValue=tbgetRtn();
	var nowArray=nowValue.split(";");
	var oldArray=oldValue.split(";");
	if(nowArray.length!=oldArray.length) return false;
	for(var i=0;i<nowArray.length;i++)
	{
		var nid=nowArray[i].split(",")[0];
		var nvalue=nowArray[i].split(",")[1];
		var hasid=false;
		for(var j=0;j<oldArray.length;j++)
		{
			var oid=oldArray[j].split(",")[0];
			var ovalue=oldArray[j].split(",")[1];
			if(oid==nid)
			{
				hasid=true;
				if(ovalue!=nvalue) return false;
			}
		}
		if(!hasid) return false;
	}

	for(var i=0;i<oldArray.length;i++)
	{
		var oid=oldArray[i].split(",")[0];
		var hasid=false;
		for(var j=0;j<nowArray.length;j++)
		{
			var nid=nowArray[j].split(",")[0];
			if(oid==nid)
			{
				hasid=true;
			}
		}
		if(!hasid) return false;
	}
	return true;
}

function tbcancelck()
{
	if(checkRtn()||(!checkRtn()&&confirm('已经做出了修改，不保存结果吗？'))){parent.sdClose();}
}

function changeAll(obj)
{
	var tr=document.getElementById("SlaveStoreDiv").getElementsByTagName("table")[0].rows;
	for(i=1;i<tr.length;i++)
	{
		if(tr[i].tg) break;
		tr[i].cells[2].getElementsByTagName("input")[0].value=obj.value;
	}
}

function checkScroll(obj)
{
	obj.doScroll(event.wheelDelta<0?"down":"up");
	event.cancelBubble=true;
	return false;
}

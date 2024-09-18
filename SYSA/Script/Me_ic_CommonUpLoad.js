
function addAtt(strName,strSize,strDesc,strDelLink)
{
	var tbobj=document.getElementById("atttb");
	if(tbobj.rows.length==0)
	{
		var th=tbobj.insertRow(-1);
		th.className="top";
		var th1=th.insertCell(-1);
		var th2=th.insertCell(-1);
		var th3=th.insertCell(-1);
		var th4=th.insertCell(-1);
		th1.innerHTML="<center><span style='color:#5B7CAE;font-weight:bolder'>文件名</span></center>";
		th2.innerHTML="<center><span style='color:#5B7CAE;font-weight:bolder'>文件大小</span></center>";
		th3.innerHTML="<center><span style='color:#5B7CAE;font-weight:bolder'>文件描述</span></center>";
		th4.innerHTML="<center><span style='color:#5B7CAE;font-weight:bolder'>删除</span></center>";
	}
	var newtr=tbobj.insertRow(-1);
	//newtr.className="top";
	var newcell1=newtr.insertCell(-1);
	var newcell2=newtr.insertCell(-1);
	var newcell3=newtr.insertCell(-1);
	var newcell4=newtr.insertCell(-1);
	newtr.style.height="22px"
	newcell1.style.paddingLeft="20px";
	newcell1.style.paddingRight="20px";
	newcell1.innerHTML="<center><span style='color:#5B7CAE;font-weight:lighter'>"+strName+"</span></center>";
	newcell2.style.paddingLeft="20px";
	newcell2.style.paddingRight="20px";
	newcell2.innerHTML="<center><span style='color:#5B7CAE;font-weight:lighter'>"+strSize+"</span></center>";
	newcell3.style.paddingLeft="20px";
	newcell3.style.paddingRight="20px";
	newcell3.innerHTML="<center><span style='color:#5B7CAE;font-weight:lighter'>"+strDesc+"</span></center>";
	newcell4.style.paddingLeft="20px";
	newcell4.style.paddingRight="20px";
	newcell4.innerHTML="<center><span style='color:#5B7CAE;font-weight:lighter'>"+strDelLink+"</span></center>";
	var tmpFrame;
	if(tmpFrame=parent.document.getElementById("cFF")){tmpFrame.style.height=document.body.scrollHeight+0+"px";}
}

function delRow(obj,ord)
{
	if(confirm("确定要删除此文件吗（删除后不可恢复）？"))
	{
		var trobj=obj.parentElement.parentElement.parentElement.parentElement;
		var hidobj=trobj.getElementsByTagName("input")
		var fname=hidobj[0].value;
		var foname=hidobj[1].value;
		var ajaxurl="../../reply/ProcDelFile.asp?t=0&ord="+ord+"&f="+escape(foname+"/"+fname)+"&t="+Math.random();
		xmlHttp.open("GET", ajaxurl, false);
		xmlHttp.onreadystatechange = function(){
		if (xmlHttp.readyState < 4) {
		}
		if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText.split("</noscript>")[1];
		xmlHttp.abort();
		}
		};
		xmlHttp.send(null);
		trobj.parentElement.removeChild(trobj);
		var tbobj=document.getElementById("atttb");
		if(tbobj.rows.length==1) tbobj.deleteRow(0);
	}
}

function showUploadForm(obj)
{
	var x=obj.offsetLeft,y=obj.offsetTop;
	var obj2=obj;
	var offsetx=25;
	while(obj2=obj2.offsetParent)
	{
		x+=obj2.offsetLeft;  
		y+=obj2.offsetTop;
	}
	var showobj=document.getElementById("fupload");
	showobj.style.display="block";
	showobj.style.left=offsetx+x+"px";
	showobj.style.top=y-5+"px";
}


//启动进度条
function startProgress(xmlPath)
{
  displayProgress();
  setProgressDivPos();
  setTimeout("DisplayProgressBar('" + xmlPath + "')",500);
}

function DisplayProgressBar(xmlPath)
{
	var xmlDoc = new ActiveXObject("Msxml2.DOMDocument.3.0");
	xmlDoc.async = false;
	xmlDoc.load(xmlPath);
	if (xmlDoc.parseError.errorCode!=0)
	{
		//var error = xmlDoc.parseError;
		//alert(error.reason)
		setTimeout("DisplayProgressBar('" + xmlPath + "')",1000);
		return;
	}
	
	try
	{
		var root = xmlDoc.documentElement;   //根节点
		var totalbytes = root.childNodes(0).text;
		var uploadbytes = root.childNodes(1).text;
		var percent = root.childNodes(2).text;
		ProgressPercent.innerHTML = percent + "%";
		ProgressBar.style.width = percent + "%";
		uploadSize.innerHTML = uploadbytes;
		uploadSpeed.innerHTML = root.childNodes(3).text;
		totalTime.innerHTML = root.childNodes(4).text;
		leftTime.innerHTML = root.childNodes(5).text;
		if (percent<100)
		{
			setTimeout("DisplayProgressBar('" + xmlPath + "')",1000);
		}
	}
	catch(e)
	{
	}
}

function displayProgress()
{
  var objProgress = document.getElementById("Progress");
  objProgress.style.display = "";
}

function closeProgress()
{
  var objProgress = document.getElementById("Progress");
  objProgress.style.display = "none";
}

function setProgressDivPos()
{
	var objProgress = document.getElementById("Progress");
	objProgress.style.top = document.body.scrollTop+(document.body.clientHeight-document.getElementById("Progress").offsetHeight)/2
	objProgress.style.left = document.body.scrollLeft+(document.body.clientWidth-document.getElementById("Progress").offsetWidth)/2;
}




function showADS()
{
	var dv=document.getElementById("adsDiv");
	var dvdlg=parent.document.getElementById("productselect");
	if(dv.disp==1)
	{
		dv.style.display="none";
		dv.disp=0;
		dvdlg.style.width="210px";
		event.srcElement.value="高级"
	}
	else
	{
		dv.style.display="block";
		dv.disp=1;
		event.srcElement.value="收回"
		dvdlg.style.width="600px";
	}
}

function adDoSearch()
{
	ajaxSubmit_page(0,1);
}

function adDoReset()
{
	var sobj=document.getElementsByTagName("input");
	for(var i=0;i<sobj.length;i++){if(sobj[i].type=="text"){sobj[i].value="";}else if(sobj[i].type=="checkbox"&&sobj[i].checked&&sobj[i].name){sobj[i].checked=false;sobj[i].fireEvent("onclick");}}
	sobj=document.getElementsByTagName("select");
	for(var i=0;i<sobj.length;i++){sobj[i].value='';}
}

function ContinueMovePannel(event,flg)
{
	event=event||window.event;
	var mp=parent.document.getElementById("productselect");
	if(flg==0){mp.ismoving=0;return false;}
	if(!mp.ismoving||!mp.oldx||!mp.oldx||!mp.oldleft||!mp.oldtop||mp.ismoving!=1) return false;
	var newleft=parseInt(mp.oldleft)+(event.clientX+parseInt(mp.style.left))-parseInt(mp.oldx);
	var newtop=parseInt(mp.oldtop)+(event.clientY+parseInt(mp.style.top))-parseInt(mp.oldy);
	//top.document.title=newleft+","+newtop;
	if(newleft<0||newtop<0) return false;
	mp.style.left=newleft;
	mp.style.top=newtop;
	var pfm=parent.parent.document.getElementById("cFF");
	if(parseInt(mp.style.top)+parseInt(mp.offsetHeight)>parseInt(pfm.style.height)) pfm.style.height=parseInt(mp.style.top)+parseInt(mp.offsetHeight);
}

function ajaxSubmit(sort1)
{
	var B=document.forms[0].B.value;
	var C=document.forms[0].C.value;
	var top=document.forms[0].top.value;
	var url = "../contract/search_cp.asp?lv=1&B="+escape(B)+"&C="+escape(C) +"&top="+escape(top) +"&sort1="+escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function()
	{
		if (xmlHttp.readyState == 4)
		{
			var response = xmlHttp.responseText;
			cp_search.innerHTML=response;
			xmlHttp.abort();
		}
	};
	xmlHttp.send(null);  
}

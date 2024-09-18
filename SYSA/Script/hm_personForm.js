
function frameResize(){
document.getElementById("cFF2").style.height=I2.document.body.scrollHeight+0+"px";
}

function $(name){
	return document.getElementById(name);
}
function showmenu(self,showname){
	var tableObj=self.parentNode.parentNode;
	for(var i=0;i<tableObj.rows.length;i++){
		var tdObj=tableObj.rows(i).cells(0);
		if(tdObj==self){
			var old=tdObj.className;
			tdObj.className=(old=="menutab"?"menutab_hover":"menutab");
		}else if(tdObj==$(showname)){
			var old=tdObj.className;
			tdObj.className=(old=="menulist"?"menulist_hover":"menulist");
		}else{
			if(tdObj.id){
				tdObj.className="menulist";
			}else{
				tdObj.className="menutab";
			}
		}
	}
}
function switchMenu(self){
	var subobj=self.getElementsByTagName("ul")[0];
	if(self.className=="hover"){
		self.className="";
		subobj.style.display="none";
	}else{
		self.className="hover";
		subobj.style.display="block";
	}
}
function showHidaLeftMenu(self){
	var leftObj=$("leftmenuall");
	if(leftObj.style.display=="none"){
		leftObj.style.display="block";
		self.src="../images/hideleft.gif";
	}else{
		leftObj.style.display="none";
		self.src="../images/showleft.gif";
	}
}

function ajaxSubmit(sort1){
    //获取用户输入
    var B=document.getElementById("B").value;
	var C=document.getElementById("C8").value;
    var url = "../hrm/Ajax_search_yh.asp?B="+escape(B)+"&C="+escape(C) +"&sort1="+escape(sort1) + "&strperson="+window.strPerson+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage_cp();
  };
  xmlHttp.send(null);
}
function updatePage_cp() {
  if (xmlHttp.readyState < 4) {
	cp_search.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	cp_search.innerHTML=response;
	xmlHttp.abort();
  }
}

function ajaxSubmit2(sort1){
    setTimeout("ajaxSubmit(2);",500);
}

function ajaxSubmit_page(pid,pagenum,ftype)
{
	if (pagenum<1)
	{
		pagenum=1;
	}
	var B=document.getElementById("B").value;
	var C=document.getElementById("C8").value;
	xmlHttp.open("get","Ajax_hrmDom.asp?pagenum="+pagenum+"&pid="+pid+"&ftype="+ftype+"&B="+escape(B)+"&C="+escape(C)+"&strperson="+window.strPerson+"&r="+Math.round(Math.random()*100),false);
	xmlHttp.onreadystatechange = function () {
		if (xmlHttp.readyState == 4) {
			var yy = xmlHttp.responseText;
			if (ftype == 3)
			{
				cp_search.innerHTML=yy;
			}
			else if (ftype == 2) {
				document.getElementById("xz"+pid+"").innerHTML = yy;
			}
			else if (ftype == 1)
			{
				document.getElementById("manager").innerHTML = yy;
			}
			else if (ftype == 4)
			{
				document.getElementById("bumen").innerHTML = yy;
			}
			else if (ftype == 5)
			{
				document.getElementById("bm"+pid+"").innerHTML = yy;
			}
			else if (ftype == 6)
			{
				document.getElementById("bmperson"+pid+"").innerHTML = yy;
			}
			else {
				//document.getElementById("a" + pid).cells[0].innerHTML = yy;
				alert(yy);
			}
		}
	}
	xmlHttp.send(null);
}
function goPage(id,ftype)
{
	var pagenum=1;
	if(ftype==2||ftype==1||ftype==3||ftype==4)
	{
		pagenum=document.getElementById('txtGoToPage_'+id).value;
	}
	else if (ftype==5)
	{
		pagenum=document.getElementById('bmtxtGoToPage_'+id).value;
	}
	else if (ftype==6)
	{
		pagenum=document.getElementById('bmpersontxtGoToPage_'+id).value;
	}
	else
	{
		pagenum=1
	}
	if(pagenum&&!isNaN(pagenum))
	{
		ajaxSubmit_page(id,parseInt(pagenum),ftype);
	}
	else
	{
		alert('请输入数字');
		if(ftype==1||ftype==2||ftype==3||ftype==4){
			document.getElementById('txtGoToPage_'+id).value=1;
			document.getElementById('txtGoToPage_'+id).select();
		}
		else if (ftype==5)
		{
			document.getElementById('bmtxtGoToPage_'+id).value=1;
			document.getElementById('bmtxtGoToPage_'+id).select();
		}
		else if (ftype==6)
		{
			document.getElementById('bmpersontxtGoToPage_'+id).value=1;
			document.getElementById('bmpersontxtGoToPage_'+id).select();
		}
	}
}

function MM_findObj(n, d) { //v4.01
  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);
  if(!x && d.getElementById) x=d.getElementById(n); return x;
}

function MM_preloadImages() { //v3.0
  var d=document; if(d.images){ if(!d.MM_p) d.MM_p=new Array();
    var i,j=d.MM_p.length,a=MM_preloadImages.arguments; for(i=0; i<a.length; i++)
    if (a[i].indexOf("#")!=0){ d.MM_p[j]=new Image; d.MM_p[j++].src=a[i];}}
}

function MM_swapImgRestore() { //v3.0
  var i,x,a=document.MM_sr; for(i=0;a&&i<a.length&&(x=a[i])&&x.oSrc;i++) x.src=x.oSrc;
}

function MM_swapImage() { //v3.0
  var i,j=0,x,a=MM_swapImage.arguments; document.MM_sr=new Array; for(i=0;i<(a.length-2);i+=3)
   if ((x=MM_findObj(a[i]))!=null){document.MM_sr[j++]=x; if(!x.oSrc) x.oSrc=x.src; x.src=a[i+2];}
}


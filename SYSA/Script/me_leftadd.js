function changeMobile(recid,mobilenum,flg){
	try{
		var obj = window.ActiveXObject?window.frames['cFF2']:document.getElementById('cFF2').contentWindow;
		if (obj.document.getElementById('takeName').value=="" && obj.document.getElementById('sort').value==""){
			tmpstr="";
		}else{
			tmpstr=obj.document.getElementById('takeNames').value;
		}
		if((","+tmpstr+",").indexOf(","+recid+",")<0){
			tmpstr=obj.document.getElementById('takeName').value;
			if(tmpstr==""){
				tmpstr=recid;
			}else{
				tmpstr+=","+recid;
			}
			obj.document.getElementById('takeName').value=tmpstr;
			if(document.getElementById("IMG"+recid+"_"+mobilenum)){document.getElementById("IMG"+recid+"_"+mobilenum).src="../images/d14.gif";}
			tmpstr=obj.document.getElementById('takeName2').value;
			if((","+tmpstr+",").indexOf(","+recid+",")>=0){
				tmpstr=(","+tmpstr+",").replace(","+recid+",",",");
				if(tmpstr!=""){
					if(tmpstr==","){
						tmpstr="";
					}else{
						tmpstr=tmpstr.substring(1,tmpstr.length-1);
					}
				}
				obj.document.getElementById('takeName2').value=tmpstr;
			}
		}else{
			tmpstr=obj.document.getElementById('takeName').value;
			if((","+tmpstr+",").indexOf(","+recid+",")>=0){
				tmpstr=(","+tmpstr+",").replace(","+recid+",",",");
				if(tmpstr!=""){
					if(tmpstr==","){
						tmpstr="";
					}else{
						tmpstr=tmpstr.substring(1,tmpstr.length-1);
					}
				}
				obj.document.getElementById('takeName').value=tmpstr;
			}
			tmpstr=obj.document.getElementById('takeName2').value;
			if(flg){
				if(tmpstr!=""){
					tmpstr+=","+recid;
				}else{
					tmpstr=recid;
				}
				if(document.getElementById("IMG"+recid+"_"+mobilenum)){document.getElementById("IMG"+recid+"_"+mobilenum).src="../images/155.gif";}
			}
			obj.document.getElementById('takeName2').value=tmpstr;
		}
		obj.document.getElementById('date').submit();
	}catch(e1){
		window.frames['cFF2'].history.back();
	}

}
function GetXmlHttp(){
	var MSXML	=	['Msxml2.XMLHTTP',
				 'Microsoft.XMLHTTP',
				 'Msxml2.XMLHTTP.5.0',
				 'Msxml2.XMLHTTP.4.0',
				 'Msxml2.XMLHTTP.3.0'
				];
	if (window.XMLHttpRequest) {
		try { return new XMLHttpRequest(); }
		catch (e) { }
	}
	for (var i = 0; i < MSXML.length; i++){
		try {return new ActiveXObject(MSXML[i]);}
		catch (e){}
	}
}

function getAll(cid){	
	var yy="";
	var xmlhttp=new GetXmlHttp();
	if(xmlhttp){
		xmlhttp.open("get","getPerson.asp?cid="+cid+"&action=address&r="+Math.round(Math.random()*100),false);
		xmlhttp.send(null);
		xmlhttp.onreadystatechange=function(){
			if(xmlhttp.readyState==4){
				yy=unescape(xmlhttp.responseText).split("</noscript>")[1].replace(" ","").replace("\r\n","");
			}
		}
	}
	try{
		if (window.frames['cFF2'].document.getElementById('sort')){
			if (window.frames['cFF2'].document.getElementById('sort').value==""){
				window.frames['cFF2'].document.getElementById('sort').value=cid;
				var zz=yy.split(",");
				for(var m=0;m<zz.length;m++){
					var kk=zz[m].split(";");
					if(kk[0]&&kk[1]){
						if(document.getElementById("IMG"+kk[0]+"_"+kk[1]))document.getElementById("IMG"+kk[0]+"_"+kk[1]).src="../images/d14.gif";
					}
				}
			}
			else{
				sortstr=","+window.frames['cFF2'].document.getElementById('sort').value+",";
				if (sortstr.indexOf(","+cid+",")>=0){
					sortstr=sortstr.replace(","+cid+",",",");
					if (sortstr==","){
						window.frames['cFF2'].document.getElementById('sort').value="";
					}
					else{
						window.frames['cFF2'].document.getElementById('sort').value=sortstr.substring(1,sortstr.length-1);
					}
					var zz=yy.split(",");
					for(var m=0;m<zz.length;m++){
						var kk=zz[m].split(";");
						if(kk[0]&&kk[1]){
							if(document.getElementById("IMG"+kk[0]+"_"+kk[1]))document.getElementById("IMG"+kk[0]+"_"+kk[1]).src="../images/155.gif";
						}
					}
				}
				else
				{
					window.frames['cFF2'].document.getElementById('sort').value=window.frames['cFF2'].document.getElementById('sort').value+","+cid;
					var zz=yy.split(",");
					for(var m=0;m<zz.length;m++){
						var kk=zz[m].split(";");
						if(kk[0]&&kk[1]){
							if(document.getElementById("IMG"+kk[0]+"_"+kk[1]))document.getElementById("IMG"+kk[0]+"_"+kk[1]).src="../images/d14.gif";
						}
					}
				}
			}
		}
		window.frames['cFF2'].document.getElementById('date').submit();
	}
	catch(e1){
		window.frames['cFF2'].src="all.asp";
	}

}
function chageIframe(url){
   var urlValue = url;
	 if(urlValue!="")
	 {
   document.getElementById("cFF2").src = urlValue;
	 }

}


function ajaxSubmit_page(pid,pagenum,ftype){
	var xmlhttp=window.ActiveXObject? new ActiveXObject("Microsoft.XMLHTTP"):new XMLHttpRequest();
	if(xmlhttp){
	    xmlhttp.onreadystatechange = function () {
	        if (xmlhttp.readyState == 4) {
	            var yy = unescape(xmlhttp.responseText).split("</noscript>")[1];
	            if (ftype == 3 || !document.getElementById("a" + pid)) {
	                document.getElementById("cp_search").innerHTML = yy;
	            }
	            else {
	                document.getElementById("a" + pid).cells[0].innerHTML = yy;
	            }
	            var imgobj = document.getElementsByTagName("img");
	            try {	
					var obj = window.ActiveXObject?window.frames['cFF2']:document.getElementById('cFF2').contentWindow;
	                var allord = obj.document.getElementById('takeNames').value;
	            }
	            catch (e1) {
	                window.frames['cFF2'].src = "all.asp";
	            }
	            for (var j = 0; j < imgobj.length; j++) {
	                var tmpid = imgobj[j].id;
	                if (tmpid && tmpid.substring(0, 3) == "IMG") {
	                    var tmpord = tmpid.substring(3,tmpid.indexOf("_"));
	                    if (("," + allord + ",").indexOf("," + tmpord + ",") >= 0) {
	                        imgobj[j].src = "../images/d14.gif";
	                    }
	                }
	            }
	        }
	    }
		xmlhttp.open("get","search_person.asp?B="+document.getElementById("B").value+"&C="+document.getElementById("C8").value+"&P="+pagenum+"&sort="+pid+"&ftype="+ftype+"&r="+Math.round(Math.random()*100),false);
		xmlhttp.send(null);
	}
}

function goPage(pageid,ftype)
{
	var pagenum=document.getElementById('txtGoToPage_'+pageid).value;
	if(pagenum&&!isNaN(pagenum))
	{
		ajaxSubmit_page(pageid,parseInt(pagenum),ftype);
	}
	else
	{
		alert('请输入数字');
	}
}

//高级搜索
function Left_adSearch(obj){
	var sdivobj=document.getElementById("adsDiv");
	if(sdivobj.style.display!="none"){
		Left_adClose();
	}
	else
	{
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


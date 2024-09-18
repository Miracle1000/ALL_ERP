function showBG(flg){
	var bg=document.getElementById("bgdiv");
	if (document.body.offsetHeight > 0) {
	    bgdiv.style.height = document.body.offsetHeight + "px";
	}
	bgdiv.style.display=flg?"block":"none";
}

function searchStoreHC(pg){
	var dateType = jQuery('#hc_dateType').val();
	var dateBegin = jQuery('#hc_dateBegin').val();
	var dateEnd = jQuery('#hc_dateEnd').val();
	var searchType = jQuery('#hc_searchType').val();
	var searchKeyWord = jQuery('#hc_searchKeyWord').val();
	var params = "&pg="+pg+"&dateType="+dateType+"&dateBegin="+dateBegin+"&dateEnd="+dateEnd+"&searchType="+searchType+"&searchKeyWord="+searchKeyWord;
	showStore(null,params);
}

var __param = {};
function showStore(obj,conditionParams){
	var showobj=document.getElementById("showhc");
	var hcdivobj=document.getElementById("hcdiv");
	if (obj){
		var x=obj.offsetLeft,y=obj.offsetTop;
		var obj2=obj;
		while(obj2=obj2.offsetParent){
			x+=obj2.offsetLeft;
			y+=obj2.offsetTop;
		}
		hcdivobj.style.display="block";
		showobj.innerHTML="";
		hcdivobj.style.left= 100+"px";
		hcdivobj.style.top=y-50+"px";
		showBG(true);
		var cell=obj.parentElement.obj;
		var row = cell.getParent();
		var isOpenProductAttr = row.Cells[8].datatype;
		if (isOpenProductAttr == "proAttr1") {
		    __param.proAttr1 = row.Cells[8].value;
		    __param.proAttr2 = row.Cells[9].value;
		}
		__param.pid=row.Cells[2].value;
		__param.unit=row.Cells[6].value;
		__param.tindex=row.Cells[1].value;
	}

	var url = "getStoreHC.asp?ord=" + __param.pid + "&unit=" + __param.unit + "&tindex=" + __param.tindex + "&stamp=" + (Math.random() * 10).toString().replace(".", "") + (conditionParams ? conditionParams : '') + (__param.proAttr1 == null ? '' : '&proAttr1=' + __param.proAttr1) + (__param.proAttr2 == null ? '' : '&proAttr2=' + __param.proAttr2);
	xmlHttp.open("post", url, false);
	xmlHttp.send(null);
	var response = xmlHttp.responseText;
	if(response.substring(0,6)!="<scrip"){
		showobj.innerHTML=response;
	}else{
		alert("登录已超时");
		showBG(false);
	}
	xmlHttp.abort();
}

function saveHC(ckid,tindex){
	var hcnum=document.getElementById("backnum_"+ckid).value;
	var idx=-1;
	for(var i=0;i<lv.Rows.length;i++){if(lv.Rows[i].Cells[1].value==tindex){idx=i;break;}}
	if(idx==-1){alert('未找到匹配的行，可能对冲信息所依附的行已被删除');return;}
	var numindex = 8;
	for (var i = 0; i<lv.Headers.length ; i++ )
	{
		if(lv.Headers[i].innerHTML==("数量")) {
			numindex = i;
		}
	}
	for(var i=0; i<lv.Rows[0].Cells.length; i++){
		if(lv.Rows[0].Cells[i].datatype=="rknum"){
			numindex = i;
			break;
		}
	}
	var kuinnum=lv.Rows[idx].Cells[numindex].value;
	if(hcnum==""||isNaN(hcnum)){
		alert("对冲数量不合法");
		return false;
	}
	if(kuinnum==""||isNaN(kuinnum)){
		alert("对冲数量不合法");
		return false;
	}

	var url="SaveStoreHC.asp?ckid="+ckid+"&cpmxid="+escape(tindex)+"&hcnum="+escape(hcnum)+"&kuinnum="+kuinnum+"&stamp=" + (Math.random()*10).toString().replace(".","");
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		if (xmlHttp.readyState == 4){
			var response = xmlHttp.responseText;
			if(response=="成功!"){
				document.getElementById("backnum_"+ckid).style.backgroundColor="green";
				document.getElementById("backnum_"+ckid).style.color="white";
			}else{
				alert(response);
				document.getElementById("backnum_"+ckid).value="0";
			}
			xmlHttp.abort();
		}
	};
	xmlHttp.send(null);
}


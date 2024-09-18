
function spec(sid){	
	//document.getElementById(sid).value=document.getElementById(sid).value.replace(/[\"\'/\\,]/,'');	
}
function Ajax(){
	var xH,xA="",fun=arguments[1];
	for (i=2;i<arguments.length;i++) xA+=",'"+arguments[i]+"'";
	this.Ajax_sced=function(){ if(xH.readyState==4||xH.readyState=="complete") eval("fun(xH.responseText"+xA+");");}
	this.Ajax_gxho=function(handler){ var oXH=false;
		if(window.XMLHttpRequest) { oXH = new XMLHttpRequest(); if(oXH.overrideMimeType) oXH.overrideMimeType('text/xml');
		}else if(window.ActiveXObject) {
			var versions=['Microsoft.XMLHTTP','MSXML.XMLHTTP','Microsoft.XMLHTTP','Msxml2.XMLHTTP.7.0','Msxml2.XMLHTTP.6.0','Msxml2.XMLHTTP.5.0','Msxml2.XMLHTTP.4.0','MSXML2.XMLHTTP.3.0','MSXML2.XMLHTTP'];	for(var i=0;i<versions.length;i++) {try {oXH=new ActiveXObject(versions[i]);if(oXH) break;	} catch(e) {}};
		} try{oXH.onreadystatechange=handler; return oXH;} catch(e){ alert("AJAX环境错误"); return ;} 
	}
	if (arguments[0].length>0){ xH=this.Ajax_gxho(this.Ajax_sced); xH.open("POST",arguments[0],true); xH.send(" ");}else{ eval("fun(''"+xA+");");}
}
function sent(s1,s2,tname){
	if(s1.indexOf("IsUsing_")>-1){
		if(s2=="1"){
			document.getElementById("sz_"+s1.replace("IsUsing_","")+"_3").style.display="";
		}else{
			document.getElementById("sz_"+s1.replace("IsUsing_","")+"_3").style.display="none";
		}
	}
	if (tname!=1 && tname!=45)
	{
		s2=trim(s2);
		s2=s2.replace(/\[/g,"").replace(/\]/g,"")
		url="updatezd.asp?TName="+tname+"&flg=1&items="+s1+"&vals="+escape(s2);
		if(s2!="")
		Ajax(url,shows);
		if(s1.indexOf("FType_")>-1){
			document.getElementById("Y"+s1).value = s2;
		}		
	}
}
function shows(str){
	//alert(str);
}

function FAlert(){
	alert("类型更改后，以前录入的字段内容就不能正确显示出来");
}
function checkFType(objType,del){		//Task. 1282 . 添加对字段类型改变后有数据兼容问题的弹出提示 . 2014-1-21 . ljh 
	var typeId = objType.name;
	var ytypeId = "Y"+typeId;
	var newType = objType.value
	var yType = document.getElementById(ytypeId).value;
	if(newType != yType && del==1){
		if(yType=="1" || yType=="2"){	//单行/多行文本向其他类型转换
			if(newType=="3" || newType=="4" || newType=="6" || newType=="7"){
				FAlert();
			}
		}else if(yType=="3"){	//日期类型向其他类型转换
			if(newType=="4" || newType=="6" || newType=="7"){
				FAlert();
			}
		}else if(yType=="4"){	//数字类型向其他类型转换
			if(newType=="6" || newType=="7"){
				FAlert();
			}
		}else if(yType=="5"){	//备注类型向其他类型转换
			if(newType=="3" || newType=="4" || newType=="6" || newType=="7"){
				FAlert();
			}
		}else if(yType=="6"){	//是/否类型向其他类型转换
			if(newType=="4" || newType=="7"){
				FAlert();
			}
		}
	}
}


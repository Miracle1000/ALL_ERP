/*
'创建人：曲俊伟
'创建时间:2012-11-2
'功能：用于后台交互异步传输数据AJAX
*/
//替换 document.getElmentById..
function $BI(){return document.getElementById?document.getElementById(arguments[0]):eval(arguments[0]);}



//打开对象
function openpl(id){$BI(id).style.display='block';}

// 兼容IE FF的ByName方法
// 调用： FnGetElementsByName("div","divName")
var FnGetElementsByName = function(tag, name){
    var returns = document.getElementsByName(name);
    if(returns.length > 0) return returns;
	
    returns = new Array();
    var e = document.getElementsByTagName(tag);
    //for(var i = 0; i < e.length; i++){
    for(var i = e.length;i--;){
        if(e[i].getAttribute("name") == name){
            returns[returns.length] = e[i];
        }
    }
    return returns;
}


//创建AJAX对象
function createXMLHttps()
{
    var ret = null;
    try {
        ret = new ActiveXObject('Msxml2.XMLHTTP');
    }
    catch (e) {
        try {
            ret = new ActiveXObject('Microsoft.XMLHTTP');
        }
        catch (ee) {
            ret = null;
        }
    }
    if (!ret && typeof XMLHttpRequest != 'undefined')
        ret = new XMLHttpRequest();
    return ret;
}

var xmlhttp;
function sell(url,ufc) {
	if (window.XMLHttpRequest) {
		xmlhttp=new XMLHttpRequest();
	}else {
		xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
	}
	xmlhttp.onreadystatechange=ufc;
	xmlhttp.open("GET",url,true);
	xmlhttp.send();
}




//实现部门小组联动
function mysel(str) {
//alert(str);
	if (str.length==0) {
		//document.getElementById("span1").innerHTML="";
	}
URL="ajax.asp?cid="+str+"&fromname=gate2&xtime="+ new Date().getTime(); 
//alert(sd);
var xmlhttp = createXMLHttps();
xmlhttp.open("GET",URL,true);
xmlhttp.send(null);
xmlhttp.onreadystatechange = function() {
if (xmlhttp.readyState == 4) {
	var js_pd=unescape(xmlhttp.responseText);
		//由于执行操作的asp页面中引用的头不是干净的数据库连接带有样式。所以无法返回想要的回想错误数字改用indexOf判断 NU001 错误号
		if(js_pd.indexOf("NU001") > 0){
			//$BI("dishow").innerHTML=js_pd;
		}
		else {
			//显示分页内容
			$BI("span1").innerHTML=js_pd;
		}
		xmlhttp=null;
		}
	}



}
function mysel2(strg,bmtc) {
//alert(strg+bmtc);
if (strg.length==0) {
	//	document.getElementById("span2").innerHTML="";
	}
	//document.getElementById("span2").innerHTML="";	
	if (strg=="岗位") {
		//document.getElementById("span2").innerHTML="";
		//return;
	}else {
	  sell("ajax.asp?sid="+strg+"&bmtc="+bmtc+"&fromname=gate",function() {
		  if (xmlhttp.readyState==4 && xmlhttp.status==200) {
		  //document.getElementById("span2").innerHTML=xmlhttp.responseText;
		  }
	  });
	}
}





//共享人ShowGXR
function ajax_showgxr(q,m) {
//alert(str);
	  sell("ajax_showgxr.asp?cid="+q+"&sid="+m+"&fromname=gate3",function() {
		  if (xmlhttp.readyState==4 && xmlhttp.status==200) {
		  $BI("ShowGXR").innerHTML=xmlhttp.responseText;
		  }
	  });
}


//实现分享用户选择界面呈现
var ThemeID;
function  FnUserOrd(strshow,tj,ch,vch)  {
		//	alert(strshow);
//如果是人员的话则逆向回退小组
if (strshow=="ry") {
		strshow=$BI('sel2').value;
		tj="xz";		
	}
//如果是小组的话则逆向回退部门
if (strshow=="ss") {
		strshow=$BI('sel1').value;
		tj="bm";		
	}	
URL="ajax_gxrlist.asp?strshow="+escape(strshow)+"&tj="+escape(tj)+"&ch="+escape(ch)+"&vch="+escape(vch)+"&xtime="+ new Date().getTime();
//alert(URL);
var xmlhttp = createXMLHttps();
xmlhttp.open("GET",URL,true);
xmlhttp.send(null);
xmlhttp.onreadystatechange = function() {

if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
	var js_pd=unescape(xmlhttp.responseText);
		//由于执行操作的asp页面中引用的头不是干净的数据库连接带有样式。所以无法返回想要的回想错误数字改用indexOf判断 NU001 错误号		
		if(js_pd.indexOf("NU001") >= 0){
			$BI("ShowSubjectKJ").innerHTML="<center>没有信息！</center>";
		}
		else {
			//显示分页内容
			$BI("ShowSubjectKJ").innerHTML=js_pd;
			try{
				parent.document.getElementById('S9').style.height=document.getElementById('ShowSubjectKJ').offsetHeight+100 + 'px';
			}catch(e){}
		}
		xmlhttp=null;
		}
	}
}

function FnUserOrdByFromtype(strshow, tj, ch, vch,fromtype) {
    //	alert(strshow);
    //如果是人员的话则逆向回退小组
    if (strshow == "ry") {
        strshow = $BI('sel2').value;
        tj = "xz";
    }
    //如果是小组的话则逆向回退部门
    if (strshow == "ss") {
        strshow = $BI('sel1').value;
        tj = "bm";
    }
    URL = "ajax_gxrlist.asp?strshow=" + escape(strshow) + "&fromtype=" + escape(fromtype) + "&tj=" + escape(tj) + "&ch=" + escape(ch) + "&vch=" + escape(vch) + "&xtime=" + new Date().getTime();
    //alert(URL);
    var xmlhttp = createXMLHttps();
    xmlhttp.open("GET", URL, true);
    xmlhttp.send(null);
    xmlhttp.onreadystatechange = function () {

        if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
            var js_pd = unescape(xmlhttp.responseText);
            //由于执行操作的asp页面中引用的头不是干净的数据库连接带有样式。所以无法返回想要的回想错误数字改用indexOf判断 NU001 错误号		
            if (js_pd.indexOf("NU001") >= 0) {
                $BI("ShowSubjectKJ").innerHTML = "<center>没有信息！</center>";
            }
            else {
                //显示分页内容
                $BI("ShowSubjectKJ").innerHTML = js_pd;
                try {
                    parent.document.getElementById('S9').style.height = document.getElementById('ShowSubjectKJ').offsetHeight + 100 + 'px';
                } catch (e) { }
            }
            xmlhttp = null;
        }
    }
}



function  Fnsplc(strg,wdord)  {
	if(typeof(wdord) == "undefined"){
		wdord = 0;
	}
URL="Ajax_shenpiren.asp?sptype="+escape(strg)+"&ord="+wdord+"&xtime="+ new Date().getTime();
var xmlhttp = createXMLHttps();
xmlhttp.open("GET",URL,true);
xmlhttp.send(null);
xmlhttp.onreadystatechange = function() {
if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
		var js_pd=unescape(xmlhttp.responseText);
		//判断1没有数据显示文字记录
		//alert(js_pd);
		//由于执行操作的asp页面中引用的头不是干净的数据库连接带有样式。所以无法返回想要的回想错误数字改用indexOf判断 NU001 错误号
		if(js_pd.indexOf("NU001") >= 0){
			$BI("ShowSPR").innerHTML="没有信息！";
			//把隐藏域的值设置为空
			//$BI('cateid_sp').value = "";
			//$BI("sp_id").value = "";
			//$BI("spMD").value = "";
			$BI("contentSP").style.display="none"; 
			$BI("contentSP1").style.display="none"; 

		}
		else {
			//显示分页内容
			$BI("contentSP").style.display=""; 
			$BI("contentSP1").style.display=""; 
			$BI("ShowSPR").innerHTML=js_pd;
		}
		xmlhttp=null;
		}
	}
}



//实现默认审批人
function ckmr(id,sd) {
	var ckds;
if($BI("spMD").checked==false) {
	ckds = 0;
	}
if($BI("spMD").checked==true) {
	ckds = 1;
	}	
URL="ajax_moren.asp?strshow="+escape(id)+"&ckds="+escape(ckds)+"&sd="+escape(sd)+"&xtime="+ new Date().getTime(); 
//alert(URL);
var xmlhttp = createXMLHttps();
xmlhttp.open("GET",URL,true);
xmlhttp.send(null);
xmlhttp.onreadystatechange = function() {
if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
	var js_pd=unescape(xmlhttp.responseText);
		//由于执行操作的asp页面中引用的头不是干净的数据库连接带有样式。所以无法返回想要的回想错误数字改用indexOf判断 NU001 错误号
		if(js_pd.indexOf("NU001") > 0){
			$BI("ShowSubjectKJ").innerHTML=js_pd;
		}
		//else {
			//显示分页内容
			//alert("操作成功!");
		//}
		xmlhttp=null;
		}
	}
}


//列表页面的分类收索
function Fn_leftadd(id,sd,urld,muid) {
URL="ajax_leftadd.asp?Showname="+escape(sd)+"&idx="+escape(id)+"&urld="+escape(urld)+"&muid="+escape(muid)+"&xtime="+ new Date().getTime(); 
//alert(sd);
var xmlhttp = createXMLHttps();
xmlhttp.open("GET",URL,true);
xmlhttp.send(null);
xmlhttp.onreadystatechange = function() {
if (xmlhttp.readyState == 4) {
	var js_pd=unescape(xmlhttp.responseText);
		//由于执行操作的asp页面中引用的头不是干净的数据库连接带有样式。所以无法返回想要的回想错误数字改用indexOf判断 NU001 错误号
		if(js_pd.indexOf("NU001") > 0){
			//$BI("dishow").innerHTML=js_pd;
		}
		else {
			//显示分页内容
			$BI("dishow").innerHTML=js_pd;
		}
		xmlhttp=null;
		}
	}
}




// 获取共享岗位数据
function getSharePostList(id , stype){	
	$.post("set_gwlist.asp",{__msgid:"getPostList",id:id,stype : stype},function(data){
		$("#ShowGXR").html(data);
	});



}
// 获取共享岗位数据
function getSharePostList(id, stype, fromtype) {
    if (fromtype == "")
    {
        $.post("set_gwlist.asp", { __msgid: "getPostList", id: id, stype: stype, fromtype: fromtype }, function (data) {
            $("#ShowGXR").html(data);
        });
    }
    else {
        $.post("../document/set_gwlist.asp", { __msgid: "getPostList", id: id, stype: stype, fromtype: fromtype }, function (data) {
            $("#ShowGXR").html(data);
        });
    }
    



}
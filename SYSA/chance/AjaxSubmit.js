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



//数据呈现
function Fnshowxx(id) {
	URL="ajax_ganttchart.asp?id="+escape(id)+"&xtime="+ new Date().getTime(); 
	var xmlhttp = createXMLHttps();
	xmlhttp.open("GET",URL,true);
	xmlhttp.send(null);
	xmlhttp.onreadystatechange = function() {
	$BI("xx").innerHTML="<center><img src=../images/loading2.gif border=0></center>"
	if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
		var js_pd=unescape(xmlhttp.responseText);
		if(js_pd.indexOf("NU001") == 0){
			$BI("xx").innerHTML="<center>没有信息！</center>";
		}
		else {
			$BI("xx").innerHTML=js_pd;
		}
		xmlhttp=null;
		}
	}
}



function Fnitemzygl(btime,etime,cs) {
	URL="ajax_Itemzygl.asp?btime="+escape(btime)+"&etime="+escape(etime)+"&cs="+escape(cs)+"&xtime="+ new Date().getTime(); 
	var xmlhttp = createXMLHttps();
	xmlhttp.open("GET",URL,true);
	xmlhttp.send(null);
	xmlhttp.onreadystatechange = function() {
	$BI("itemzygl").innerHTML="<center><img src=../images/loading2.gif border=0></center>"
	if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
		var js_pd=unescape(xmlhttp.responseText);
		if(js_pd.indexOf("NU001") == 0){
			$BI("itemzygl").innerHTML="<center>没有信息！</center>";
		}
		else {
			$BI("itemzygl").innerHTML=ajax.PreScript(js_pd);
		}
		xmlhttp=null;
		}
	}
}

function Fnitemjdgz(btime,etime,xmzt,cs) {
URL="ajax_Itemjdgz.asp?btime="+escape(btime)+"&etime="+escape(etime)+"&xmzt="+escape(xmzt)+"&cs="+escape(cs)+"&xtime="+ new Date().getTime(); 
var xmlhttp = createXMLHttps();
xmlhttp.open("GET",URL,true);
xmlhttp.send(null);
xmlhttp.onreadystatechange = function() {
$BI("itemjdgz").innerHTML="<center><img src=../images/loading2.gif border=0></center>"
if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
	var js_pd=unescape(xmlhttp.responseText);
		if(js_pd.indexOf("NU001") == 0){
			$BI("itemjdgz").innerHTML="<center>没有信息！</center>";
		}
		else {
			$BI("itemjdgz").innerHTML=js_pd;
		}
		xmlhttp=null;
		}
	}
}

//翻动日期
function Fndatetimefy(mb,act) {
	var cp="";
	  sell("ajaxdatetime.asp?mb="+mb+"&act="+act+"&fromname=gate",function() {
		  if (xmlhttp.readyState==4 && xmlhttp.status==200) {
			  cp = xmlhttp.responseText;
			  cp = cp.split(",");
		  $BI('date5').value=cp[0];
		  $BI('date6').value=cp[1];
		  }
	  });
}

var hide = false;
function xmldata1(logid,logTitle,beginDate,endDate,executor,statuStr,open,intro,uid){
	hide = false;
	var dhtml=$BI('dhtml');
	var left=parseInt(event.clientX)-5;
	var top=event.clientY+document.body.scrollTop;  //鼠标的y坐标
	var htmlleft=document.body.offsetWidth; //所打开当前网页，办公区域的高度，网页的高度
	if(htmlleft-event.clientX<300) {
		left = htmlleft - 300;
	}
	var htmlheight=document.body.offsetHeight; //所打开当前网页，办公区域的高度，网页的高度
	var scrollheight = window.screen.availHeight;//整个windows窗体的高度
	if(htmlheight-event.clientY<100) {
		top = top - 20 * (4 - parseInt((htmlheight - event.clientY) / 100));
	}
	$BI('dhtml').style.top=top+"px";
	$BI('dhtml').style.left=left+"px";	
	intro = ','+intro+','
	var ajaxhtml = "";
	ajaxhtml += "<table width='400' border='1' borderColor='#ccc' cellpadding='3' cellspacing='1' bgcolor='#C0CCDD' id='content'>"
	ajaxhtml += "<tr><td align='right' height='27'>项目阶段：</td><td>"+ logTitle +"</td></tr>"
	ajaxhtml += "<tr><td align='right' height='27'>执行人员：</td><td>"+ executor +"</td></tr>"
	ajaxhtml += "<tr><td align='right' height='27'>时&nbsp;&nbsp;&nbsp;&nbsp;间：</td><td>"+ beginDate +" - "+ endDate +"</td></tr>"
	ajaxhtml += "<tr><td align='right' height='27'>执行状态：</td><td>"+ statuStr +"</td></tr>"
	if(open=3 || (open=1 && intro.indexof(','+uid+',')>0)){
		ajaxhtml += "<tr>"
		ajaxhtml += "<td colspan='2' height='27'><input type='button' value='详情' class='anybutton' onclick=\"window.open('ChanceLogPage.asp?ord="+logid+"','newwin123','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100')\"></td>"
		ajaxhtml += "</tr>"
	}
	ajaxhtml += "</table>"
	if (ajaxhtml!=""){
			$BI('dhtml').innerHTML=ajaxhtml;
			$BI('dhtml').style.display='block';
	}
	
}

function shouLabel(){
	if($BI('dhtml').style.display=='block'){
		hide = false
		$BI('dhtml').style.display='block';	
	}
}

function hidelabel(){	
	hide = true;
	window.setTimeout("hidelabel2()", 10); 
}

function hidelabel2(){	
	if($BI('dhtml').style.display=="block" && hide == true){
		$BI('dhtml').innerHTML="";
		$BI('dhtml').style.display='none';
	}
}

